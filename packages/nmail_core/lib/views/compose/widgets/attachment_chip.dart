import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/compose_attachment.dart';
import 'package:nmail_core/utils/get_attachements.dart';
import 'package:nmail_core/views/email/widgets/image_viewer_page.dart';
import 'rename_attachment_dialog.dart';
import 'show_attachment_menu.dart';

class AttachmentChip extends StatelessWidget {
  final ComposeAttachment attachment;
  final VoidCallback onDelete;
  final ValueChanged<String> onRename;

  const AttachmentChip({
    super.key,
    required this.attachment,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final iconView = Icon(
      getAttachmentIcon(attachment.filename),
      size: 20,
      color: colorScheme.primary,
    );
    final size = formatFileSize(attachment.size);
    final isImage = isImageFile(attachment.filename);
    const thumbnailSize = 32.0;

    void openMenu([Offset? position]) => showAttachmentMenu(
      context,
      attachment: attachment,
      onRename: onRename,
      onRemove: onDelete,
      position: position,
    );

    return GestureDetector(
      onSecondaryTapUp: (details) => openMenu(details.globalPosition),
      child: Material(
        color: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isImage
              ? () => showImageViewerPage(
                  context,
                  filename: attachment.filename,
                  imageData: Future.value(attachment.data),
                  onRename: (context, filename) async {
                    final renamed = await showRenameAttachmentDialog(
                      context,
                      filename,
                    );
                    if (renamed != null) onRename(renamed);
                    return renamed;
                  },
                )
              : null,
          onLongPress: openMenu,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(
                      attachment.data,
                      width: thumbnailSize,
                      height: thumbnailSize,
                      cacheWidth:
                          (thumbnailSize *
                                  MediaQuery.devicePixelRatioOf(context))
                              .round(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => iconView,
                    ),
                  )
                else
                  iconView,
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        attachment.filename,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        size,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: l.composeRemoveAttachment,
                  button: true,
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
