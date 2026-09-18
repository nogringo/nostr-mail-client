import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_mail_plus/enough_mail.dart' show MailAddress;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/get_mime_type.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:nmail_core/views/email/widgets/email_source_dialog.dart';
import 'package:nmail_core/views/email/widgets/nip59_events_dialog.dart';
import 'package:nmail_core/views/shared/window_caption_inset.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:nmail_core/services/android_file_saver.dart';
import 'package:nmail_core/utils/platform_helper.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class EmailController extends GetxController {
  static EmailController get to => Get.find();

  /// Nostr event reference this controller renders.
  ///
  /// Can be a 64-char hex event id, a note, or a nevent. A nevent can carry
  /// relay hints from push notifications and share links.
  final String eventReference;

  /// Folder the email is being viewed from. Null when reached via the
  /// `/:nostrId` share-link dispatcher (no folder context). Source of
  /// truth for folder-dependent UI (restore button, mark-as-read on
  /// open, destructive vs trash semantics).
  final MailFolder? folder;

  Email? email;
  bool isLoading = true;
  bool showRecipients = false;
  late bool showImages;
  String? rawContent;
  bool isLoadingRawContent = false;

  EmailController({required this.eventReference, this.folder}) {
    showImages = Get.find<SettingsController>().alwaysLoadImages.value;
    loadEmail();
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
    return Get.find<InboxController>().isEmailRead(email!.id);
  }

  Future<void> showEmailSource() async {
    if (email == null) return;

    _ensureRawContent();
    await showEmailSourceDialog(Get.context!);
  }

  Future<String?> _ensureRawContent() async {
    if (email == null) return null;
    if (rawContent != null) return rawContent;
    if (isLoadingRawContent) return null;

    isLoadingRawContent = true;
    update();
    try {
      final nostrMailService = Get.find<NostrMailService>();
      rawContent = await nostrMailService.client.getRawMimeText(email!);
    } finally {
      isLoadingRawContent = false;
      update();
    }
    return rawContent;
  }

  /// Toggle email read/unread status
  void toggleReadStatus() async {
    if (email == null) return;

    final inboxController = Get.find<InboxController>();
    if (isEmailRead) {
      await inboxController.markAsUnread(email!.id);
    } else {
      await inboxController.markAsRead(email!.id);
    }
    update();
  }

  Future<void> loadEmail() async {
    final nostrMailService = Get.find<NostrMailService>();
    final reference = nostrEventReferenceFromString(eventReference);
    final loaded = reference == null
        ? null
        : await nostrMailService.client.openEmail(
            eventId: reference.eventId,
            relays: reference.relays,
          );

    email = loaded;
    isLoading = false;
    update();

    // Auto-mark as read for inbox emails only (non-blocking).
    // Cold-start via share link (folder == null) does not auto-mark.
    if (loaded != null && folder == MailFolder.inbox) {
      Get.find<InboxController>().markAsRead(loaded.id);
    }
  }

  Future<void> deleteEmail(BuildContext context) async {
    if (email == null) return;

    final l = AppLocalizations.of(context);
    final inboxController = Get.find<InboxController>();
    final isInTrash = folder == MailFolder.trash;

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

    final nostrMailService = Get.find<NostrMailService>();

    final giftWrap = await nostrMailService.client.getGiftWrap(email!.id);
    final seal = await nostrMailService.client.getSeal(email!.id);
    final rumor = await nostrMailService.client.getRumor(email!.id);

    await showNip59EventsDialog(
      context: Get.context!,
      giftWrap: giftWrap,
      seal: seal,
      rumor: rumor,
    );
  }

  void restoreEmail() {
    if (email == null) return;

    Get.find<InboxController>().restoreFromTrash(email!.id);
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

    final l = AppLocalizations.of(Get.context!);
    try {
      final subject = (email!.subject?.isEmpty ?? true)
          ? l.emailDefaultFilename
          : email!.subject!;
      final fileName = subject.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      final raw = await _ensureRawContent();
      if (raw == null) {
        ToastHelper.error(Get.context!, l.emailRawContentUnavailable);
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

      ToastHelper.success(Get.context!, l.emailSaved(result));
    } catch (e) {
      ToastHelper.error(Get.context!, l.emailSaveFailed(e.toString()));
    }
  }

  Future<void> repostEmail() async {
    if (email == null) return;

    final l = AppLocalizations.of(Get.context!);
    try {
      final nostrMailService = Get.find<NostrMailService>();
      final rumor = await nostrMailService.client.getRumor(email!.id);

      if (rumor == null) {
        ToastHelper.error(Get.context!, l.emailRepostFailedEvent);
        return;
      }

      await nostrMailService.client.repost(rumor);
      ToastHelper.success(Get.context!, l.emailRepostSuccess);
    } catch (e) {
      ToastHelper.error(Get.context!, l.emailRepostFailed(e.toString()));
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
    Get.find<InboxController>().moveToArchive(email!.id);
    AppRouter.popOrGoInbox();
  }

  void unarchiveEmail() {
    if (email == null) return;
    Get.find<InboxController>().restoreFromArchive(email!.id);
    AppRouter.popOrGoInbox();
  }

  Future<void> downloadAttachment({required AttachmentRef ref}) async {
    final l = AppLocalizations.of(Get.context!);
    if (email == null) return;
    final filename = ref.filename ?? 'attachment';
    final nostrMailService = Get.find<NostrMailService>();
    final fileData = await nostrMailService.client.getAttachmentBytes(
      email!,
      ref,
    );
    if (fileData == null) {
      ToastHelper.error(Get.context!, l.emailAttachmentLoadFailed);
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

      ToastHelper.success(Get.context!, l.emailFileSaved);
    } catch (e) {
      ToastHelper.error(Get.context!, l.emailFileSaveFailed(e.toString()));
    }
  }

  Future<void> downloadAllAttachments(List<AttachmentRef> attachments) async {
    final l = AppLocalizations.of(Get.context!);
    if (email == null) return;
    int successCount = 0;
    int failureCount = 0;
    final nostrMailService = Get.find<NostrMailService>();

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
        Get.context!,
        l.emailDownloadedAllSuccess(successCount),
      );
    } else if (successCount == 0) {
      ToastHelper.error(Get.context!, l.emailDownloadedAllFailed(failureCount));
    } else {
      ToastHelper.info(
        Get.context!,
        l.emailDownloadedMixed(successCount, failureCount),
      );
    }
  }

  Future<void> showImageViewer({required AttachmentRef ref}) async {
    final l = AppLocalizations.of(Get.context!);
    if (email == null) return;
    final filename = ref.filename ?? 'image';
    final nostrMailService = Get.find<NostrMailService>();
    final imageData = await nostrMailService.client.getAttachmentBytes(
      email!,
      ref,
    );
    if (imageData != null) {
      Navigator.of(Get.context!).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              WindowCaptionInset(
                child: Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                    actionsPadding: .only(right: 8),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () => downloadAttachment(ref: ref),
                        tooltip: l.emailDownload,
                      ),
                    ],
                  ),
                  body: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      // Swallows taps on the image so only the backdrop closes.
                      child: GestureDetector(
                        onTap: () {},
                        child: InteractiveViewer(
                          child: Image.memory(imageData, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      ToastHelper.error(Get.context!, l.emailImageLoadFailed);
    }
  }

  Future<void> showPdfViewer({required AttachmentRef ref}) async {
    final l = AppLocalizations.of(Get.context!);
    if (email == null) return;
    final filename = ref.filename ?? 'document.pdf';
    final nostrMailService = Get.find<NostrMailService>();
    final pdfData = await nostrMailService.client.getAttachmentBytes(
      email!,
      ref,
    );
    if (pdfData != null) {
      Navigator.of(Get.context!).push(
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
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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
      ToastHelper.error(Get.context!, l.emailPdfLoadFailed);
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
