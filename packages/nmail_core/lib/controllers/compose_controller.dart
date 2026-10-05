import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:enough_mail_plus/enough_mail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:get/get.dart' hide FirstWhereExt;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart' hide Recipient;
import 'package:nostr_mail/nostr_mail.dart' as mail show Recipient;
import 'package:nmail_core/utils/is_email.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../app/routes/app_router.dart';
import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/compose_attachment.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/models/from_option.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/models/send_mode.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/browser_image_paste/browser_image_paste.dart';
import 'package:nmail_core/utils/html_image_scan.dart';
import 'package:nmail_core/utils/inline_image_source.dart';
import 'package:nmail_core/utils/media_metadata/strip_media_metadata.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/utils/prepare_email_html.dart';
import 'package:nmail_core/utils/primary_email.dart';
import 'package:nmail_core/utils/reply_quote.dart';
import 'package:nmail_core/utils/sender_name_helper.dart';
import 'auth_controller.dart';
import 'settings_controller.dart';

const Duration _nip05Timeout = Duration(seconds: 5);

final _quoteDateFormat = DateFormat('EEE, MMM d, yyyy \'at\' h:mm a');

/// As a reader writes them: [MailAddress.encode] MIME-encodes a non-ASCII name.
String _readableAddresses(Iterable<MailAddress> addresses) => addresses
    .map((address) {
      final name = address.personalName?.trim();
      return name == null || name.isEmpty
          ? address.email
          : '$name <${address.email}>';
    })
    .join(', ');

enum NostrLookupResult { found, notFound, unreachable }

class ComposeController extends ChangeNotifier implements InlineImageSource {
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
  DateTime? get scheduledAt => _scheduledAt;
  set scheduledAt(DateTime? value) {
    _scheduledAt = value;
    notifyListeners();
  }

  final _nostrMailService = GetIt.I<NostrMailService>();
  final _contactsService = Get.find<ContactsService>();
  final _metadataService = Get.find<MetadataService>();

  bool get isSending => _isSending;
  set isSending(bool value) {
    _isSending = value;
    notifyListeners();
  }

  final recipients = <Recipient>[];

  FromOption? get selectedFrom => _selectedFrom;
  set selectedFrom(FromOption? value) {
    _selectedFrom = value;
    notifyListeners();
  }

  List<FromOption> get fromOptions => _fromOptions;
  set fromOptions(List<FromOption> value) {
    _fromOptions = value;
    if (_pendingFrom case final addresses?) {
      _pendingFrom = null;
      _applyFrom(addresses);
    }
    notifyListeners();
  }

  DateTime? _scheduledAt;
  bool _isSending = false;
  FromOption? _selectedFrom;
  List<FromOption> _fromOptions = [];

  final attachments = <ComposeAttachment>[];

  /// Images of the body and of the quote, keyed by the Content-ID their `cid:`
  /// URL names.
  final inlineImages = <String, ComposeAttachment>{};

  /// The email a reply or forward quotes, appended below the editor's HTML
  /// when sending.
  String? _quotedHtml;

  /// A reply's quote starts folded and can be removed. A forward's stays open:
  /// it is the message being sent.
  bool get quoteIsReply => _quoteIsReply;
  bool _quoteIsReply = false;

  bool quoteExpanded = false;

  /// [_quotedHtml] ready to display, kept because resolving its styles on
  /// every rebuild would cost too much.
  EmailHtml? quotedEmailHtml;

  /// Whether the quote shows the images it would fetch over the network.
  bool showQuotedImages = false;
  SendMode sendMode = SendMode.normal;

  bool showExpandedFields = false;
  final ccRecipients = <Recipient>[];
  final bccRecipients = <Recipient>[];

  bool _isDisposed = false;

  late final TextEditingController toController;
  late final TextEditingController ccController;
  late final TextEditingController bccController;
  late final TextEditingController subjectController;
  late final QuillController quillController;
  final FocusNode editorFocusNode = FocusNode();
  final _recipientFocusNodes = {
    for (final field in RecipientField.values) field: FocusNode(),
  };
  final ScrollController editorScrollController = ScrollController();

