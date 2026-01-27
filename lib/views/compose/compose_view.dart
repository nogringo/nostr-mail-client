import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../controllers/compose_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/from_option.dart';
import '../../services/nostr_mail_service.dart';
import '../../utils/toast_helper.dart';
import 'widgets/from_selector_sheet.dart';
import 'widgets/recipient_autocomplete.dart';
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
  late final QuillController quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final signature = Get.find<SettingsController>().emailSignature.value;

    toController = TextEditingController();
    subjectController = TextEditingController();

    // Initialize Quill controller with signature
    if (signature.isEmpty) {
      quillController = QuillController.basic();
    } else {
      final doc = Document()..insert(0, '\n\n$signature');
      quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Load from options
    controller.loadFromOptions();

    // Handle reply/forward mode
    final email = args?['email'] as Email?;
    final mode = args?['mode'] as String?;

    if (email != null && mode != null) {
      _initFromEmail(email, mode);
    }
  }

  void _initFromEmail(Email email, String mode) {
    final myPubkey = Get.find<NostrMailService>().getPublicKey();
    final isSentByMe = email.senderPubkey == myPubkey;
    final signature = Get.find<SettingsController>().emailSignature.value;
    final signatureBlock = signature.isEmpty ? '' : '\n\n$signature';

    if (mode == 'reply') {
      // Set recipient
      final replyTo = isSentByMe ? email.to : email.from;
      controller.addRecipient(replyTo);

      // Set subject (avoid Re: Re: Re:)
      final subject = email.subject;
      subjectController.text = subject.startsWith('Re:')
          ? subject
          : 'Re: $subject';

      // Set body with quoted original message
      final dateFormat = DateFormat('EEE, MMM d, yyyy \'at\' h:mm a');
      final quotedBody = email.body
          .split('\n')
          .map((line) => '> $line')
          .join('\n');
      final bodyText =
          '$signatureBlock\n\nOn ${dateFormat.format(email.date)}, ${email.from} wrote:\n$quotedBody';
      _setQuillContent(bodyText);
    } else if (mode == 'forward') {
      // Set subject (avoid Fwd: Fwd: Fwd:)
      final subject = email.subject;
      subjectController.text = subject.startsWith('Fwd:')
          ? subject
          : 'Fwd: $subject';

      // Set body with forwarded message
      final dateFormat = DateFormat('EEE, MMM d, yyyy \'at\' h:mm a');
      final bodyText =
          '$signatureBlock\n\n---------- Forwarded message ----------\n'
          'From: ${email.from}\n'
          'Date: ${dateFormat.format(email.date)}\n'
          'Subject: ${email.subject}\n\n'
          '${email.body}';
      _setQuillContent(bodyText);
    }
  }

  void _setQuillContent(String text) {
    final doc = Document()..insert(0, text);
    quillController.document = doc;
    quillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  @override
  void dispose() {
    toController.dispose();
    subjectController.dispose();
    quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RecipientAutocomplete(
                        textController: toController,
                        hintText: controller.recipients.isEmpty
                            ? 'To'
                            : 'Add more',
                        excludeIds: controller.recipientIds,
                        onContactSelected: (contact) {
                          controller.addRecipientFromContact(contact);
                        },
                        onManualInput: (input) {
                          controller.addRecipient(input);
                        },
                        onSubmitted: _handleToSubmit,
                      ),
                    ),
                  ],
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
              _buildQuillToolbar(context),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: QuillEditor(
                    controller: quillController,
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    config: QuillEditorConfig(
                      placeholder: 'Compose email',
                      expands: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
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
      document: quillController.document,
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

  Widget _buildQuillToolbar(BuildContext context) {
    final iconTheme = QuillIconTheme(
      iconButtonSelectedData: IconButtonData(
        color: Theme.of(context).colorScheme.primary,
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      iconButtonUnselectedData: const IconButtonData(),
    );

    return QuillSimpleToolbar(
      controller: quillController,
      config: QuillSimpleToolbarConfig(
        buttonOptions: QuillSimpleToolbarButtonOptions(
          bold: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          italic: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          underLine: QuillToolbarToggleStyleButtonOptions(iconTheme: iconTheme),
          strikeThrough: QuillToolbarToggleStyleButtonOptions(
            iconTheme: iconTheme,
          ),
          listNumbers: QuillToolbarToggleStyleButtonOptions(
            iconTheme: iconTheme,
          ),
          listBullets: QuillToolbarToggleStyleButtonOptions(
            iconTheme: iconTheme,
          ),
        ),
        showAlignmentButtons: false,
        showBackgroundColorButton: false,
        showCenterAlignment: false,
        showClearFormat: false,
        showCodeBlock: false,
        showColorButton: false,
        showDirection: false,
        showFontFamily: false,
        showFontSize: false,
        showHeaderStyle: false,
        showIndent: false,
        showInlineCode: false,
        showJustifyAlignment: false,
        showLeftAlignment: false,
        showListBullets: true,
        showListCheck: false,
        showListNumbers: true,
        showQuote: false,
        showRightAlignment: false,
        showSearchButton: false,
        showSmallButton: false,
        showStrikeThrough: true,
        showSubscript: false,
        showSuperscript: false,
        showUndo: false,
        showRedo: false,
        showClipboardCopy: false,
        showClipboardCut: false,
        showClipboardPaste: false,
        multiRowsDisplay: false,
      ),
    );
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
