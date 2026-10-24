import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../../compose/widgets/quill_editor_styles.dart';
import '../../compose/widgets/quill_toolbar_view.dart';
import 'signature_image_embed_builder.dart';

/// The rich text of the signature, framed like the name field above it.
class SignatureContentField extends StatelessWidget {
  final SignatureFormController controller;

  const SignatureContentField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller.editorFocusNode,
      builder: (context, _) => InputDecorator(
        isFocused: controller.editorFocusNode.hasFocus,
        decoration: InputDecoration(
          labelText: l.signatureContent,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        ),
        // The decorator would line the editor's first text baseline up with
        // a one-line field's, pushing the toolbar over the label.
        child: IgnoreBaseline(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuillToolbarView(
                controller: controller.quillController,
                color: Colors.transparent,
                showUnderline: false,
                showStrikeThrough: false,
                showLists: false,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.image_outlined),
                    tooltip: l.signatureAddImage,
                    onPressed: controller.pickImage,
                  ),
                ],
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 120),
                child: QuillEditor.basic(
                  controller: controller.quillController,
                  focusNode: controller.editorFocusNode,
                  config: QuillEditorConfig(
                    scrollable: false,
                    placeholder: l.signatureContentHint,
                    customStyles: quillEditorStyles(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    embedBuilders: [SignatureImageEmbedBuilder(controller)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