  void init() {
    _contactsService.loadContacts();

    final settings = Get.find<SettingsController>();
    final signature = settings.signature(
      AppLocalizations.of(AppRouter.rootContext!),
    );
    showQuotedImages = settings.alwaysLoadImages.value;

    toController = TextEditingController();
    ccController = TextEditingController();
    bccController = TextEditingController();
    subjectController = TextEditingController();

    final editorConfig = QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(onImagePaste: addInlineImage),
    );
    if (signature.isEmpty) {
      quillController = QuillController.basic(config: editorConfig);
    } else {
      final doc = Document()..insert(0, '\n\n$signature');
      quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        config: editorConfig,
      );
    }
    _browserImagePaste = listenToBrowserImagePaste(
      accepts: () => editorFocusNode.hasFocus,
      onImage: _insertPastedImage,
    );

    // Load from options
    loadFromOptions();

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

  Future<bool> _addRecipientToList(String input, List<Recipient> list) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    if (list.any((r) => r.input == trimmed)) return false;

    final parsed = _parseRecipient(trimmed);
    if (parsed == null) {
      if (!trimmed.contains('@')) return false;
      final pubkey = await _resolveNip05(trimmed);
      if (pubkey == null) return false;
      return _addUnique(
        Recipient(input: trimmed, pubkey: pubkey, type: RecipientType.nostr),
        list,
      );
    }

    if (!_addUnique(parsed, list)) return false;

    if (parsed.isLegacy) {
      _trackResolution(_upgradeToNostr(parsed, list));
      _autoSelectBridgeForLegacy();
    }

    return true;
  }

  bool _addUnique(Recipient recipient, List<Recipient> list) {
    final pubkey = recipient.pubkey;
    if (pubkey != null && list.any((r) => r.pubkey == pubkey)) return false;
    list.add(recipient);
    notifyListeners();
    return true;
  }

  /// NIP-05 lookups still running, awaited before sending because they decide
  /// whether a recipient goes through Nostr or SMTP.
  final _pendingResolutions = <Future<void>>{};

  void _trackResolution(Future<void> resolution) {
    _pendingResolutions.add(resolution);
    resolution.whenComplete(() => _pendingResolutions.remove(resolution));
  }

  Future<void> _upgradeToNostr(Recipient legacy, List<Recipient> list) async {
    final pubkey = await _resolveNip05(legacy.input);
    if (pubkey == null) return;
    _promoteToNostr(list, legacy, pubkey);
  }

  /// Keeps the legacy address so the user can switch back to SMTP.
  void _promoteToNostr(
    List<Recipient> list,
    Recipient legacy,
    String pubkey,
  ) {
    final index = list.indexOf(legacy);
    if (index == -1) return;

    if (list.any((r) => r.pubkey == pubkey)) {
      list.removeAt(index);
    } else {
      list[index] = Recipient(
        input: legacy.input,
        pubkey: pubkey,
        mailAddress: legacy.mailAddress,
        type: RecipientType.nostr,
      );
    }
    _revertBridgeIfNoLegacy();
    notifyListeners();
  }

  List<Recipient> recipientsOf(RecipientField field) => switch (field) {
    RecipientField.to => recipients,
    RecipientField.cc => ccRecipients,
    RecipientField.bcc => bccRecipients,
  };

  TextEditingController textControllerOf(RecipientField field) =>
      switch (field) {
        RecipientField.to => toController,
        RecipientField.cc => ccController,
        RecipientField.bcc => bccController,
      };

  FocusNode focusNodeOf(RecipientField field) => _recipientFocusNodes[field]!;

  void removeRecipientFrom(RecipientField field, Recipient recipient) {
    final list = recipientsOf(field);
    _removeRecipientFromList(list.indexOf(recipient), list);
  }

  void moveRecipient(
    Recipient recipient,
    RecipientField from,
    RecipientField to,
  ) {
    if (!recipientsOf(from).remove(recipient)) return;
    final target = recipientsOf(to);
    final pubkey = recipient.pubkey;
    final alreadyThere = target.any(
      (r) =>
          r.input.toLowerCase() == recipient.input.toLowerCase() ||
          (pubkey != null && r.pubkey == pubkey),
    );
    if (alreadyThere) {
      if (recipient.isLegacy) _revertBridgeIfNoLegacy();
    } else {
      target.add(recipient);
    }
    if (to != RecipientField.to) showExpandedFields = true;
    notifyListeners();
  }

  /// Turns the chip back into the text the user typed.
  void editRecipient(RecipientField field, Recipient recipient) {
    removeRecipientFrom(field, recipient);
    textControllerOf(field).value = TextEditingValue(
      text: recipient.input,
      selection: TextSelection.collapsed(offset: recipient.input.length),
    );
  }

  void sendViaSmtp(RecipientField field, Recipient recipient, String address) {
    final list = recipientsOf(field);
    final index = list.indexOf(recipient);
    if (index == -1) return;

    list[index] = Recipient(
      input: address,
      mailAddress: recipient.smtpAddress == address
          ? recipient.mailAddress
          : MailAddress(null, address),
      type: RecipientType.legacy,
    );
    _autoSelectBridgeForLegacy();
    notifyListeners();
  }

  Future<NostrLookupResult> sendViaNostr(
    RecipientField field,
    Recipient recipient,
  ) async {
    final String? pubkey;
    try {
      pubkey = await _lookupNip05(recipient.input);
    } catch (_) {
      return NostrLookupResult.unreachable;
    }
    if (pubkey == null) return NostrLookupResult.notFound;

    _promoteToNostr(recipientsOf(field), recipient, pubkey);
    return NostrLookupResult.found;
  }

  void removeRecipient(int index) =>
      _removeRecipientFromList(index, recipients);
  void removeCcRecipient(int index) =>
      _removeRecipientFromList(index, ccRecipients);
  void removeBccRecipient(int index) =>
      _removeRecipientFromList(index, bccRecipients);

  void _removeRecipientFromList(int index, List<Recipient> list) {
    if (index < 0 || index >= list.length) return;
    if (list.removeAt(index).isLegacy) _revertBridgeIfNoLegacy();
    notifyListeners();
  }

  /// The bridge picked by [_autoSelectBridgeForLegacy], reverted once no
  /// legacy recipient needs it. A From chosen by the user is never reverted.
  FromOption? _autoSelectedBridge;

  void _revertBridgeIfNoLegacy() {
    final hasLegacyRecipients =
        recipients.any((r) => r.isLegacy) ||
        ccRecipients.any((r) => r.isLegacy) ||
        bccRecipients.any((r) => r.isLegacy);
    if (hasLegacyRecipients) return;

    final bridge = _autoSelectedBridge;
    if (bridge == null || selectedFrom != bridge) return;
    _autoSelectedBridge = null;

    final nostrOption = fromOptions.firstWhereOrNull(
      (o) => o.source == FromSource.npubNostr,
    );
    if (nostrOption != null) {
      selectedFrom = nostrOption;
    }
  }

  void addRecipientFromContact(Contact contact) =>
      _addContactToList(contact, recipients);
  void addCcRecipientFromContact(Contact contact) =>
      _addContactToList(contact, ccRecipients);
  void addBccRecipientFromContact(Contact contact) =>
      _addContactToList(contact, bccRecipients);

  void _addContactToList(Contact contact, List<Recipient> list) {
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

    final recipient = contact.toRecipient();
    list.add(recipient);

    if (recipient.isLegacy) {
      _autoSelectBridgeForLegacy();
    }
    notifyListeners();
  }

  Set<String> get recipientIds => _getIdsFromList(recipients);
  Set<String> get ccRecipientIds => _getIdsFromList(ccRecipients);
  Set<String> get bccRecipientIds => _getIdsFromList(bccRecipients);

  /// Get all recipient identifiers for exclusion in autocomplete
  Set<String> _getIdsFromList(List<Recipient> list) {
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
    final l = AppLocalizations.of(AppRouter.rootContext!);
    try {
      // TODO: limit file size
      final files = await FilePicker.pickFiles(
        dialogTitle: l.composeSelectAttachments,
      );

      for (final file in files) {
        attachments.add(
          ComposeAttachment(
            filename: file.name,
            data: stripMediaMetadata(await file.readAsBytes()),
            mimeType: _getMimeType(file.name),
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      if (AppRouter.rootContext != null) {
        ToastHelper.error(
          AppRouter.rootContext!,
          l.composePickFilesFailed(e.toString()),
        );
      }
    }
  }

  /// Remove attachment at the specified index
  void removeAttachment(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
      notifyListeners();
    }
  }

  void renameAttachment(int index, String filename) {
    if (index < 0 || index >= attachments.length) return;
    final attachment = attachments[index];
    attachments[index] = ComposeAttachment(
      filename: filename,
      data: attachment.data,
      mimeType: attachment.mimeType,
    );
    notifyListeners();
  }

  /// Returns the `cid:` URL the body embeds [bytes] under.
  Future<String> addInlineImage(Uint8List bytes) async {
    final data = stripMediaMetadata(bytes);
    final mimeType = lookupMimeType('', headerBytes: data) ?? 'image/png';
    final contentId = _newContentId();
    inlineImages[contentId] = ComposeAttachment(
      filename: 'image.${extensionFromMime(mimeType) ?? 'png'}',
      data: data,
      mimeType: mimeType,
    );
    return 'cid:$contentId';
  }

  StreamSubscription<void>? _browserImagePaste;

  Future<void> _insertPastedImage(Uint8List bytes) async {
    final url = await addInlineImage(bytes);
    final selection = quillController.selection;
    quillController.replaceText(
      selection.start,
      selection.end - selection.start,
      BlockEmbed.image(url),
      TextSelection.collapsed(offset: selection.start + 1),
    );
  }

  Future<void> pasteFromClipboard() async {
    try {
      final image = await readBrowserClipboardImage();
      if (image != null) return await _insertPastedImage(image);
      await quillController.clipboardPaste();
    } catch (_) {
      final l = AppLocalizations.of(AppRouter.rootContext!);
      ToastHelper.error(AppRouter.rootContext!, l.composePasteFailed);
    }
  }

  String _newContentId() {
    final random = Random.secure();
    final hex = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '$hex@nmail';
  }

  /// Get MIME type based on file extension
  String _getMimeType(String filePath) {
    return lookupMimeType(filePath) ?? 'application/octet-stream';
  }

  /// Recognizes [input] without any network access. Profiles are read by the
  /// chips, and a legacy address may later be upgraded through NIP-05.
  Recipient? _parseRecipient(String input) {
    try {
      final bech32Part = input.split('@').first;
      final String? pubkey;
      if (input.startsWith('npub1')) {
        pubkey = Nip19.decode(bech32Part);
      } else if (input.startsWith('nprofile1')) {
        pubkey = Nip19.decodeNprofile(bech32Part).pubkey;
      } else if (input.startsWith('naddr1')) {
        pubkey = Nip19.decodeNaddr(bech32Part).pubkey;
      } else {
        pubkey = null;
      }
      if (pubkey != null) {
        return Recipient(
          input: input,
          pubkey: pubkey,
          type: RecipientType.nostr,
        );
      }
    } catch (_) {}

    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(input)) {
      return Recipient(
        input: input,
        pubkey: input.toLowerCase(),
        type: RecipientType.nostr,
      );
    }

    if (isEmail(input)) {
      return Recipient(
        input: input,
        mailAddress: MailAddress(null, input),
        type: RecipientType.legacy,
      );
    }

    return null;
  }

  Future<String?> _resolveNip05(String identifier) async {
    try {
      return await _lookupNip05(identifier);
    } catch (_) {
      return null;
    }
  }

  /// Null when the domain answers without this name. Throws when the domain
  /// cannot be reached or answers something that is not a NIP-05 document.
  Future<String?> _lookupNip05(String identifier) async {
    final parts = identifier.split('@');
    if (parts.length != 2) return null;

    final name = parts[0];
    final domain = parts[1];
    final url = Uri.https(domain, '/.well-known/nostr.json', {'name': name});

    final response = await http.get(url).timeout(_nip05Timeout);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', url);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final names = json['names'] as Map<String, dynamic>?;
    if (names == null || !names.containsKey(name)) return null;

    return names[name] as String;
  }

  Future<bool> send({
    String? from,
    required String subject,
    required Document document,
    SendMode mode = SendMode.normal,
  }) async {
    if (recipients.isEmpty) return false;

    isSending = true;
    try {
      final message = buildMimeMessage(
        from: from,
        subject: subject,
        document: document,
      );

      await _nostrMailService.client.sendMime(
        message,
        to: _toTransportRecipients(recipients),
        cc: _toTransportRecipients(ccRecipients),
        bcc: _toTransportRecipients(bccRecipients),
        signRumor: mode != SendMode.normal,
        isPublic: mode == SendMode.public,
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      isSending = false;
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

    isSending = true;
    try {
      final message = buildMimeMessage(
        from: from,
        subject: subject,
        document: document,
      );

      await _nostrMailService.client.scheduleMime(
        message,
        to: _toTransportRecipients(recipients),
        cc: _toTransportRecipients(ccRecipients),
        bcc: _toTransportRecipients(bccRecipients),
        signRumor: mode != SendMode.normal,
        isPublic: mode == SendMode.public,
        at: at,
      );

      return true;
    } catch (e) {
      return false;
    } finally {
      isSending = false;
    }
  }

  @visibleForTesting
  MimeMessage buildMimeMessage({
    String? from,
    required String subject,
    required Document document,
  }) {
    final delta = document.toDelta();
    final converterOptions = ConverterOptions.forEmail();
    converterOptions.sanitizerOptions.urlSanitizer = (url) =>
        contentIdFromUrl(url) != null ? url : null;
    final converter = QuillDeltaToHtmlConverter(
      delta.toJson().cast<Map<String, dynamic>>(),
      converterOptions,
    );
    final htmlBody = appendQuote(converter.convert(), _quotedHtml);

    final plainText = htmlToText(htmlBody);

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
      final displayName = selectedFrom?.displayName;
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
      final bodyImages = _inlineImagesIn(delta);
      final htmlBuilder = bodyImages.isEmpty
          ? bodyBuilder
          : bodyBuilder.addPart(mediaSubtype: MediaSubtype.multipartRelated);
      htmlBuilder.addTextHtml(
        htmlBody,
        transferEncoding: TransferEncoding.base64,
      );
      for (final MapEntry(key: contentId, value: image) in bodyImages) {
        htmlBuilder
            .addBinary(
              image.data,
              MediaType.fromText(image.mimeType),
              disposition: ContentDispositionHeader.from(
                ContentDisposition.inline,
                filename: image.filename,
                size: image.size,
              ),
            )
            .setHeader('Content-ID', '<$contentId>');
      }
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

  /// Images deleted from the body are left out.
  List<MapEntry<String, ComposeAttachment>> _inlineImagesIn(Delta delta) {
    final contentIds = {
      for (final op in delta.toList())
        if (op.data case {'image': final String url}) contentIdFromUrl(url),
      if (_quotedHtml case final quote?) ...htmlInlineImageCids(quote),
    };
    return inlineImages.entries
        .where((entry) => contentIds.contains(entry.key))
        .toList();
  }

  /// nostr recipients become `npub@nostr`; legacy ones keep their email input.
  /// The name comes from the profile: [Recipient.displayName] can be private.
  MailAddress _toMailAddress(Recipient r) {
    final pubkey = r.pubkey;
    if (r.isNostr && pubkey != null) {
      final npub = Nip19.encodePubKey(pubkey);
      final name = _metadataService.of(pubkey).value?.realName;
      return MailAddress(name, '$npub@nostr');
    }
    return MailAddress(null, r.input);
  }

  List<mail.Recipient> _toTransportRecipients(List<Recipient> list) {
    return list.map((r) {
      if (r.isNostr && r.pubkey != null) {
        return NostrRecipient.fromPubkey(r.pubkey!);
      }
      return SmtpRecipient(r.input);
    }).toList();
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
    final settings = await _nostrMailService.client.getLocalPrivateSettings();
    _primaryEmail = primaryEmailAddress(npub: npub, settings: settings);
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
      bridges = [NostrConfig.recommendedBridges.first];
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

    fromOptions = options;
    selectedFrom ??= options.first;
    _autoSelectBridgeForLegacy();

    // 4. Check if user's NIP-05 domain is a bridge
    final nip05 = metadata?.nip05;
    if (nip05 != null && nip05.contains('@')) {
      final domain = nip05.split('@').last;
      if (!bridges.contains(domain) && await _isDomainBridge(domain)) {
        final option = FromOption(
          mailAddress: MailAddress(senderName, nip05),
          picture: metadata?.picture,
          source: FromSource.nip05Bridge,
        );
        fromOptions = [...fromOptions, option];
      }
    }
  }

  /// The address the account menu copies, the From for legacy recipients.
  String? _primaryEmail;

  void _autoSelectBridgeForLegacy() {
    // Check if we have legacy recipients
    final hasLegacyRecipients =
        recipients.any((r) => r.isLegacy) ||
        ccRecipients.any((r) => r.isLegacy) ||
        bccRecipients.any((r) => r.isLegacy);

    if (!hasLegacyRecipients) return;

    // If current selection is already a bridge, keep it
    final currentFrom = selectedFrom;
    if (currentFrom != null && currentFrom.source != FromSource.npubNostr) {
      return; // Already using a bridge
    }

    final primaryOption = fromOptions.firstWhereOrNull(
      (o) => o.address == _primaryEmail,
    );

    if (primaryOption != null) {
      selectedFrom = primaryOption;
      _autoSelectedBridge = primaryOption;
    }
  }

  /// Check if a domain is a bridge by looking up _smtp@domain
  Future<bool> _isDomainBridge(String domain) async {
    final url = Uri.https(domain, '/.well-known/nostr.json', {'name': '_smtp'});

    try {
      final response = await http.get(url).timeout(_nip05Timeout);
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
    selectedFrom = option;
    _autoSelectedBridge = null;
  }

  void initFromEmail(Email email, ComposeMode mode) {
    final myPubkey = _nostrMailService.getPublicKey()!;

    // Get user's MailAddress from selectedFrom or fallback
    MailAddress fromAddress;
    if (selectedFrom != null) {
      fromAddress = selectedFrom!.mailAddress;
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

    // Set subject from builder
    subjectController.text = builder.subject ?? '';

    _quotedParts = switch (mode) {
      ComposeMode.reply || ComposeMode.replyAll => quoteReply(email),
      ComposeMode.forward => quoteForward(email),
    };

    addReplyRecipients(
      email,
      to: builder.to ?? const [],
      cc: builder.cc ?? const [],
    );
    if (mode != ComposeMode.forward) applyReplyFrom(email);
  }

  /// Replies from the address [email] reached, or was sent from when it is
  /// the user's own.
  @visibleForTesting
  void applyReplyFrom(Email email) {
    final mime = email.mime;
    // npub@nostr is the default already, and must not replace the bridge a
    // legacy recipient selected.
    _applyFrom([
      for (final address in [...?mime.from, ...?mime.to, ...?mime.cc])
        if (!address.email.endsWith('@nostr')) address.email,
    ]);
  }

  /// Awaited before sending, so a reply or forward never goes out incomplete.
  Future<void>? _quotedParts;

  /// The load of each image the quote shows, keyed by Content-ID.
  final _inlineImageLoads = <String, Future<Uint8List?>>{};

  /// Quotes [email] below the editor and loads the images it shows.
  @visibleForTesting
  Future<void> quoteReply(Email email) => _quote(
    email,
    header: [
      'On ${_quoteDateFormat.format(email.date)}, '
          '${_readableAddresses([?email.sender])} wrote:',
    ],
    asReply: true,
  );

  /// Quotes [email] below the editor and loads the images and attachments it
  /// carries.
  @visibleForTesting
  Future<void> quoteForward(Email email) => _quote(
    email,
    header: [
      '---------- Forwarded message ----------',
      'From: ${_readableAddresses([?email.sender])}',
      'Date: ${_quoteDateFormat.format(email.date)}',
      'Subject: ${email.subject ?? ''}',
      if (email.mime.to case final to? when to.isNotEmpty)
        'To: ${_readableAddresses(to)}',
      if (email.mime.cc case final cc? when cc.isNotEmpty)
        'Cc: ${_readableAddresses(cc)}',
    ],
    asReply: false,
  );

  Future<void> _quote(
    Email email, {
    required List<String> header,
    required bool asReply,
  }) {
    final html = quoteHtml(email, header: header, asReply: asReply);
    _quotedHtml = html;
    _quoteIsReply = asReply;
    _prepareQuote();
    return _loadQuotedParts(
      email,
      htmlInlineImageCids(html),
      withAttachments: !asReply,
    );
  }

  void toggleQuote() {
    quoteExpanded = !quoteExpanded;
    notifyListeners();
  }

  void removeQuote() {
    _quotedHtml = null;
    _quotedParts = null;
    _prepareQuote();
  }

  void loadQuotedImages() {
    showQuotedImages = true;
    _prepareQuote();
  }

  void _prepareQuote() {
    final html = _quotedHtml;
    quotedEmailHtml = html == null
        ? null
        : prepareEmailHtml(html, allowRemoteImages: showQuotedImages);
    notifyListeners();
  }

  @override
  Uint8List? resolvedInlineImage(String contentId) =>
      inlineImages[contentId]?.data;

  @override
  Future<Uint8List?> inlineImageBytes(String contentId) =>
      _inlineImageLoads[contentId] ??
      Future.value(resolvedInlineImage(contentId));

  /// Loads the images the quote shows, then, [withAttachments], every other
  /// attachment of [email].
  Future<void> _loadQuotedParts(
    Email email,
    Set<String> contentIds, {
    required bool withAttachments,
  }) async {
    // One at a time: a cache miss makes getAttachmentBytes download and
    // decrypt the whole message, and nothing dedupes that work.
    Future<Uint8List?> previous = Future.value();
    for (final contentId in contentIds) {
      final load = previous.then((_) => _loadInlineImage(email, contentId));
      _inlineImageLoads[contentId] = load;
      previous = load;
    }
    final images = await Future.wait([
      for (final contentId in contentIds) _inlineImageLoads[contentId]!,
    ]);
    var complete = !images.contains(null);

    for (final ref
        in withAttachments ? email.attachmentRefs : const <AttachmentRef>[]) {
      if (_isDisposed) return;
      if (contentIds.contains(normalizeContentId(ref.contentId))) continue;
      final bytes = await _attachmentBytes(email, ref);
      if (bytes == null) {
        complete = false;
        continue;
      }
      attachments.add(
        ComposeAttachment(
          filename: ref.filename ?? 'attachment',
          data: bytes,
          mimeType: ref.contentType,
        ),
      );
      notifyListeners();
    }

    if (!complete && !_isDisposed && _quotedHtml != null) {
      final l = AppLocalizations.of(AppRouter.rootContext!);
      ToastHelper.error(AppRouter.rootContext!, l.composeForwardPartsFailed);
    }
  }

  /// Null when the image cannot be recovered, never an error, which would
  /// break the chain of loads behind it.
  Future<Uint8List?> _loadInlineImage(Email email, String contentId) async {
    if (_isDisposed) return null;
    try {
      final ref = inlineImageRef(email.attachmentRefs, contentId);
      final bytes =
          inlineImageFromMime(email.mime, contentId) ??
          (ref == null
              ? null
              : await _nostrMailService.client.getAttachmentBytes(email, ref));
      if (bytes != null) {
        inlineImages[contentId] = ComposeAttachment(
          filename: ref?.filename ?? 'image',
          data: bytes,
          mimeType:
              ref?.contentType ??
              lookupMimeType('', headerBytes: bytes) ??
              'image/png',
        );
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _attachmentBytes(Email email, AttachmentRef ref) async {
    try {
      return await _nostrMailService.client.getAttachmentBytes(email, ref);
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  void addReplyRecipients(
    Email email, {
    required List<MailAddress> to,
    required List<MailAddress> cc,
  }) {
    final isFromNostr =
        !email.isBridged &&
        email.senderPubkey != _nostrMailService.getPublicKey();
    final nostrSenderAddresses = isFromNostr
        ? {
            for (final address in [...?email.mime.from, ?email.sender])
              address.email.toLowerCase(),
          }
        : const <String>{};
    for (final address in to) {
      _addReplyRecipient(address, recipients, email, nostrSenderAddresses);
    }
    for (final address in cc) {
      _addReplyRecipient(address, ccRecipients, email, nostrSenderAddresses);
    }
    _autoSelectBridgeForLegacy();
  }

  /// Keeps the transport of the original email: a plain address stays SMTP,
  /// and the sender of an email that came through Nostr stays its pubkey.
  void _addReplyRecipient(
    MailAddress address,
    List<Recipient> list,
    Email email,
    Set<String> nostrSenderAddresses,
  ) {
    final input = address.email.trim();
    if (list.any((r) => r.input == input)) return;

    if (nostrSenderAddresses.contains(input.toLowerCase())) {
      _addUnique(
        Recipient(
          input: input,
          pubkey: email.senderPubkey,
          mailAddress: MailAddress(null, input),
          type: RecipientType.nostr,
        ),
        list,
      );
      return;
    }

    final parsed = _parseRecipient(input);
    if (parsed != null) _addUnique(parsed, list);
  }

  /// Pre-fill the composer from an already-scheduled email so the user can
  /// edit it. Recipients, subject and send mode come from the light model
  /// immediately; the full body and attachments are hydrated from the original
  /// MIME, which the package reconstructs from the schedule's stored content.
  Future<void> initFromScheduled(ScheduledEmail scheduled) async {
    scheduledAt = scheduled.scheduleAt;
    sendMode = scheduled.isPublic ? SendMode.public : SendMode.normal;
    subjectController.text = scheduled.subject;

    final mime = await _nostrMailService.client.getScheduledMime(
      scheduled.packageId,
    );
    if (_isDisposed) return;

    final to = mime?.to?.map((a) => a.email) ?? scheduled.to;
    final cc = mime?.cc?.map((a) => a.email) ?? scheduled.cc;
    final bcc = mime?.bcc?.map((a) => a.email) ?? scheduled.bcc;

    for (final address in to) {
      addRecipient(address);
    }
    for (final address in cc) {
      addCcRecipient(address);
    }
    for (final address in bcc) {
      addBccRecipient(address);
    }
    if (cc.isNotEmpty || bcc.isNotEmpty) showExpandedFields = true;

    // Set after recipients so the original From wins over any bridge that
    // adding a legacy recipient auto-selected.
    _applyFrom([?(mime?.fromEmail ?? scheduled.from)]);

    if (mime != null) {
      _loadAttachmentsFromMime(mime);
      _setBodyFromMime(mime);
    }
    notifyListeners();
  }

  /// Select the From option of the first of [addresses] that has one, as soon
  /// as the options are loaded (they load asynchronously in [init]).
  void _applyFrom(List<String> addresses) {
    if (addresses.isEmpty) return;
    if (fromOptions.isEmpty) {
      _pendingFrom = addresses;
      return;
    }
    final match = addresses
        .map(
          (address) => fromOptions.firstWhereOrNull(
            (o) => o.address.toLowerCase() == address.toLowerCase(),
          ),
        )
        .nonNulls
        .firstOrNull;
    if (match == null) return;
    selectedFrom = match;
    _autoSelectedBridge = null;
  }

  /// The addresses [_applyFrom] got before the From options loaded.
  List<String>? _pendingFrom;

  /// The HTML part is the source of truth, as in other rich-text clients.
  void _setBodyFromMime(MimeMessage mime) {
    final html = mime.decodeTextHtmlPart() ?? '';
    if (html.trim().isEmpty) {
      final text = mime.decodeTextPlainPart() ?? '';
      if (text.trim().isNotEmpty) setQuillContent(text);
      return;
    }
    final (:body, :quote, :quoteIsReply) = splitQuote(html);
    if (quote != null) {
      _quotedHtml = quote;
      _quoteIsReply = quoteIsReply;
      _prepareQuote();
    }
    quillController.document = Document.fromDelta(HtmlToDelta().convert(body));
    quillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
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
      final contentId = normalizeContentId(part.getHeaderValue('content-id'));
      if (contentId != null && disposition != ContentDisposition.attachment) {
        final data = part.decodeContentBinary();
        if (data == null || data.isEmpty) return;
        inlineImages[contentId] = ComposeAttachment(
          filename: filename ?? 'image',
          data: data,
          mimeType: part.mediaType.text,
        );
        return;
      }
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
    final doc = Document()..insert(0, normalizeLineBreaks(text));
    quillController.document = doc;
    quillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  /// Lookups, loads and sends outlive the page that started them.
  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _browserImagePaste?.cancel();
    toController.dispose();
    ccController.dispose();
    bccController.dispose();
    subjectController.dispose();
    quillController.dispose();
    editorFocusNode.dispose();
    for (final focusNode in _recipientFocusNodes.values) {
      focusNode.dispose();
    }
    editorScrollController.dispose();
    super.dispose();
  }

  void toggleExpandedFields() {
    showExpandedFields = !showExpandedFields;
    notifyListeners();
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
      if (_isDisposed) return;
      if (added) {
        controller.clear();
      } else {
        final l = AppLocalizations.of(AppRouter.rootContext!);
        ToastHelper.error(AppRouter.rootContext!, l.composeInvalidRecipient);
      }
    }
  }

  /// The one send trigger: schedules for later when a send time is set,
  /// otherwise sends immediately. Picking a time only sets [scheduledAt]; it is
  /// this action, from the send button, that actually queues or sends.
  Future<void> firstSend() async {
    if (!await _flushAndValidate()) return;

    final at = scheduledAt;
    if (at != null && !at.isAfter(DateTime.now())) {
      final l = AppLocalizations.of(AppRouter.rootContext!);
      ToastHelper.error(AppRouter.rootContext!, l.composeScheduleTimePast);
      return;
    }

    if (!await _cancelEditedOriginal()) return;

    final success = at != null
        ? await scheduleSend(
            from: selectedFrom?.address,
            subject: subjectController.text,
            document: quillController.document,
            at: at,
            mode: sendMode,
          )
        : await send(
            from: selectedFrom?.address,
            subject: subjectController.text,
            document: quillController.document,
            mode: sendMode,
          );

    final l = AppLocalizations.of(AppRouter.rootContext!);
    if (success) {
      AppRouter.router.pop();
    } else {
      ToastHelper.error(
        AppRouter.rootContext!,
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
      final l = AppLocalizations.of(AppRouter.rootContext!);
      ToastHelper.error(AppRouter.rootContext!, l.scheduledCancelFailed);
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

    final pending = [..._pendingResolutions, ?_quotedParts];
    if (pending.isNotEmpty) {
      isSending = true;
      await Future.wait(pending);
      isSending = false;
    }

    final l = AppLocalizations.of(AppRouter.rootContext!);
    if (recipients.isEmpty) {
      ToastHelper.error(AppRouter.rootContext!, l.composeAddRecipient);
      return false;
    }

    if (selectedFrom == null && fromOptions.isNotEmpty) {
      selectedFrom = fromOptions.first;
    }

    return true;
  }
}
