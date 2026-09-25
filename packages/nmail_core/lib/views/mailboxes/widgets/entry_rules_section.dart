import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'entry_attachment_filter.dart';

/// The `match` condition that files emails into the entry without any label.
class EntryRulesSection extends StatelessWidget {
  final MailEntryFormController controller;

  const EntryRulesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final materialL = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(l.mailboxRules, style: theme.textTheme.titleSmall),
                  Text(
                    switch (controller.kind) {
                      MailEntryKind.folder => l.mailboxRulesFolderHelp,
                      MailEntryKind.tag => l.mailboxRulesTagHelp,
                    },
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final expanded = controller.rulesExpanded.value;
              return IconButton(
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                tooltip: expanded
                    ? materialL.expandedIconTapHint
                    : materialL.collapsedIconTapHint,
                onPressed: () => controller.rulesExpanded.value = !expanded,
              );
            }),
          ],
        ),
        Obx(
          () => AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: controller.rulesExpanded.value
                // The top padding keeps the first field's floating label
                // inside the clip of the animation.
                ? Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: controller.fromController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l.mailboxRuleFrom,
                            hintText: l.mailboxRuleFromHint,
                            helperText: l.mailboxRuleListHelper,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controller.subjectController,
                          decoration: InputDecoration(
                            labelText: l.mailboxRuleSubject,
                            helperText: l.mailboxRuleListHelper,
                          ),
                        ),
                        const SizedBox(height: 16),
                        EntryAttachmentFilter(controller: controller),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }
}
