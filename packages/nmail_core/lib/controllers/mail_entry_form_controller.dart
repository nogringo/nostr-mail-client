import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/mail_match_format.dart';
import 'mailboxes_controller.dart';

enum MailEntryFormError { nameTaken, saveFailed }

class MailEntryFormController extends GetxController {
  final MailEntryKind kind;

  /// The entry being edited, null when creating one.
  final MailEntry? entry;

  MailEntryFormController({required this.kind, this.entry});

  /// The spec's limit on a trimmed name.
  static const maxNameLength = 64;

  static const palette = [
    '#D50000',
    '#E67C73',
    '#F4511E',
    '#F6BF26',
    '#33B679',
    '#0B8043',
    '#039BE5',
    '#3F51B5',
    '#7986CB',
    '#8E24AA',
    '#616161',
    '#795548',
  ];

  late final TextEditingController nameController;
  late final TextEditingController fromController;
  late final TextEditingController subjectController;

  /// `#RRGGBB`, or null for the color the spec derives from the id.
  final color = RxnString();
  final hasAttachment = Rxn<bool>();
  final rulesExpanded = false.obs;
  final isSaving = false.obs;
  final canSave = false.obs;
  final error = Rxn<MailEntryFormError>();

  MailboxesController get _mailboxes => Get.find<MailboxesController>();

  bool get isEditing => entry != null;

  @override
  void onInit() {
    super.onInit();
    final match = entry?.match;
    nameController = TextEditingController(text: entry?.name ?? '');
    fromController = TextEditingController(text: formatMatchList(match?.from));
    subjectController = TextEditingController(
      text: formatMatchList(match?.subject),
    );
    color.value = entry?.color;
    hasAttachment.value = match?.hasAttachment;
    rulesExpanded.value = match != null;
    nameController.addListener(_onNameChanged);
    _onNameChanged();
  }

  @override
  void onClose() {
    nameController.dispose();
    fromController.dispose();
    subjectController.dispose();
    super.onClose();
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
    error.value = taken ? MailEntryFormError.nameTaken : null;
    canSave.value = name.isNotEmpty && !taken;
  }

  /// The saved entry, or null when saving failed and [error] says why.
  Future<MailEntry?> save() async {
    if (!canSave.value || isSaving.value) return null;
    isSaving.value = true;
    error.value = null;
    final name = nameController.text.trim();
    final match = buildMailMatch(
      from: fromController.text,
      subject: subjectController.text,
      hasAttachment: hasAttachment.value,
      original: entry?.match,
    );
    try {
      final existing = entry;
      return existing == null
          ? await _mailboxes.create(
              kind,
              name,
              color: color.value,
              match: match,
            )
          : await _mailboxes.edit(
              kind,
              existing.id,
              name: name,
              color: color.value,
              match: match,
            );
    } catch (_) {
      error.value = MailEntryFormError.saveFailed;
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}
