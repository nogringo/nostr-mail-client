import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FirstWhereExt;
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/android_file_saver.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import '../views/contacts/widgets/import_conflict_dialog.dart';

class ContactsController extends ChangeNotifier {
  ContactsController() {
    queryController.addListener(notifyListeners);
    _contactsSubscription = addressBookService.contacts.listen(
      (_) => _ensureSelection(),
    );
    _loadingSubscription = addressBookService.isLoading.listen(
      (_) => notifyListeners(),
    );
    addressBookService.load(sync: true).then((_) => _ensureSelection());
    _checkLaunchCapabilities();
  }

  final addressBookService = Get.find<AddressBookService>();
  final queryController = TextEditingController();
  String? selectedUid;
  String? copiedVCardUid;
  Timer? _copiedVCardTimer;
  late final StreamSubscription<List<AddressBookContact>> _contactsSubscription;
  late final StreamSubscription<bool> _loadingSubscription;

  /// Whether the platform can place a call / send an SMS. Checked once at init
  /// (a `tel:`/`sms:` handler is a device-wide capability, not per-number) so
  /// the phone-row buttons can hide when there is no app to handle them.
  bool canCall = false;
  bool canSms = false;

  String get query => queryController.text;

  bool get isLoading => addressBookService.isLoading.value;

  List<AddressBookContact> get filteredContacts {
    final q = query.trim().toLowerCase();
    final list = addressBookService.contacts.where((contact) {
      if (q.isEmpty) return true;
      final index = contact.index;
      final haystack = [
        index.formattedName,
        ...index.emails,
        ...index.nostrIdentifiers,
        if (index.organization != null) index.organization!,
      ].join('\n').toLowerCase();
      return haystack.contains(q);
    }).toList();
    list.sort((a, b) {
      final byName = a.index.formattedName.toLowerCase().compareTo(
        b.index.formattedName.toLowerCase(),
      );
      if (byName != 0) return byName;
      return b.eventCreatedAt.compareTo(a.eventCreatedAt);
    });
    return list;
  }

  AddressBookContact? get selectedContact {
    final uid = selectedUid;
    if (uid == null) return null;
    return addressBookService.contacts.firstWhereOrNull(
      (contact) => contact.uid == uid,
    );
  }

  Future<void> _checkLaunchCapabilities() async {
    canCall = await canLaunchUrl(Uri(scheme: 'tel', path: '0'));
    canSms = await canLaunchUrl(Uri(scheme: 'sms', path: '0'));
    notifyListeners();
  }

  @override
  void dispose() {
    _copiedVCardTimer?.cancel();
    _contactsSubscription.cancel();
    _loadingSubscription.cancel();
    queryController.dispose();
    super.dispose();
  }

  void select(AddressBookContact contact) {
    selectedUid = contact.uid;
    notifyListeners();
  }

  Future<void> syncContacts() => addressBookService.pull();

  Future<void> retryBroadcasts() => addressBookService.retryBroadcasts();

  Future<void> exportContacts(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final list = addressBookService.contacts;
    if (list.isEmpty) {
      ToastHelper.info(context, l.contactsExportEmpty);
      return;
    }
    try {
      final vcf = list.map((contact) => contact.vCard).join('\r\n');
      final bytes = Uint8List.fromList(utf8.encode(vcf));

      String result;
      if (PlatformHelper.isAndroid) {
        result = await AndroidFileSaver.saveToDownloads(
          fileName: 'contacts.vcf',
          bytes: bytes,
          mimeType: 'text/vcard',
        );
      } else {
        result = await FileSaver.instance.saveFile(
          name: 'contacts',
          bytes: bytes,
          fileExtension: 'vcf',
          mimeType: MimeType.other,
        );
      }
      if (!context.mounted) return;
      ToastHelper.success(context, l.contactsExportSaved(result));
    } catch (error) {
      if (!context.mounted) return;
      ToastHelper.error(context, l.contactsExportFailed(error.toString()));
    }
  }

  Future<void> importContacts(BuildContext context) async {
    final l = AppLocalizations.of(context);
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: l.contactsImport,
        type: FileType.custom,
        allowedExtensions: ['vcf'],
      );
      if (file == null) return;

      final forms = AddressBookVCardMapper.formsFromVCardText(
        utf8.decode(await file.readAsBytes()),
      );
      if (forms.isEmpty) {
        if (!context.mounted) return;
        ToastHelper.info(context, l.contactsImportEmpty);
        return;
      }

