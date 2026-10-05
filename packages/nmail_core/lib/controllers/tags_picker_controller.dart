import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'mailboxes_controller.dart';

typedef TagChanges = ({Set<String> add, Set<String> remove});

class TagsPickerController extends ChangeNotifier {
  final List<EmailSummary> emails;

  TagsPickerController(this.emails) {
    for (final tag in GetIt.I<MailboxesController>().tags) {
      final holding = emails.where((e) => e.tags.contains(tag.id)).length;
      _initial[tag.id] = holding == 0
          ? false
          : holding == emails.length
          ? true
          : null;
    }
    states.addAll(_initial);
  }

  /// Per tag id: true when every email has it, false when none does, null
  /// when only some do.
  final Map<String, bool?> states = {};
  final Map<String, bool?> _initial = {};

  bool? stateOf(String tagId) =>
      states.containsKey(tagId) ? states[tagId] : false;

  /// Its match condition holds every email: taking a label off changes
  /// nothing.
  bool isHeldByRule(String tagId) => emails.every(
    (e) => e.tags.contains(tagId) && !e.labels.contains('tag:$tagId'),
  );

  void toggle(String tagId) {
    states[tagId] = stateOf(tagId) != true;
    notifyListeners();
  }

  void check(String tagId) {
    states[tagId] = true;
    notifyListeners();
  }

  TagChanges get changes => (
    add: {
      for (final MapEntry(:key, :value) in states.entries)
        if (value == true && _initial[key] != true) key,
    },
    remove: {
      for (final MapEntry(:key, :value) in states.entries)
        if (value == false &&
            _initial.containsKey(key) &&
            _initial[key] != false)
          key,
    },
  );

  bool get hasChanges {
    final (:add, :remove) = changes;
    return add.isNotEmpty || remove.isNotEmpty;
  }
}
