import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/mail_match_format.dart';
import 'package:nmail_core/utils/string_color.dart';
import 'mailboxes_controller.dart';

enum MailEntryFormError { nameTaken, saveFailed }

class MailEntryFormController extends ChangeNotifier {
  final MailEntryKind kind;

  /// The entry being edited, null when creating one.
  final MailEntry? entry;

  MailEntryFormController({required this.kind, this.entry}) {
    final match = entry?.match;
    nameController = TextEditingController(text: entry?.name ?? '');
    fromController = TextEditingController(text: formatMatchList(match?.from));
    subjectController = TextEditingController(
      text: formatMatchList(match?.subject),
    );
    _color = entry?.color;
    if (_isCustom(entry?.color)) customColor = entry?.color;
    _hasAttachment = match?.hasAttachment;
    _rulesExpanded = match != null;
    nameController.addListener(_onNameChanged);
    _onNameChanged();
  }

  /// The spec's limit on a trimmed name.
  static const maxNameLength = 64;

  /// Suggested colors, keyed by `#RRGGBB`, with the name `colorName` shows.
  static const palette = {
    '#D50000': 'red',
    '#E67C73': 'pink',
    '#F4511E': 'orange',
    '#F6BF26': 'yellow',
    '#33B679': 'green',
    '#0B8043': 'darkGreen',
    '#039BE5': 'lightBlue',
    '#3F51B5': 'blue',
    '#7986CB': 'lavender',
    '#8E24AA': 'purple',
    '#616161': 'gray',
    '#795548': 'brown',
  };

  late final TextEditingController nameController;
  late final TextEditingController fromController;
  late final TextEditingController subjectController;

  /// `#RRGGBB`, or null for the color the spec derives from the id.
  String? get color => _color;
  set color(String? value) {
    _color = value;
    notifyListeners();
  }

  bool? get hasAttachment => _hasAttachment;
  set hasAttachment(bool? value) {
    _hasAttachment = value;
    notifyListeners();
  }

  bool get rulesExpanded => _rulesExpanded;
  set rulesExpanded(bool value) {
    _rulesExpanded = value;
    notifyListeners();
  }

  String? _color;
  bool? _hasAttachment;
  bool _rulesExpanded = false;

  /// A color from outside [palette], kept while another one is selected.
  String? customColor;
  bool isSaving = false;
  bool canSave = false;
  MailEntryFormError? error;
  bool _isDisposed = false;

  MailboxesController get _mailboxes => GetIt.I<MailboxesController>();

  bool get isEditing => entry != null;

  @override
  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    fromController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  static bool _isCustom(String? hex) =>
      MailboxesController.parseEntryColor(hex) != null &&
      !palette.containsKey(hex!.toUpperCase());

  /// Where the custom color dialog opens.
  Color get customColorSeed =>
      MailboxesController.parseEntryColor(customColor) ??
      MailboxesController.parseEntryColor(_color) ??
      switch (entry) {
        final entry? => getStringColor(entry.id),
        null => MailboxesController.parseEntryColor(palette.keys.first)!,
      };

  void pickCustomColor(String hex) {
    _color = hex;
    if (_isCustom(hex)) customColor = hex;
    notifyListeners();
  }

  void _onNameChanged() {
    final name = nameController.text.trim();
    final taken = _mailboxes
        .entriesOf(kind)
        .any(
          (other) =>
              other.id != entry?.id &&
              other.name.trim().toLowerCase() == name.toLowerCase(),
        );
    error = taken ? MailEntryFormError.nameTaken : null;
    canSave = name.isNotEmpty && !taken;
    notifyListeners();
  }

  /// The saved entry, or null when saving failed and [error] says why.
  Future<MailEntry?> save() async {
    if (!canSave || isSaving) return null;
    isSaving = true;
    error = null;
    notifyListeners();
    final name = nameController.text.trim();
    final match = buildMailMatch(
      from: fromController.text,
      subject: subjectController.text,
      hasAttachment: _hasAttachment,
      original: entry?.match,
    );
    try {
      final existing = entry;
      return existing == null
          ? await _mailboxes.create(kind, name, color: _color, match: match)
          : await _mailboxes.edit(
              kind,
              existing.id,
              name: name,
              color: _color,
              match: match,
            );
    } catch (_) {
      error = MailEntryFormError.saveFailed;
      return null;
    } finally {
      if (!_isDisposed) {
        isSaving = false;
        notifyListeners();
      }
    }
  }
}
