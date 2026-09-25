import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'mailboxes_controller.dart';

typedef TagChanges = ({Set<String> add, Set<String> remove});

class TagsPickerController extends GetxController {
  final List<EmailSummary> emails;

  TagsPickerController(this.emails);

  /// Per tag id: true when every email has it, false when none does, null
  /// when only some do.
  final states = <String, bool?>{}.obs;
  final Map<String, bool?> _initial = {};

  @override
  void onInit() {
    super.onInit();
    for (final tag in Get.find<MailboxesController>().tags) {
      final holding = emails.where((e) => e.tags.contains(tag.id)).length;
      _initial[tag.id] = holding == 0
          ? false
          : holding == emails.length
          ? true
          : null;
    }
    // A copy: assignAll keeps the map it is given, and toggling would then
    // rewrite the initial state it is compared against.
    states.assignAll(Map.of(_initial));
  }

  bool? stateOf(String tagId) =>
      states.containsKey(tagId) ? states[tagId] : false;

  /// Its match condition holds every email: taking a label off changes
  /// nothing.
  bool isHeldByRule(String tagId) => emails.every(
    (e) => e.tags.contains(tagId) && !e.labels.contains('tag:$tagId'),
  );

  void toggle(String tagId) => states[tagId] = stateOf(tagId) != true;

  void check(String tagId) => states[tagId] = true;

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
