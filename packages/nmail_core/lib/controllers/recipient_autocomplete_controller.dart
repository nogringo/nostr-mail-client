import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/utils/platform_helper.dart';

class RecipientAutocompleteController extends GetxController {
  RecipientAutocompleteController({
    required this.textController,
    required this._excludeIds,
    required this._onContactSelected,
    required this._onManualInput,
  });

  final TextEditingController textController;
  final _contactsService = Get.find<ContactsService>();
  final focusNode = FocusNode();
  final layerLink = LayerLink();
  final tapRegionGroup = Object();
  final textFieldKey = GlobalKey();

  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  BuildContext? _overlayContext;
  WidgetBuilder? _overlayBuilder;
  Set<String> _excludeIds;
  void Function(Contact contact) _onContactSelected;
  Future<bool> Function(String input) _onManualInput;
  bool _isCommittingInput = false;
  String _lastQuery = '';

  List<Contact> suggestions = [];
  int highlightedIndex = -1;
  bool isSearching = false;

  bool get isOverlayVisible => _overlayEntry != null;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(_onFocusChanged);
    textController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    hideOverlay();
    textController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    focusNode.dispose();
    super.onClose();
  }

  void updateConfig({
    required Set<String> excludeIds,
    required void Function(Contact contact) onContactSelected,
    required Future<bool> Function(String input) onManualInput,
  }) {
    _excludeIds = excludeIds;
    _onContactSelected = onContactSelected;
    _onManualInput = onManualInput;
  }

  void bindOverlay(BuildContext context, WidgetBuilder builder) {
    _overlayContext = context;
    _overlayBuilder = builder;
  }

  void onTapOutside(PointerDownEvent event) {
    hideOverlay();
    if (!PlatformHelper.isDesktop && event.kind == PointerDeviceKind.touch) {
      return;
    }
    focusNode.unfocus();
  }

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (_overlayEntry == null || suggestions.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      highlightedIndex = (highlightedIndex + 1) % suggestions.length;
      update();
      updateOverlay();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      highlightedIndex =
          (highlightedIndex - 1 + suggestions.length) % suggestions.length;
      update();
      updateOverlay();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.tab) {
      if (highlightedIndex >= 0 && highlightedIndex < suggestions.length) {
        selectContact(suggestions[highlightedIndex]);
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      hideOverlay();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<void> handleSubmitted(String value) async {
    if (highlightedIndex >= 0 &&
        highlightedIndex < suggestions.length &&
        _overlayEntry != null) {
      selectContact(suggestions[highlightedIndex]);
    } else {
      await commitManualInput(value, expectedText: value);
    }
  }

  Future<bool> commitManualInput(String value, {String? expectedText}) async {
    final input = value.trim();
    if (input.isEmpty || _isCommittingInput) return false;

    _isCommittingInput = true;
    final bool added;
    try {
      added = await _onManualInput(input);
    } finally {
      _isCommittingInput = false;
    }

    if (isClosed) return added;

    if (added &&
        (expectedText == null || textController.text == expectedText)) {
      textController.clear();
      hideOverlay();
      suggestions = [];
      highlightedIndex = -1;
      update();
    }

    return added;
  }

  void selectContact(Contact contact) {
    _onContactSelected(contact);
    textController.clear();
    hideOverlay();
    suggestions = [];
    highlightedIndex = -1;
    update();
  }

  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) return;

    hideOverlay();
    final text = textController.text;
    unawaited(commitManualInput(text, expectedText: text));
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    if (_overlayContext == null || _overlayBuilder == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _overlayBuilder!(context),
    );
    Overlay.of(_overlayContext!).insert(_overlayEntry!);
  }

  void _onTextChanged() {
    final text = textController.text;
    final trimmedText = text.trim();

    if (trimmedText.startsWith('npub1') ||
        trimmedText.startsWith('nprofile1') ||
        trimmedText.startsWith('naddr1')) {
      String? prefix;
      if (trimmedText.startsWith('npub1')) {
        prefix = 'npub1';
      } else if (trimmedText.startsWith('nprofile1')) {
        prefix = 'nprofile1';
      } else if (trimmedText.startsWith('naddr1')) {
        prefix = 'naddr1';
      }

      if (prefix != null) {
        final bech32Part = trimmedText.split('@').first;
        final minLength = prefix == 'npub1'
            ? 63
            : prefix == 'nprofile1'
            ? 59
            : 56;
        if (bech32Part.length >= minLength) {
          unawaited(commitManualInput(trimmedText, expectedText: text));
          return;
        }
      }
    }

    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(trimmedText)) {
      unawaited(commitManualInput(trimmedText, expectedText: text));
      return;
    }

    if (text.endsWith(' ') || text.endsWith(',') || text.endsWith(';')) {
      final input = text.substring(0, text.length - 1).trim();
      if (input.isNotEmpty) {
        unawaited(commitManualInput(input, expectedText: text));
        return;
      }
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      search(trimmedText);
    });
  }

  Future<void> search(String query) async {
    if (query.length < 2) {
      hideOverlay();
      suggestions = [];
      highlightedIndex = -1;
      isSearching = false;
      update();
      return;
    }

    _lastQuery = query;

    final localResults = _contactsService.search(
      query,
      excludeIds: _excludeIds,
    );

    suggestions = localResults;
    highlightedIndex = -1;
    isSearching = query.contains('@');
    update();

    if (localResults.isNotEmpty || query.contains('@')) {
      _showOverlay();
      updateOverlay();
    } else {
      hideOverlay();
    }

    if (query.contains('@')) {
      final asyncResults = await _contactsService.searchAsync(
        query,
        excludeIds: _excludeIds,
      );

      if (_lastQuery == query && !isClosed) {
        suggestions = asyncResults;
        highlightedIndex = -1;
        isSearching = false;
        update();

        if (asyncResults.isNotEmpty) {
          _showOverlay();
          updateOverlay();
        } else {
          hideOverlay();
        }
      }
    }
  }
}
