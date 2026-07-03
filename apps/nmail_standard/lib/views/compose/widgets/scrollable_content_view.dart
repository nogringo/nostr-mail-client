import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:nmail_standard/controllers/compose_controller.dart';
import 'package:nmail_standard/l10n/generated/app_localizations.dart';
import 'package:nmail_standard/utils/responsive_helper.dart';
import 'package:nmail_standard/views/compose/widgets/from_selector_view.dart';
import 'package:nmail_standard/views/compose/widgets/recipient_chip.dart';

import 'attachment_chip.dart';
import 'quill_toolbar_view.dart';
import 'recipient_autocomplete.dart';
import 'schedule_banner.dart';

class ScrollableContentView extends StatelessWidget {
  const ScrollableContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ComposeController.to;
    final isWide = ResponsiveHelper.isNotMobile(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ScheduleBanner(),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.recipients.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    itemCount: controller.recipients.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => RecipientChip(
                      recipient: controller.recipients[index],
                      onDelete: () => controller.removeRecipient(index),
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: RecipientAutocomplete(
                        textController: controller.toController,
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
                  IconButton(
                    icon: Icon(
                      controller.showExpandedFields.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onPressed: controller.toggleExpandedFields,
                    tooltip: controller.showExpandedFields.value
                        ? l.composeHideExpanded
                        : l.composeShowExpanded,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              if (controller.showExpandedFields.value) ...[
                const Divider(height: 1),
                if (controller.ccRecipients.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: controller.ccRecipients.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => RecipientChip(
                        recipient: controller.ccRecipients[index],
                        onDelete: () => controller.removeCcRecipient(index),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RecipientAutocomplete(
                    textController: controller.ccController,
                    hintText: l.composeCc,
                    excludeIds: controller.ccRecipientIds,
                    onContactSelected: controller.addCcRecipientFromContact,
                    onManualInput: controller.addCcRecipient,
                    onSubmitted: controller.handleCcSubmit,
                  ),
                ),
                const Divider(height: 1),
                if (controller.bccRecipients.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: controller.bccRecipients.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => RecipientChip(
                        recipient: controller.bccRecipients[index],
                        onDelete: () => controller.removeBccRecipient(index),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RecipientAutocomplete(
                    textController: controller.bccController,
                    hintText: l.composeBcc,
                    excludeIds: controller.bccRecipientIds,
                    onContactSelected: controller.addBccRecipientFromContact,
                    onManualInput: controller.addBccRecipient,
                    onSubmitted: controller.handleBccSubmit,
                  ),
                ),
                const Divider(height: 1),
                FromSelectorView(),
              ],
            ],
          ),
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
        QuillToolbarView(),
        const Divider(height: 1),
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: QuillEditor(
              controller: controller.quillController,
              focusNode: controller.editorFocusNode,
              scrollController: controller.editorScrollController,
              config: QuillEditorConfig(
                placeholder: l.composePlaceholder,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.attachments.isEmpty) return Container();

          return Column(
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
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