      // Pair each imported form with the existing contact it conflicts with
      // (same uid, or a shared normalized email).
      final pending = forms
          .map((form) => (form: form, existing: _findExisting(form)))
          .toList();
      final conflicts = pending.where((entry) => entry.existing != null).length;

      var choice = ImportConflictChoice.mergeAll;
      if (conflicts > 0) {
        if (!context.mounted) return;
        final picked = await ImportConflictDialog.show(context, conflicts);
        if (picked == null || picked == ImportConflictChoice.cancel) return;
        choice = picked;
      }

      var imported = 0;
      var skipped = 0;
      for (final entry in pending) {
        final existing = entry.existing;
        if (existing != null && choice == ImportConflictChoice.skipDuplicates) {
          skipped++;
          continue;
        }
        try {
          if (existing == null) {
            await addressBookService.saveContact(entry.form);
          } else if (choice == ImportConflictChoice.replaceAll) {
            await addressBookService.saveContact(
              entry.form.copyWith(uid: existing.uid),
              existing: existing,
            );
          } else {
            final merged = AddressBookVCardMapper.mergeForms(
              AddressBookVCardMapper.formFromContact(existing),
              entry.form,
            );
            await addressBookService.saveContact(merged, existing: existing);
          }
          imported++;
        } catch (_) {
          skipped++;
        }
      }

      if (!context.mounted) return;
      ToastHelper.success(context, l.contactsImportSummary(imported, skipped));
    } catch (error) {
      if (!context.mounted) return;
      ToastHelper.error(context, l.contactsImportFailed(error.toString()));
    }
  }

  AddressBookContact? _findExisting(AddressBookContactForm form) {
    final list = addressBookService.contacts;
    if (form.uid != null) {
      final byUid = list.firstWhereOrNull((contact) => contact.uid == form.uid);
      if (byUid != null) return byUid;
    }
    final emails = form.emails
        .map((email) => email.trim().toLowerCase())
        .where((email) => email.isNotEmpty)
        .toSet();
    if (emails.isEmpty) return null;
    return list.firstWhereOrNull(
      (contact) => contact.index.emails.any(
        (email) => emails.contains(email.trim().toLowerCase()),
      ),
    );
  }

  Future<void> save(
    AddressBookContactForm form, {
    AddressBookContact? existing,
  }) async {
    final saved = await addressBookService.saveContact(
      form,
      existing: existing,
    );
    selectedUid = saved.uid;
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    final contact = selectedContact;
    if (contact == null) return;
    await deleteContact(contact);
  }

  Future<void> deleteContact(AddressBookContact contact) async {
    await addressBookService.deleteContact(contact);
    if (selectedUid == contact.uid) {
      selectedUid = null;
    }
    _ensureSelection();
  }

  void copyVCard(AddressBookContact contact) {
    Clipboard.setData(ClipboardData(text: contact.vCard));
    copiedVCardUid = contact.uid;
    notifyListeners();
    _copiedVCardTimer?.cancel();
    _copiedVCardTimer = Timer(const Duration(seconds: 2), () {
      if (copiedVCardUid == contact.uid) {
        copiedVCardUid = null;
        notifyListeners();
      }
    });
  }

  void copyText(String value) {
    Clipboard.setData(ClipboardData(text: value));
  }

  void composeToEmail(BuildContext context, String email) {
    context.push(
      AppRoutes.compose,
      extra: {'recipient': Recipient(input: email, type: RecipientType.legacy)},
    );
  }

  /// Opens the platform dialer pre-filled with [phone]. The OS asks before the
  /// call is actually placed, so no in-app confirmation is needed.
  Future<void> callNumber(String phone) {
    return launchUrl(Uri(scheme: 'tel', path: phone));
  }

  /// Opens the platform SMS app pre-filled with [phone] (nothing is sent).
  Future<void> smsNumber(String phone) {
    return launchUrl(Uri(scheme: 'sms', path: phone));
  }

  void composeToPubkey(BuildContext context, String pubkey) {
    context.push(
      AppRoutes.compose,
      extra: {
        'recipient': Recipient(
          input: Nip19.encodePubKey(pubkey),
          pubkey: pubkey,
          type: RecipientType.nostr,
        ),
      },
    );
  }

  AddressBookContactForm formFor(AddressBookContact contact) {
    return AddressBookVCardMapper.formFromContact(contact);
  }

  void _ensureSelection() {
    final current = selectedUid;
    final visible = filteredContacts;
    if (visible.isEmpty) {
      selectedUid = null;
    } else if (current == null ||
        !visible.any((contact) => contact.uid == current)) {
      selectedUid = visible.first.uid;
    }
    // Also the only signal that the contact list changed.
    notifyListeners();
  }
}
