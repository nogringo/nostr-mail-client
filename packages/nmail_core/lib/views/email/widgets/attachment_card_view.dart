import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/utils/get_attachements.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/views/email/widgets/image_thumbnail_view.dart';
import 'package:nmail_core/views/email/widgets/pdf_thumbnail_view.dart';

class AttachmentCardView extends StatelessWidget {
  final Email email;
  final AttachmentRef attachment;

  const AttachmentCardView({
    super.key,
    required this.email,
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    final filename = attachment.filename ?? '';
    final icon = getAttachmentIcon(filename);
    final isImage = isImageFile(filename);
    final isPdf = isPdfFile(filename);
    final size = formatFileSize(attachment.size);

    return InkWell(
      onTap: () => EmailController.to.handleAttachmentTap(
        ref: attachment,
        isImage: isImage,
        isPdf: isPdf,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 140, maxWidth: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isImage)
              ImageThumbnailView(ref: attachment, email: email)
            else if (isPdf)
              PdfThumbnailView()
            else
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filename,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attachment.size > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      size,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
