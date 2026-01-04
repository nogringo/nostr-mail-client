import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/compose_controller.dart';
import '../../models/from_option.dart';
import '../../utils/toast_helper.dart';
import 'widgets/from_selector_sheet.dart';
import 'widgets/recipient_chip.dart';

class ComposeView extends StatefulWidget {
  const ComposeView({super.key});

  @override
  State<ComposeView> createState() => _ComposeViewState();
}

class _ComposeViewState extends State<ComposeView> {
  final controller = Get.find<ComposeController>();

  late final TextEditingController toController;
  late final TextEditingController subjectController;
  late final TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;

    toController = TextEditingController();
    subjectController = TextEditingController(text: args?['subject'] ?? '');
    bodyController = TextEditingController();

    // Load from options
    controller.loadFromOptions();

    // Add replyTo as recipient if provided
    final replyTo = args?['replyTo'] as String?;
    if (replyTo != null && replyTo.isNotEmpty) {
      controller.addRecipient(replyTo);
    }
  }

  @override
  void dispose() {
    toController.dispose();
    subjectController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void _handleToInput(String value) {
    // Check for space or comma to add recipient
    if (value.endsWith(' ') || value.endsWith(',')) {
      final input = value.substring(0, value.length - 1).trim();
      if (input.isNotEmpty) {
        controller.addRecipient(input);
        toController.clear();
      }
    }
  }

  void _handleToSubmit(String value) {
    final input = value.trim();
    if (input.isNotEmpty) {
      controller.addRecipient(input);
      toController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose'),
        actions: [
          Obx(
            () => controller.isSending.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(icon: const Icon(Icons.send), onPressed: _send),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildFromSelector(context),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...controller.recipients.asMap().entries.map(
                          (entry) => RecipientChip(
                            recipient: entry.value,
                            onDelete: () =>
                                controller.removeRecipient(entry.key),
                          ),
                        ),
                        IntrinsicWidth(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 100),
                            child: TextField(
                              controller: toController,
                              decoration: InputDecoration(
                                hintText: controller.recipients.isEmpty
                                    ? 'To'
                                    : 'Add more',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 16),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: _handleToInput,
                              onSubmitted: _handleToSubmit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    hintText: 'Subject',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: bodyController,
                    decoration: InputDecoration(
                      hintText: 'Compose email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                    maxLines: null,
                    expands: true,
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (controller.recipients.isEmpty) {
      ToastHelper.error(context, 'Add at least one recipient');
      return;
    }

    final selectedFrom = controller.selectedFrom.value;
    final hasLegacyRecipient = controller.recipients.any((r) => r.isLegacy);
    if (hasLegacyRecipient && selectedFrom == null) {
      ToastHelper.error(context, 'Select a From address for legacy email');
      return;
    }

    final success = await controller.send(
      from: selectedFrom?.address,
      subject: subjectController.text,
      body: bodyController.text,
    );

    if (success) {
      if (mounted) {
        ToastHelper.success(context, 'Email sent');
      }
      Get.back();
    } else {
      if (mounted) {
        ToastHelper.error(context, 'Failed to send email');
      }
    }
  }

  Widget _buildFromSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => FromSelectorSheet.show(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'From',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final selected = controller.selectedFrom.value;
                if (selected == null) {
                  return Text(
                    'Loading...',
                    style: TextStyle(color: colorScheme.outline),
                  );
                }
                return Row(
                  children: [
                    _buildFromAvatar(context, selected),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selected.label,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (selected.displayName != null &&
                              selected.displayName!.isNotEmpty)
                            Text(
                              selected.shortAddress,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromAvatar(BuildContext context, FromOption option) {
    final colorScheme = Theme.of(context).colorScheme;

    if (option.picture != null && option.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(option.picture!),
        backgroundColor: colorScheme.primaryContainer,
      );
    }

    final initial = option.displayName?.isNotEmpty == true
        ? option.displayName![0].toUpperCase()
        : 'N';

    return CircleAvatar(
      radius: 14,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
