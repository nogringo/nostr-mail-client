import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_mail_plus/enough_mail.dart' show MailAddress;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/get_mime_type.dart';
import 'package:nmail_core/utils/inline_image_source.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:nmail_core/utils/prepare_email_html.dart';
import 'package:nmail_core/utils/run_sender_verdict.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:nmail_core/views/email/widgets/email_source_dialog.dart';
import 'package:nmail_core/views/email/widgets/image_viewer_page.dart';
import 'package:nmail_core/views/email/widgets/nip59_events_dialog.dart';
import 'package:nmail_core/views/mailboxes/widgets/show_move_to_picker.dart';
import 'package:nmail_core/views/mailboxes/widgets/show_tags_picker.dart';
import 'package:nmail_core/views/shared/window_caption_inset.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:nmail_core/services/android_file_saver.dart';
import 'package:nmail_core/utils/platform_helper.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class EmailController extends ChangeNotifier implements InlineImageSource {
  static EmailController get to => GetIt.I<EmailController>();

  /// Nostr event reference this controller renders.
  ///
  /// Can be a 64-char hex event id, a note, or a nevent. A nevent can carry
  /// relay hints from push notifications and share links.
  final String eventReference;

  /// Mailbox the email is being viewed from. Null when reached via the
  /// `/:nostrId` share-link dispatcher (no mailbox context). Source of
  /// truth for mailbox-dependent UI (restore button, mark-as-read on
  /// open, destructive vs trash semantics).
  final Mailbox? mailbox;

  Email? email;

  /// The row of [email], for the folder and tags the full message lacks.
  EmailSummary? summary;
  bool isLoading = true;
  bool showRecipients = false;
  String? rawContent;
  bool isLoadingRawContent = false;
  EmailHtml? emailHtml;
  bool _isDisposed = false;

  late bool _showImages;

  /// Inline images keyed by Content-ID. A null value marks one that cannot be
  /// resolved, so it is not looked up again.
  final Map<String, Uint8List?> _inlineImages = {};
  final Map<String, Future<Uint8List?>> _inlineImageLoads = {};
  Future<void> _inlineImageQueue = Future.value();

  final Map<String, Future<Uint8List?>> _thumbnailLoads = {};

  EmailController({required this.eventReference, this.mailbox}) {
    _showImages = Get.find<SettingsController>().alwaysLoadImages.value;
    loadEmail();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool get showImages => _showImages;

  set showImages(bool value) {
    if (_showImages == value) return;
    _showImages = value;
    _buildEmailHtml();
  }

  void toggleRecipients() {
    showRecipients = !showRecipients;
    notifyListeners();
  }

  void loadImages() {
    showImages = true;
    notifyListeners();
  }

  /// Resolving the stylesheet is too costly to repeat on every rebuild, and it
  /// depends on [showImages] because blocked images also cover CSS backgrounds.
  void _buildEmailHtml() {
    final html = email?.htmlBody;
    emailHtml = html == null || html.isEmpty
        ? null
        : prepareEmailHtml(html, allowRemoteImages: _showImages);
  }

  @override
  Uint8List? resolvedInlineImage(String contentId) => _inlineImages[contentId];

  @override
  Future<Uint8List?> inlineImageBytes(String contentId) {
    if (_inlineImages.containsKey(contentId)) {
      return Future.value(_inlineImages[contentId]);
    }

    final email = this.email;
    if (email == null) return Future.value();

    // A part the extractor left alone still carries its payload, so it needs
    // no download and paints on the first frame.
    final embedded = inlineImageFromMime(email.mime, contentId);
    if (embedded != null) {
      _inlineImages[contentId] = embedded;
      return Future.value(embedded);
    }

    return _inlineImageLoads.putIfAbsent(
      contentId,
      () => _loadInlineImage(email, contentId),
    );
  }

  Future<Uint8List?> thumbnailBytes(Email email, AttachmentRef ref) {
    return _thumbnailLoads.putIfAbsent(
      ref.sha256,
      () => GetIt.I<NostrMailService>().client.getAttachmentBytes(email, ref),
    );
  }

  /// Runs one download at a time: on a cache miss `getAttachmentBytes`
  /// downloads and decrypts the whole message blob, and nothing dedupes that
  /// work, so a signature with five logos would fetch it five times over.
  Future<Uint8List?> _loadInlineImage(Email email, String contentId) async {
    final ref = inlineImageRef(email.attachmentRefs, contentId);
    if (ref == null) {
      _inlineImages[contentId] = null;
      return null;
    }

    final previous = _inlineImageQueue;
    final done = Completer<void>();
    _inlineImageQueue = done.future;
    await previous;

    try {
      final bytes = await GetIt.I<NostrMailService>().client
          .getAttachmentBytes(email, ref);
      _inlineImages[contentId] = bytes;
      return bytes;
    } catch (_) {
      _inlineImages[contentId] = null;
      return null;
    } finally {
      _inlineImageLoads.remove(contentId);
      done.complete();
    }
  }

  EmailPerson get senderPerson {
    final email = this.email!;
    if (!email.isBridged) return EmailPerson.nostr(email.senderPubkey);
    return EmailPerson.email(
      email.sender ?? MailAddress(null, ''),
      bridgePubkey: email.senderPubkey,
    );
  }

  /// Check if Reply All should be shown (multiple recipients or cc/bcc)
  bool get shouldShowReplyAll {
    if (email == null) return false;

    final to = email!.mime.to ?? [];
    final cc = email!.mime.cc ?? [];
    final bcc = email!.mime.bcc ?? [];

    // Show Reply All if:
    // - More than 1 "to" recipient
    // - OR there are cc recipients
    // - OR there are bcc recipients
    return to.length > 1 || cc.isNotEmpty || bcc.isNotEmpty;
  }

  /// Check if current email is read
  bool get isEmailRead {
    if (email == null) return true;
    return GetIt.I<InboxController>().isEmailRead(email!.id);
  }

  Future<void> showEmailSource() async {
    if (email == null) return;

    _ensureRawContent();
    await showEmailSourceDialog(AppRouter.rootContext!);
  }

  Future<String?> _ensureRawContent() async {
    if (email == null) return null;
    if (rawContent != null) return rawContent;
    if (isLoadingRawContent) return null;

    isLoadingRawContent = true;
    notifyListeners();
    try {
      final nostrMailService = GetIt.I<NostrMailService>();
      rawContent = await nostrMailService.client.getRawMimeText(email!);
    } finally {
      if (!_isDisposed) {
        isLoadingRawContent = false;
        notifyListeners();
      }
    }
    return rawContent;
  }

  /// Toggle email read/unread status
  void toggleReadStatus() async {
    if (email == null) return;

    final inboxController = GetIt.I<InboxController>();
    if (isEmailRead) {
      await inboxController.markAsUnread(email!.id);
    } else {
      await inboxController.markAsRead(email!.id);
    }
    if (!_isDisposed) notifyListeners();
  }

  Future<void> loadEmail() async {
    final nostrMailService = GetIt.I<NostrMailService>();
    final reference = nostrEventReferenceFromString(eventReference);
    final loaded = reference == null
        ? null
        : await nostrMailService.client.openEmail(
            eventId: reference.eventId,
            relays: reference.relays,
          );

    email = loaded;
    _buildEmailHtml();
    isLoading = false;
    if (!_isDisposed) notifyListeners();
    if (loaded == null) return;

    // Auto-mark as read where unread shows (non-blocking).
    // Cold-start via share link (mailbox == null) does not auto-mark.
    if (mailbox?.showsUnread ?? false) {
      GetIt.I<InboxController>().markAsRead(loaded.id).then((_) {
        if (!_isDisposed) notifyListeners();
      });
    }
    await _loadSummary();
  }

  Future<void> _loadSummary() async {
    final id = email?.id;
    if (id == null) return;
    summary = await GetIt.I<NostrMailService>().client.getSummary(id);
    if (!_isDisposed) notifyListeners();
  }

  Future<void> moveTo(BuildContext context) async {
    final id = email?.id;
    if (id == null) return;
    final folder = await showMoveToPicker(context, current: mailbox);
    if (folder == null) return;
    await GetIt.I<InboxController>().moveTo([id], folder);
    AppRouter.popOrGoInbox();
  }

  Future<void> editTags(BuildContext context) async {
    final summary = this.summary;
    if (summary == null) return;
    final changes = await showTagsPicker(context, emails: [summary]);
    if (changes == null) return;
    await GetIt.I<InboxController>().applyTags(
      [summary],
      add: changes.add,
      remove: changes.remove,
    );
    await _loadSummary();
  }

  Future<void> removeTag(String tagId) async {
    final summary = this.summary;
    if (summary == null) return;
    await GetIt.I<InboxController>().applyTags([summary], remove: {tagId});
    await _loadSummary();
  }

  Future<void> deleteEmail(BuildContext context) async {
    if (email == null) return;

    final l = AppLocalizations.of(context);
    final inboxController = GetIt.I<InboxController>();
    final isInTrash = mailbox?.isTrash ?? false;

    if (isInTrash) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.emailDeletePermanentlyTitle),
          content: Text(l.emailDeletePermanentlyMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(l.actionDelete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await inboxController.deleteEmail(email!.id);
    } else {
      inboxController.deleteEmail(email!.id);
    }
    AppRouter.popOrGoInbox();
  }

  Future<void> showNip59Events() async {
    if (email == null) return;

    final nostrMailService = GetIt.I<NostrMailService>();

    final giftWrap = await nostrMailService.client.getGiftWrap(email!.id);
    final seal = await nostrMailService.client.getSeal(email!.id);
    final rumor = await nostrMailService.client.getRumor(email!.id);

    await showNip59EventsDialog(
      context: AppRouter.rootContext!,
      giftWrap: giftWrap,
      seal: seal,
      rumor: rumor,
    );
  }

  void restoreEmail() {
    if (email == null) return;

    GetIt.I<InboxController>().restoreFromTrash(email!.id);
    AppRouter.popOrGoInbox();
  }

  void handleAttachmentTap({
    required AttachmentRef ref,
    bool isImage = false,
    bool isPdf = false,
  }) {
    if (isImage) {
      showImageViewer(ref: ref);
    } else if (isPdf) {
      showPdfViewer(ref: ref);
    } else {
      downloadAttachment(ref: ref);
    }
  }

  Future<void> downloadEmail() async {
    if (email == null) return;

    final l = AppLocalizations.of(AppRouter.rootContext!);
    try {
      final subject = (email!.subject?.isEmpty ?? true)
          ? l.emailDefaultFilename
          : email!.subject!;
      final fileName = subject.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      final raw = await _ensureRawContent();
      if (raw == null) {
        ToastHelper.error(AppRouter.rootContext!, l.emailRawContentUnavailable);
        return;
      }
      final bytes = utf8.encode(raw);

      String result;
      if (PlatformHelper.isAndroid) {
        result = await AndroidFileSaver.saveToDownloads(
          fileName: '$fileName.eml',
          bytes: Uint8List.fromList(bytes),
          mimeType: 'message/rfc822',
        );
      } else {
        result = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(bytes),
          fileExtension: 'eml',
          mimeType: MimeType.other,
        );
      }

      ToastHelper.success(AppRouter.rootContext!, l.emailSaved(result));
    } catch (e) {
      ToastHelper.error(
        AppRouter.rootContext!,
        l.emailSaveFailed(e.toString()),
      );
    }
  }

  Future<void> repostEmail() async {
    if (email == null) return;

    final l = AppLocalizations.of(AppRouter.rootContext!);
    try {
      final nostrMailService = GetIt.I<NostrMailService>();
      final rumor = await nostrMailService.client.getRumor(email!.id);

      if (rumor == null) {
        ToastHelper.error(AppRouter.rootContext!, l.emailRepostFailedEvent);
        return;
      }

      await nostrMailService.client.repost(rumor);
      ToastHelper.success(AppRouter.rootContext!, l.emailRepostSuccess);
    } catch (e) {
      ToastHelper.error(
        AppRouter.rootContext!,
        l.emailRepostFailed(e.toString()),
      );
    }
  }

  void replyEmail() {
    if (email == null) return;
    AppRouter.router.push(
      AppRoutes.compose,
      extra: {'email': email, 'mode': ComposeMode.reply},
    );
  }

  void replyAllEmail() {
    if (email == null) return;
    AppRouter.router.push(
      AppRoutes.compose,
      extra: {'email': email, 'mode': ComposeMode.replyAll},
    );
  }

  void forwardEmail() {
    if (email == null) return;
    AppRouter.router.push(
      AppRoutes.compose,
      extra: {'email': email, 'mode': ComposeMode.forward},
    );
  }

  void archiveEmail() {
    if (email == null) return;
    GetIt.I<InboxController>().moveToArchive(email!.id);
    AppRouter.popOrGoInbox();
  }

  bool get isFromMe =>
      email?.senderPubkey == Get.find<AuthController>().publicKey;

  /// The email leaves the mailbox it is shown from, along with every other
  /// email of its sender: back to that mailbox's list, past a page listing
  /// only that sender's emails.
  Future<void> setSenderVerdict(
    BuildContext context,
    SenderVerdict verdict,
  ) async {
    final senderKey = email?.senderKey;
    if (senderKey == null) return;
    final applied = await runSenderVerdict(
      context,
      () => GetIt.I<InboxController>().setSenderVerdict([senderKey], verdict),
    );
    if (!applied) return;
    final mailbox = this.mailbox;
    if (mailbox == null) {
      AppRouter.popOrGoInbox();
    } else {
      AppRouter.router.go(AppRoutes.mailboxPath(mailbox));
    }
  }

  void unarchiveEmail() {
    if (email == null) return;
    GetIt.I<InboxController>().restoreFromArchive(email!.id);
    AppRouter.popOrGoInbox();
  }

  Future<void> downloadAttachment({required AttachmentRef ref}) async {
    final l = AppLocalizations.of(AppRouter.rootContext!);
    if (email == null) return;
    final filename = ref.filename ?? 'attachment';
    final nostrMailService = GetIt.I<NostrMailService>();
    final fileData = await nostrMailService.client.getAttachmentBytes(
      email!,
      ref,
    );
    if (fileData == null) {
      ToastHelper.error(AppRouter.rootContext!, l.emailAttachmentLoadFailed);
      return;
    }

    try {
      // Extract file extension
      final extension = p
          .extension(filename)
          .toLowerCase()
          .replaceFirst('.', '');

      // Map common extensions to MIME types
      MimeType mimeType = getMimeType(extension);

      // Clean filename (remove path if any)
      final cleanName = p.basename(filename);

      if (PlatformHelper.isAndroid) {
        await AndroidFileSaver.saveToDownloads(
          fileName: cleanName,
          bytes: fileData,
          mimeType: _getMimeTypeString(mimeType, extension),
        );
      } else {
        await FileSaver.instance.saveFile(
          name: p.basenameWithoutExtension(cleanName),
          bytes: fileData,
          fileExtension: extension,
          mimeType: mimeType,
        );
      }

      ToastHelper.success(AppRouter.rootContext!, l.emailFileSaved);
    } catch (e) {
      ToastHelper.error(
        AppRouter.rootContext!,
        l.emailFileSaveFailed(e.toString()),
      );
    }
  }

  Future<void> downloadAllAttachments(List<AttachmentRef> attachments) async {
    final l = AppLocalizations.of(AppRouter.rootContext!);
    if (email == null) return;
    int successCount = 0;
    int failureCount = 0;
    final nostrMailService = GetIt.I<NostrMailService>();

    for (final ref in attachments) {
      final filename = ref.filename ?? 'attachment';
      final fileData = await nostrMailService.client.getAttachmentBytes(
        email!,
        ref,
      );
      if (fileData == null) {
        failureCount++;
        continue;
      }

      try {
        // Extract file extension
        final extension = p
            .extension(filename)
            .toLowerCase()
            .replaceFirst('.', '');

        // Map common extensions to MIME types
        MimeType mimeType = getMimeType(extension);

        // Clean filename (remove path if any)
        final cleanName = p.basename(filename);

        if (PlatformHelper.isAndroid) {
          await AndroidFileSaver.saveToDownloads(
            fileName: cleanName,
            bytes: fileData,
            mimeType: _getMimeTypeString(mimeType, extension),
          );
        } else {
          await FileSaver.instance.saveFile(
            name: p.basenameWithoutExtension(cleanName),
            bytes: fileData,
            fileExtension: extension,
            mimeType: mimeType,
          );
        }
        successCount++;
      } catch (e) {
        failureCount++;
      }
    }

    if (failureCount == 0) {
      ToastHelper.success(
        AppRouter.rootContext!,
        l.emailDownloadedAllSuccess(successCount),
      );
    } else if (successCount == 0) {
      ToastHelper.error(
        AppRouter.rootContext!,
        l.emailDownloadedAllFailed(failureCount),
      );
    } else {
      ToastHelper.info(
        AppRouter.rootContext!,
        l.emailDownloadedMixed(successCount, failureCount),
      );
    }
  }

  void showImageViewer({required AttachmentRef ref}) {
    if (email == null) return;
    showImageViewerPage(
      AppRouter.rootContext!,
      filename: ref.filename ?? 'image',
      imageData: GetIt.I<NostrMailService>().client.getAttachmentBytes(
        email!,
        ref,
      ),
      onDownload: () => downloadAttachment(ref: ref),
    );
  }

  Future<void> showPdfViewer({required AttachmentRef ref}) async {
    final l = AppLocalizations.of(AppRouter.rootContext!);
    if (email == null) return;
    final filename = ref.filename ?? 'document.pdf';
    final nostrMailService = GetIt.I<NostrMailService>();
    final pdfData = await nostrMailService.client.getAttachmentBytes(
      email!,
      ref,
    );
    if (pdfData != null) {
      Navigator.of(AppRouter.rootContext!).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              WindowCaptionInset(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: Text(
                      filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: const CloseButton(),
                    actionsPadding: .only(right: 8),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => downloadAttachment(ref: ref),
                        tooltip: l.emailDownload,
                      ),
                    ],
                  ),
                  body: PdfViewer.data(pdfData, sourceName: filename),
                ),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      ToastHelper.error(AppRouter.rootContext!, l.emailPdfLoadFailed);
    }
  }

  String _getMimeTypeString(MimeType mimeType, String extension) {
    switch (mimeType) {
      case MimeType.pdf:
        return 'application/pdf';
      case MimeType.jpeg:
        return 'image/jpeg';
      case MimeType.png:
        return 'image/png';
      case MimeType.gif:
        return 'image/gif';
      case MimeType.webp:
        return 'image/webp';
      case MimeType.text:
        return 'text/plain';
      case MimeType.xml:
        return 'text/xml';
      case MimeType.json:
        return 'application/json';
      case MimeType.zip:
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
}
