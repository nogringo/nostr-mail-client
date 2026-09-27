import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/mail_match_format.dart';
import 'package:nmail_core/utils/string_color.dart';
import 'mailboxes_controller.dart';

enum MailEntryFormError { nameTaken, saveFailed }

class MailEntryFormController extends GetxController {
  final MailEntryKind kind;

  /// The entry being edited, null when creating one.
  final MailEntry? entry;

  MailEntryFormController({required this.kind, this.entry});

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
  final color = RxnString();

  /// A color from outside [palette], kept while another one is selected.
  final customColor = RxnString();
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
    if (_isCustom(entry?.color)) customColor.value = entry?.color;
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

  static bool _isCustom(String? hex) =>
      MailboxesController.parseEntryColor(hex) != null &&
      !palette.containsKey(hex!.toUpperCase());

  /// Where the custom color dialog opens.
  Color get customColorSeed =>
      MailboxesController.parseEntryColor(customColor.value) ??
      MailboxesController.parseEntryColor(color.value) ??
      switch (entry) {
        final entry? => getStringColor(entry.id),
        null => MailboxesController.parseEntryColor(palette.keys.first)!,
      };

  void pickCustomColor(String hex) {
    color.value = hex;
    if (_isCustom(hex)) customColor.value = hex;
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
