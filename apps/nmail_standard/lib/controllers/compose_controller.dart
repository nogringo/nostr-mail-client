import 'dart:convert';

import 'package:enough_mail_plus/enough_mail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';
import 'package:mime/mime.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart' hide Recipient;
import 'package:nostr_mail/nostr_mail.dart' as mail show Recipient;
import 'package:nmail_standard/utils/toast_helper.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../app/routes/app_router.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/compose_attachment.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/models/from_option.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/models/send_mode.dart';
import '../services/contacts_service.dart';
import '../services/nostr_mail_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import '../utils/sender_name_helper.dart';
import 'auth_controller.dart';
import 'settings_controller.dart';

// TODO: allow attachments renaming

const String _defaultBridgeDomain = 'uid.ovh';

class ComposeController extends GetxController {
  static ComposeController get to => Get.find();

  /// Optional source email + mode for reply/forward flows.
  /// Passed by the route builder via GoRouter's `extra`.
  final Email? sourceEmail;
  final ComposeMode? sourceMode;
  final Recipient? initialRecipient;

  /// When set, compose opens as an editor for this already-scheduled email:
  /// its fields are pre-filled and (re)sending cancels the original schedule.
  final ScheduledEmail? editingScheduled;

  ComposeController({
    this.sourceEmail,
    this.sourceMode,
    this.initialRecipient,
    this.editingScheduled,
  });

  bool get isEditingScheduled => editingScheduled != null;

  /// Pre-fills, and reflects edits to, the send time when editing a schedule.
  final Rxn<DateTime> scheduledAt = Rxn<DateTime>();

  final _nostrMailService = Get.find<NostrMailService>();
  final _contactsService = Get.find<ContactsService>();

  final isSending = false.obs;
  final recipients = <Recipient>[].obs;
  final Rxn<FromOption> selectedFrom = Rxn<FromOption>();
  final fromOptions = <FromOption>[].obs;
  final attachments = <ComposeAttachment>[].obs;
  final sendMode = SendMode.normal.obs;

  final showExpandedFields = false.obs;
  final ccRecipients = <Recipient>[].obs;
  final bccRecipients = <Recipient>[].obs;

  late final TextEditingController toController;
  late final TextEditingController ccController;
  late final TextEditingController bccController;
  late final TextEditingController subjectController;
  late final QuillController quillController;
  final FocusNode editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _contactsService.loadContacts();

    final signature = Get.find<SettingsController>().emailSignature.value;

    toController = TextEditingController();
    ccController = TextEditingController();
    bccController = TextEditingController();
    subjectController = TextEditingController();

    // Initialize Quill controller with signature
    if (signature.isEmpty) {
      quillController = QuillController.basic();
    } else {
      final doc = Document()..insert(0, '\n\n$signature');
      quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Load from options
    loadFromOptions();
  }

  @override
  void onReady() {
    super.onReady();
    // Initialize reply/forward async after onInit completes
    if (editingScheduled != null) {
      initFromScheduled(editingScheduled!);
    } else if (sourceEmail != null && sourceMode != null) {
      initFromEmail(sourceEmail!, sourceMode!);
    } else if (initialRecipient != null) {
      recipients.add(initialRecipient!);
      if (initialRecipient!.isLegacy) {
        _autoSelectBridgeForLegacy();
      }
    }
  }

  Future<bool> addRecipient(String input) =>
      _addRecipientToList(input, recipients);
  Future<bool> addCcRecipient(String input) =>
      _addRecipientToList(input, ccRecipients);
  Future<bool> addBccRecipient(String input) =>
      _addRecipientToList(input, bccRecipients);

  Future<bool> _addRecipientToList(String input, RxList<Recipient> list) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;

    // Check if already added (by input)
    if (list.any((r) => r.input == trimmed)) return false;

    // Resolve recipient first to get pubkey
    final resolved = await _resolveRecipient(trimmed);

    // Check if invalid format
    if (resolved == null) return false;

    // Check if already added (by pubkey for nostr recipients)
    if (resolved.type == RecipientType.nostr && resolved.pubkey != null) {
      if (list.any((r) => r.pubkey == resolved.pubkey)) return false;
    }

    // Add recipient
    list.add(resolved);

    // Auto-select bridge if this is a legacy recipient
    if (resolved.isLegacy) {
      await _autoSelectBridgeForLegacy();
    }

