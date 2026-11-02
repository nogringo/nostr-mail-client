import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/selection_range.dart';

class DraftsController extends ChangeNotifier {
  DraftsController() {
    if (_nostrMailService.hasAccount) {
      isLoading = true;
      _watchSubscription = _nostrMailService.client.watchDrafts().listen(
        _onDrafts,
        onError: (_) {},
      );
    }
  }

  final _nostrMailService = GetIt.I<NostrMailService>();

  List<Draft> drafts = [];
  bool isLoading = false;
  final selectedIds = <String>{};
  final hoveredId = ValueNotifier<String?>(null);

  String? _selectionAnchorId;
  bool _selectionAnchorChecked = false;

  StreamSubscription<List<Draft>>? _watchSubscription;

  bool get hasSelection => selectedIds.isNotEmpty;
  bool isSelected(String id) => selectedIds.contains(id);

  @override
  void dispose() {
    _watchSubscription?.cancel();
    hoveredId.dispose();
    super.dispose();
  }

  void _onDrafts(List<Draft> list) {
    drafts = list;
    isLoading = false;
    final ids = drafts.map((d) => d.draftId).toSet();
    selectedIds.removeWhere((id) => !ids.contains(id));
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    _selectionAnchorId = id;
    _selectionAnchorChecked = selectedIds.contains(id);
    notifyListeners();
  }

  /// Applies the anchor's own state to every row between it and [id], as in
  /// [InboxController.extendSelectionTo].
  void extendSelectionTo(String id) {
    final anchor = _selectionAnchorId;
    final range = anchor == null
        ? const <String>[]
        : idsInRange(drafts.map((d) => d.draftId).toList(), anchor, id);
    if (range.isEmpty) {
      toggleSelection(id);
      return;
    }
    if (_selectionAnchorChecked) {
      selectedIds.addAll(range);
    } else {
      selectedIds.removeAll(range);
    }
    notifyListeners();
  }

  void selectAll() {
    selectedIds
      ..clear()
      ..addAll(drafts.map((d) => d.draftId));
    _selectionAnchorId = null;
    notifyListeners();
  }

  void clearSelection() {
    selectedIds.clear();
    _selectionAnchorId = null;
    notifyListeners();
  }

  /// The watch stream removes it from [drafts].
  Future<void> delete(String draftId) =>
      _nostrMailService.client.deleteDraft(draftId);

  Future<void> deleteSelected() async {
    final ids = selectedIds.toList();
    clearSelection();
    await Future.wait(ids.map(_nostrMailService.client.deleteDraft));
  }
}
