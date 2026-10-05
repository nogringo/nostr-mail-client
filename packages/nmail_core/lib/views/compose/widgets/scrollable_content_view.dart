import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/views/compose/widgets/from_selector_view.dart';
import 'package:nmail_core/views/compose/widgets/recipient_chips_row.dart';

import 'attachment_chip.dart';
import 'editor_context_menu.dart';
import 'inline_image_embed_builder.dart';
import 'quill_toolbar_view.dart';
import 'quoted_email_view.dart';
import 'recipient_autocomplete.dart';
import 'schedule_banner.dart';

class ScrollableContentView extends StatelessWidget {
  const ScrollableContentView({super.key, required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = ResponsiveHelper.isNotMobile(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScheduleBanner(controller: controller),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.recipients.isNotEmpty)
              RecipientChipsRow(
                controller: controller,
                field: RecipientField.to,
                recipients: controller.recipients,
                onDelete: controller.removeRecipient,
              ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: RecipientAutocomplete(
                      textController: controller.toController,
                      focusNode: controller.focusNodeOf(RecipientField.to),
                      hintText: controller.recipients.isEmpty
                          ? l.composeTo
                          : l.composeAddMore,
                      excludeIds: controller.recipientIds,
                      onContactSelected: controller.addRecipientFromContact,
                      onManualInput: controller.addRecipient,
                      onSubmitted: controller.handleToSubmit,
                    ),
                  ),
                ),
                if (isWide)
                  TextButton.icon(
                    onPressed: controller.toggleExpandedFields,
                    icon: Icon(
                      controller.showExpandedFields
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    iconAlignment: IconAlignment.end,
                    label: Text(l.composeExpandedFieldsButtonLabel),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      controller.showExpandedFields
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: controller.toggleExpandedFields,
                    tooltip: controller.showExpandedFields
                        ? l.composeHideExpanded
                        : l.composeShowExpanded,
                  ),
                SizedBox(width: isWide ? 16 : 8),
              ],
            ),
            if (controller.showExpandedFields) ...[
              const Divider(height: 1),
              if (controller.ccRecipients.isNotEmpty)
                RecipientChipsRow(
                  controller: controller,
                  field: RecipientField.cc,
                  recipients: controller.ccRecipients,
                  onDelete: controller.removeCcRecipient,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RecipientAutocomplete(
                  textController: controller.ccController,
                  focusNode: controller.focusNodeOf(RecipientField.cc),
                  hintText: l.composeCc,
                  excludeIds: controller.ccRecipientIds,
                  onContactSelected: controller.addCcRecipientFromContact,
                  onManualInput: controller.addCcRecipient,
                  onSubmitted: controller.handleCcSubmit,
                ),
              ),
              const Divider(height: 1),
              if (controller.bccRecipients.isNotEmpty)
                RecipientChipsRow(
                  controller: controller,
                  field: RecipientField.bcc,
                  recipients: controller.bccRecipients,
                  onDelete: controller.removeBccRecipient,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RecipientAutocomplete(
                  textController: controller.bccController,
                  focusNode: controller.focusNodeOf(RecipientField.bcc),
                  hintText: l.composeBcc,
                  excludeIds: controller.bccRecipientIds,
                  onContactSelected: controller.addBccRecipientFromContact,
                  onManualInput: controller.addBccRecipient,
                  onSubmitted: controller.handleBccSubmit,
                ),
              ),
              const Divider(height: 1),
              FromSelectorView(controller: controller),
            ],
          ],
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: TextField(
            controller: controller.subjectController,
            decoration: InputDecoration(
              hintText: l.composeSubject,
              border: InputBorder.none,
              suffixIcon: isWide
                  ? null
                  : IconButton(
                      onPressed: controller.pickAttachments,
                      icon: const Icon(Icons.attach_file),
                      tooltip: l.composeAttachFile,
                    ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        const Divider(height: 1),
        QuillToolbarView(controller: controller),
        const Divider(height: 1),
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EditorContextMenu(
              controller: controller,
              child: QuillEditor(
                controller: controller.quillController,
                focusNode: controller.editorFocusNode,
                scrollController: controller.editorScrollController,
                config: QuillEditorConfig(
                  placeholder: l.composePlaceholder,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  embedBuilders: [
                    InlineImageEmbedBuilder(controller.inlineImages),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (controller.attachments.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < controller.attachments.length; i++)
                      AttachmentChip(
                        attachment: controller.attachments[i],
                        onDelete: () => controller.removeAttachment(i),
                        onRename: (filename) =>
                            controller.renameAttachment(i, filename),
                      ),
                  ],
                ),
              ),
            ],
          ),
        QuotedEmailView(controller: controller),
      ],
    );
  }
}