    return true;
  }

  void removeRecipient(int index) =>
      _removeRecipientFromList(index, recipients);
  void removeCcRecipient(int index) =>
      _removeRecipientFromList(index, ccRecipients);
  void removeBccRecipient(int index) =>
      _removeRecipientFromList(index, bccRecipients);

  void _removeRecipientFromList(int index, RxList<Recipient> list) {
    if (index >= 0 && index < list.length) {
      final removed = list.removeAt(index);

      // Re-evaluate: if no more legacy recipients, revert to npub@nostr
      if (removed.isLegacy) {
        final hasLegacyRecipients =
            recipients.any((r) => r.isLegacy) ||
            ccRecipients.any((r) => r.isLegacy) ||
            bccRecipients.any((r) => r.isLegacy);

        if (!hasLegacyRecipients) {
          // Revert to npub@nostr if we switched to bridge due to legacy recipients
          // Only if current selection is a bridge
          final currentFrom = selectedFrom.value;
          if (currentFrom != null &&
              (currentFrom.source == FromSource.npubBridge ||
                  currentFrom.source == FromSource.nip05Bridge)) {
            final nostrOption = fromOptions.firstWhereOrNull(
              (o) => o.source == FromSource.npubNostr,
            );
            if (nostrOption != null) {
              selectedFrom.value = nostrOption;
            }
          }
        }
      }
    }
  }

  void addRecipientFromContact(Contact contact) =>
      _addContactToList(contact, recipients);
  void addCcRecipientFromContact(Contact contact) =>
      _addContactToList(contact, ccRecipients);
  void addBccRecipientFromContact(Contact contact) =>
      _addContactToList(contact, bccRecipients);

  void _addContactToList(Contact contact, RxList<Recipient> list) {
    // Check if already added (by pubkey or email)
    if (contact.pubkey != null && contact.pubkey!.isNotEmpty) {
      if (list.any((r) => r.pubkey == contact.pubkey)) return;
    } else if (contact.mailAddress?.email.isNotEmpty == true) {
      if (list.any(
        (r) =>
            r.input.toLowerCase() == contact.mailAddress!.email.toLowerCase(),
      )) {
        return;
      }
    }

    list.add(contact.toRecipient());
  }

  Set<String> get recipientIds => _getIdsFromList(recipients);
  Set<String> get ccRecipientIds => _getIdsFromList(ccRecipients);
  Set<String> get bccRecipientIds => _getIdsFromList(bccRecipients);

  /// Get all recipient identifiers for exclusion in autocomplete
  Set<String> _getIdsFromList(RxList<Recipient> list) {
    final ids = <String>{};
    for (final r in list) {
      if (r.pubkey != null) {
        ids.add(r.pubkey!);
      }
      ids.add(r.input.toLowerCase());
    }
    return ids;
  }

  /// Pick files and add them as attachments
  Future<void> pickAttachments() async {
    final l = AppLocalizations.of(Get.context!);
    try {
      // TODO: limit file size
      final result = await FilePicker.pickFiles(
        dialogTitle: l.composeSelectAttachments,
        allowMultiple: true,
        withData: true, // TODO: do not work on macos
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null && file.bytes != null) {
            final filename = file.name;
            final mimeType = _getMimeType(file.path!);

            attachments.add(
              ComposeAttachment(
                filename: filename,
                data: file.bytes!,
                mimeType: mimeType,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (Get.context != null) {
        ToastHelper.error(Get.context!, l.composePickFilesFailed(e.toString()));
      }
    }
  }

  /// Remove attachment at the specified index
  void removeAttachment(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
    }
  }

  /// Get MIME type based on file extension
  String _getMimeType(String filePath) {
    return lookupMimeType(filePath) ?? 'application/octet-stream';
  }

  Future<Recipient?> _resolveRecipient(String input) async {
    try {
      String? pubkey;

      // Extract bech32 part (before @ if present) and decode
      final bech32Part = input.split('@').first;

      if (input.startsWith('npub1')) {
        pubkey = Nip19.decode(bech32Part);
      } else if (input.startsWith('nprofile1')) {
        pubkey = Nip19.decodeNprofile(bech32Part).pubkey;
      } else if (input.startsWith('naddr1')) {
        pubkey = Nip19.decodeNaddr(bech32Part).pubkey;
      }

      if (pubkey != null) {
        final metadata = await _fetchMetadata(pubkey);
        return Recipient(
          input: input,
          pubkey: pubkey,
          displayName: metadata?.getBestName(),
          picture: metadata?.picture,
          type: RecipientType.nostr,
        );
      }
    } catch (_) {}

    // Check if hex pubkey
    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(input)) {
      try {
        final pubkey = input.toLowerCase();
        final metadata = await _fetchMetadata(pubkey);
        return Recipient(
          input: input,
          pubkey: pubkey,
          displayName: metadata?.getBestName(),
          picture: metadata?.picture,
          type: RecipientType.nostr,
        );
      } catch (_) {}
    }

    // Check if NIP-05
    if (input.contains('@')) {
      try {
        final pubkey = await _resolveNip05(input);
        if (pubkey != null) {
          final metadata = await _fetchMetadata(pubkey);
          return Recipient(
            input: input,
            pubkey: pubkey,
            displayName: metadata?.getBestName(),
            picture: metadata?.picture,
            type: RecipientType.nostr,
          );
        }
      } catch (_) {}
    }

    // Validate legacy email format
    if (GetUtils.isEmail(input)) {
      return Recipient(
        input: input,
        mailAddress: MailAddress(null, input),
        type: RecipientType.legacy,
      );
    }

    // Invalid format
    return null;
  }

  Future<String?> _resolveNip05(String identifier) async {
    final parts = identifier.split('@');
    if (parts.length != 2) return null;

    final name = parts[0];
    final domain = parts[1];
    final url = Uri.https(domain, '/.well-known/nostr.json', {'name': name});

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final names = json['names'] as Map<String, dynamic>?;
      if (names == null || !names.containsKey(name)) return null;

      return names[name] as String;
    } catch (_) {
      return null;
    }
  }

  Future<Metadata?> _fetchMetadata(String pubkey) async {
    try {
      return await Get.find<Ndk>().metadata.loadMetadata(pubkey);
    } catch (_) {
      return null;
    }
  }

  Future<bool> send({
    String? from,
    required String subject,
    required Document document,
    SendMode mode = SendMode.normal,
  }) async {
    if (recipients.isEmpty) return false;

    isSending.value = true;
    try {
      final message = _buildMimeMessage(
        from: from,
        subject: subject,
        document: document,
      );

      await _nostrMailService.client.sendMime(
        message,
        to: _toTransportRecipients(recipients),
        cc: _toTransportRecipients(ccRecipients),
        bcc: _toTransportRecipients(bccRecipients),
        mailFrom: _hasLegacyRecipient ? from : null,
        signRumor: mode != SendMode.normal,
        isPublic: mode == SendMode.public,
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Schedule the email for future delivery at [at] through the Scheduler DVM.
  Future<bool> scheduleSend({
    String? from,
    required String subject,
    required Document document,
    required DateTime at,
    SendMode mode = SendMode.normal,
  }) async {
    if (recipients.isEmpty) return false;

    isSending.value = true;
    try {
      final message = _buildMimeMessage(
        from: from,
        subject: subject,
        document: document,
      );

      await _nostrMailService.client.scheduleMime(
        message,
        to: _toTransportRecipients(recipients),
        cc: _toTransportRecipients(ccRecipients),
        bcc: _toTransportRecipients(bccRecipients),
        mailFrom: _hasLegacyRecipient ? from : null,
        signRumor: mode != SendMode.normal,
        isPublic: mode == SendMode.public,
        at: at,
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      isSending.value = false;
    }
  }

  MimeMessage _buildMimeMessage({
    String? from,
    required String subject,
    required Document document,
  }) {
    final converter = QuillDeltaToHtmlConverter(
      document.toDelta().toJson().cast<Map<String, dynamic>>(),
      ConverterOptions.forEmail(),
    );
    final htmlBody = converter.convert();

    final plainText = DeltaToMarkdown().convert(document.toDelta());

    // With attachments, the root must be multipart/mixed; the text/html
    // alternative pair goes in a nested multipart/alternative part.
    // Otherwise clients like Yandex treat the attachment as just another
    // alternative representation and hide it.
    final hasAttachments = attachments.isNotEmpty;
    final hasHtml = htmlBody.isNotEmpty;
    final MessageBuilder builder;
    final PartBuilder bodyBuilder;
    if (hasAttachments) {
      builder = MessageBuilder.prepareMultipartMixedMessage();
      bodyBuilder = hasHtml
          ? builder.addPart(mediaSubtype: MediaSubtype.multipartAlternative)
          : builder;
    } else {
      builder = MessageBuilder.prepareMultipartAlternativeMessage();
      bodyBuilder = builder;
    }

    if (from != null) {
      final displayName = selectedFrom.value?.displayName;
      builder.from = [MailAddress(displayName, from)];
    }

    builder.to = recipients.map(_toMailAddress).toList();
    if (ccRecipients.isNotEmpty) {
      builder.cc = ccRecipients.map(_toMailAddress).toList();
    }
    if (bccRecipients.isNotEmpty) {
      builder.bcc = bccRecipients.map(_toMailAddress).toList();
    }

    builder.subject = subject;

    bodyBuilder.addTextPlain(plainText);
    if (hasHtml) {
      bodyBuilder.addTextHtml(
        htmlBody,
        transferEncoding: TransferEncoding.base64,
      );
    }

    for (final attachment in attachments) {
      final mediaType = MediaType.fromText(attachment.mimeType);
      builder.addBinary(
        attachment.data,
        mediaType,
        filename: attachment.filename,
      );
    }

    return builder.buildMimeMessage();
  }

  /// nostr recipients become `npub@nostr`; legacy ones keep their email input.
  MailAddress _toMailAddress(Recipient r) {
    if (r.isNostr && r.pubkey != null) {
      final npub = Nip19.encodePubKey(r.pubkey!);
      return MailAddress(r.displayName, '$npub@nostr');
    }
    return MailAddress(r.displayName, r.input);
  }

  bool get _hasLegacyRecipient =>
      [...recipients, ...ccRecipients, ...bccRecipients].any((r) => r.isLegacy);

  List<mail.Recipient> _toTransportRecipients(List<Recipient> list) {
    return list.map((r) {
      if (r.isNostr && r.pubkey != null) {
        return NostrRecipient.fromPubkey(r.pubkey!);
      }
      return SmtpRecipient(r.input);
    }).toList();
  }

  Future<String?> getDefaultFrom() async {
    try {
      final myPubkey = _nostrMailService.getPublicKey();
      if (myPubkey == null) return null;

      final emails = await _nostrMailService.client.getEmails();

      // Check sent emails first
      final sentEmail = emails
          .where((e) => e.senderPubkey == myPubkey)
          .firstOrNull;
      if (sentEmail != null && sentEmail.sender != null) {
        return sentEmail.sender!.encode();
      }

      // Fallback to received emails (use "to" which is my address)
      final receivedEmail = emails
          .where((e) => e.senderPubkey != myPubkey)
          .firstOrNull;
      if (receivedEmail != null) {
        return receivedEmail.mime.to?.firstOrNull?.encode();
      }
    } catch (_) {}

    return null;
  }

  /// Load all available From options
  Future<void> loadFromOptions() async {
    final options = <FromOption>[];
    final authController = Get.find<AuthController>();
    final npub = authController.npub;
    final metadata = authController.userMetadata.value;
    final senderName = getSenderName(metadata);

    if (npub == null) return;

    // 1. Always add npub@nostr
    options.add(
      FromOption(
        mailAddress: MailAddress(senderName, '$npub@nostr'),
        picture: metadata?.picture,
        source: FromSource.npubNostr,
      ),
    );

    // 2. Add user-created identities
    final settings = await _nostrMailService.client.getPrivateSettings();
    final identities = settings?.identities ?? [];

    for (final identity in identities) {
      options.add(
        FromOption(
          mailAddress: identity,
          picture: metadata?.picture,
          source: FromSource.customIdentity,
        ),
      );
    }

    // 3. Add npub@<bridge> for each configured bridge
    List<String> bridges = settings?.bridges ?? [];

    // Fallback to default bridge if none configured
    if (bridges.isEmpty) {
      bridges = [_defaultBridgeDomain];
    }

    for (final bridge in bridges) {
      options.add(
        FromOption(
          mailAddress: MailAddress(senderName, '$npub@$bridge'),
          picture: metadata?.picture,
          source: FromSource.npubBridge,
        ),
      );
    }

    // 3. Check if user's NIP-05 domain is a bridge
    final nip05 = metadata?.nip05;
    if (nip05 != null && nip05.contains('@')) {
      final domain = nip05.split('@').last;
      // Don't add if it's already in bridges list
      if (!bridges.contains(domain)) {
        final isBridge = await _isDomainBridge(domain);
        if (isBridge) {
          options.add(
            FromOption(
              mailAddress: MailAddress(senderName, nip05),
              picture: metadata?.picture,
              source: FromSource.nip05Bridge,
            ),
          );
        }
      }
    }

    fromOptions.value = options;

    // Set default selection
    if (selectedFrom.value == null && options.isNotEmpty) {
      await _selectDefaultFrom(options);
    }
  }

  Future<void> _selectDefaultFrom(List<FromOption> options) async {
    // Try to find last used From address
    final lastFrom = await getDefaultFrom();
    if (lastFrom != null) {
      final match = options.firstWhereOrNull((o) => o.address == lastFrom);
      if (match != null) {
        selectedFrom.value = match;
        return;
      }
    }

    // Fallback to npub@nostr
    selectedFrom.value = options.first;
  }

  /// Automatically select a bridge From address when legacy recipients are present
  Future<void> _autoSelectBridgeForLegacy() async {
    // Check if we have legacy recipients
    final hasLegacyRecipients =
        recipients.any((r) => r.isLegacy) ||
        ccRecipients.any((r) => r.isLegacy) ||
        bccRecipients.any((r) => r.isLegacy);

    if (!hasLegacyRecipients) return;

    // If current selection is already a bridge, keep it
    final currentFrom = selectedFrom.value;
    if (currentFrom != null && currentFrom.source != FromSource.npubNostr) {
      return; // Already using a bridge
    }

    // Find first bridge option (npubBridge or nip05Bridge)
    final bridgeOption = fromOptions.firstWhereOrNull(
      (o) =>
          o.source == FromSource.npubBridge ||
          o.source == FromSource.nip05Bridge,
    );

    if (bridgeOption != null) {
      selectedFrom.value = bridgeOption;
    }
  }

  /// Check if a domain is a bridge by looking up _smtp@domain
  Future<bool> _isDomainBridge(String domain) async {
    final url = Uri.https(domain, '/.well-known/nostr.json', {'name': '_smtp'});

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final names = json['names'] as Map<String, dynamic>?;

      // If _smtp exists and has a pubkey, it's a bridge
      return names != null && names.containsKey('_smtp');
    } catch (_) {
      return false;
    }
  }

  void selectFrom(FromOption option) {
    selectedFrom.value = option;
  }

  Future<void> initFromEmail(Email email, ComposeMode mode) async {
    final myPubkey = _nostrMailService.getPublicKey()!;
    final signature = Get.find<SettingsController>().emailSignature.value;
    final signatureBlock = signature.isEmpty ? '' : '\n\n$signature';

    // Get user's MailAddress from selectedFrom or fallback
    MailAddress fromAddress;
    if (selectedFrom.value != null) {
      fromAddress = selectedFrom.value!.mailAddress;
    } else {
      // Fallback: try to get from email.mime.to (sent by me) or use default
      final myAddress = email.senderPubkey == myPubkey
          ? email.mime.to?.firstOrNull
          : null;
      if (myAddress != null) {
        fromAddress = myAddress;
      } else {
        // Last resort: use npub@nostr
        final npub = Nip19.encodePubKey(myPubkey);
        fromAddress = MailAddress(null, '$npub@nostr');
      }
    }

    final MessageBuilder builder;
    switch (mode) {
      case ComposeMode.reply:
      case ComposeMode.replyAll:
        builder = MessageBuilder.prepareReplyToMessage(
          email.mime,
          fromAddress,
          replyAll: mode == ComposeMode.replyAll,
          quoteOriginalText: false,
        );
      case ComposeMode.forward:
        builder = MessageBuilder.prepareForwardMessage(
          email.mime,
          from: fromAddress,
          quoteMessage: false,
        );
    }

    // Extract and add recipients from builder
    if (builder.to != null) {
      for (final address in builder.to!) {
        await addRecipient(address.email);
      }
    }
    if (builder.cc != null) {
      for (final address in builder.cc!) {
        await addCcRecipient(address.email);
      }
    }

    // Set subject from builder
    subjectController.text = builder.subject ?? '';

    // Build body with quote (manually for Quill)
    final senderDisplay = email.sender?.encode() ?? '';
    final dateFormat = DateFormat('EEE, MMM d, yyyy \'at\' h:mm a');

    switch (mode) {
      case ComposeMode.reply:
      case ComposeMode.replyAll:
        final header =
            '$signatureBlock\n\nOn ${dateFormat.format(email.date)}, $senderDisplay wrote:\n';
        final delta = Delta()..insert(header);
        final quotePrefix = RegExp(r'^(>+ ?)+');
        for (final rawLine in email.body.split('\n')) {
          final line = rawLine.replaceFirst(quotePrefix, '');
          if (line.isNotEmpty) delta.insert(line);
          delta.insert('\n', {Attribute.blockQuote.key: true});
        }
        delta.insert('\n');
        quillController.document = Document.fromDelta(delta);
        quillController.updateSelection(
          const TextSelection.collapsed(offset: 0),
          ChangeSource.local,
        );
      case ComposeMode.forward:
        final bodyText =
            '$signatureBlock\n\n---------- Forwarded message ----------\n'
            'From: $senderDisplay\n'
            'Date: ${dateFormat.format(email.date)}\n'
            'Subject: ${email.subject}\n\n'
            '${email.body}';
        setQuillContent(bodyText);
    }
  }

  /// Pre-fill the composer from an already-scheduled email so the user can
  /// edit it. Recipients, subject and send mode come from the light model
  /// immediately; the full body and attachments are hydrated from the original
  /// MIME, which the package reconstructs from the schedule's stored content.
  Future<void> initFromScheduled(ScheduledEmail scheduled) async {
    scheduledAt.value = scheduled.scheduleAt;
    sendMode.value = scheduled.isPublic ? SendMode.public : SendMode.normal;
    subjectController.text = scheduled.subject;

    final mime = await _nostrMailService.client.getScheduledMime(
      scheduled.packageId,
    );

    final to = mime?.to?.map((a) => a.email) ?? scheduled.to;
    final cc = mime?.cc?.map((a) => a.email) ?? scheduled.cc;
    final bcc = mime?.bcc?.map((a) => a.email) ?? scheduled.bcc;

    for (final address in to) {
      await addRecipient(address);
    }
    for (final address in cc) {
      await addCcRecipient(address);
    }
    for (final address in bcc) {
      await addBccRecipient(address);
    }
    if (cc.isNotEmpty || bcc.isNotEmpty) showExpandedFields.value = true;

    // Set after recipients so the original From wins over any bridge that
    // adding a legacy recipient auto-selected.
    _applyFrom(mime?.fromEmail ?? scheduled.from);

    if (mime != null) {
      _setBodyFromMime(mime);
      _loadAttachmentsFromMime(mime);
    }
  }

  /// Select the From option whose address matches [address], as soon as the
  /// options are loaded (they load asynchronously in [onInit]).
  void _applyFrom(String? address) {
    if (address == null) return;
    void apply(List<FromOption> options) {
      final match = options.firstWhereOrNull((o) => o.address == address);
      if (match != null) selectedFrom.value = match;
    }

    if (fromOptions.isNotEmpty) {
      apply(fromOptions);
    } else {
      once(fromOptions, apply);
    }
  }

  /// The text/plain part is markdown (produced by [DeltaToMarkdown] at compose
  /// time), so round-trip it back into the Quill document.
  void _setBodyFromMime(MimeMessage mime) {
    final markdown = mime.decodeTextPlainPart() ?? '';
    if (markdown.trim().isEmpty) return;
    try {
      final delta = MarkdownToDelta(
        markdownDocument: md.Document(encodeHtml: false),
        softLineBreak: true,
      ).convert(markdown);
      quillController.document = Document.fromDelta(delta);
      quillController.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
    } catch (_) {
      setQuillContent(markdown);
    }
  }

  void _loadAttachmentsFromMime(MimeMessage mime) {
    void walk(MimePart part) {
      final children = part.parts;
      if (children != null && children.isNotEmpty) {
        for (final child in children) {
          walk(child);
        }
        return;
      }
      final filename = part.decodeFileName();
      final disposition = part.getHeaderContentDisposition()?.disposition;
      final isAttachment =
          disposition == ContentDisposition.attachment ||
          (filename != null && filename.isNotEmpty);
      if (!isAttachment || filename == null || filename.isEmpty) return;
      final data = part.decodeContentBinary();
      if (data == null) return;
      attachments.add(
        ComposeAttachment(
          filename: filename,
          data: data,
          mimeType: part.mediaType.text,
        ),
      );
    }

    walk(mime);
  }

  void setQuillContent(String text) {
    final doc = Document()..insert(0, text);
    quillController.document = doc;
    quillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  @override
  void dispose() {
    toController.dispose();
    ccController.dispose();
    bccController.dispose();
    subjectController.dispose();
    quillController.dispose();
    editorFocusNode.dispose();
    editorScrollController.dispose();
    super.dispose();
  }

  void toggleExpandedFields() {
    showExpandedFields.value = !showExpandedFields.value;
  }

  Future<void> handleToSubmit(String value) =>
      _handleSubmit(value, addRecipient, toController);
  Future<void> handleCcSubmit(String value) =>
      _handleSubmit(value, addCcRecipient, ccController);
  Future<void> handleBccSubmit(String value) =>
      _handleSubmit(value, addBccRecipient, bccController);

  Future<void> _handleSubmit(
    String value,
    Future<bool> Function(String) addFunc,
    TextEditingController controller,
  ) async {
    final input = value.trim();
    if (input.isNotEmpty) {
      final added = await addFunc(input);
      if (added) {
        controller.clear();
      } else {
        final l = AppLocalizations.of(Get.context!);
        ToastHelper.error(Get.context!, l.composeInvalidRecipient);
      }
    }
  }

  /// The one send trigger: schedules for later when a send time is set,
  /// otherwise sends immediately. Picking a time only sets [scheduledAt]; it is
  /// this action, from the send button, that actually queues or sends.
  Future<void> firstSend() async {
    if (!await _flushAndValidate()) return;

    final at = scheduledAt.value;
    if (at != null && !at.isAfter(DateTime.now())) {
      final l = AppLocalizations.of(Get.context!);
      ToastHelper.error(Get.context!, l.composeScheduleTimePast);
      return;
    }

    if (!await _cancelEditedOriginal()) return;

    final success = at != null
        ? await scheduleSend(
            from: selectedFrom.value?.address,
            subject: subjectController.text,
            document: quillController.document,
            at: at,
            mode: sendMode.value,
          )
        : await send(
            from: selectedFrom.value?.address,
            subject: subjectController.text,
            document: quillController.document,
            mode: sendMode.value,
          );

    final l = AppLocalizations.of(Get.context!);
    if (success) {
      AppRouter.router.pop();
    } else {
      ToastHelper.error(
        Get.context!,
        at != null ? l.composeScheduleFailed : l.composeSendFailed,
      );
    }
  }

  /// When editing a scheduled email, cancel the original before (re)sending so
  /// the recipient never gets it twice. Cancel first, not after: a failed
  /// resend keeps the user in the editor to retry, whereas a duplicate send is
  /// irreversible. Returns false (after a toast) if the cancel fails.
  Future<bool> _cancelEditedOriginal() async {
    final scheduled = editingScheduled;
    if (scheduled == null || _originalCancelled) return true;
    try {
      await _nostrMailService.client.cancelScheduledEmail(scheduled.packageId);
      _originalCancelled = true;
      return true;
    } catch (_) {
      final l = AppLocalizations.of(Get.context!);
      ToastHelper.error(Get.context!, l.scheduledCancelFailed);
      return false;
    }
  }

  bool _originalCancelled = false;

  /// Flush pending recipient input into chips and check we can send: returns
  /// false (after showing a toast) when a typed recipient is invalid or none
  /// were added. Ensures a From address is selected.
  Future<bool> _flushAndValidate() async {
    if (toController.text.trim().isNotEmpty) {
      await handleToSubmit(toController.text);
      if (toController.text.trim().isNotEmpty) return false;
    }
    if (ccController.text.trim().isNotEmpty) {
      await handleCcSubmit(ccController.text);
      if (ccController.text.trim().isNotEmpty) return false;
    }
    if (bccController.text.trim().isNotEmpty) {
      await handleBccSubmit(bccController.text);
      if (bccController.text.trim().isNotEmpty) return false;
    }

    final l = AppLocalizations.of(Get.context!);
    if (recipients.isEmpty) {
      ToastHelper.error(Get.context!, l.composeAddRecipient);
      return false;
    }

    if (selectedFrom.value == null && fromOptions.isNotEmpty) {
      selectedFrom.value = fromOptions.first;
    }

    return true;
  }
}
