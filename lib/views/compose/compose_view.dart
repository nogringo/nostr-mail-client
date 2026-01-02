import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/compose_controller.dart';
import '../../utils/toast_helper.dart';
import 'widgets/recipient_chip.dart';

class ComposeView extends StatefulWidget {
  const ComposeView({super.key});

  @override
  State<ComposeView> createState() => _ComposeViewState();
}

class _ComposeViewState extends State<ComposeView> {
  final controller = Get.find<ComposeController>();

  late final TextEditingController fromController;
  late final TextEditingController toController;
  late final TextEditingController subjectController;
  late final TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;

    fromController = TextEditingController(
      text: args?['from'] as String? ?? '',
    );
    toController = TextEditingController();
    subjectController = TextEditingController(text: args?['subject'] ?? '');
    bodyController = TextEditingController();

    // Load default from if not provided
    if (fromController.text.isEmpty) {
      _loadDefaultFrom();
    }

    // Add replyTo as recipient if provided
    final replyTo = args?['replyTo'] as String?;
    if (replyTo != null && replyTo.isNotEmpty) {
      controller.addRecipient(replyTo);
    }
  }

  Future<void> _loadDefaultFrom() async {
    final defaultFrom = await controller.getDefaultFrom();
    if (defaultFrom != null && fromController.text.isEmpty) {
      fromController.text = defaultFrom;
    }
  }

  @override
  void dispose() {
    fromController.dispose();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: fromController,
              decoration: InputDecoration(
                hintText: 'From',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
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
                        onDelete: () => controller.removeRecipient(entry.key),
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
    );
  }

  Future<void> _send() async {
    if (fromController.text.isEmpty) {
      ToastHelper.error(context, 'Enter a From address');
      return;
    }
    if (controller.recipients.isEmpty) {
      ToastHelper.error(context, 'Add at least one recipient');
      return;
    }

    final success = await controller.send(
      from: fromController.text,
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
}
