import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nmail_core/controllers/compose_controller.dart';

class QuillToolbarView extends StatelessWidget {
  const QuillToolbarView({super.key});

  @override
  Widget build(BuildContext context) {
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
      controller: ComposeController.to.quillController,
      config: QuillSimpleToolbarConfig(
        buttonOptions: QuillSimpleToolbarButtonOptions(
          bold: _toggleOptions(
            label: (loc) => loc.bold,
            icon: Icons.format_bold,
            iconTheme: iconTheme,
          ),
          italic: _toggleOptions(
            label: (loc) => loc.italic,
            icon: Icons.format_italic,
            iconTheme: iconTheme,
          ),
          underLine: _toggleOptions(
            label: (loc) => loc.underline,
            icon: Icons.format_underline,
            iconTheme: iconTheme,
          ),
          strikeThrough: _toggleOptions(
            label: (loc) => loc.strikeThrough,
            icon: Icons.format_strikethrough,
            iconTheme: iconTheme,
          ),
          listNumbers: _toggleOptions(
            label: (loc) => loc.numberedList,
            icon: Icons.format_list_numbered,
            iconTheme: iconTheme,
          ),
          listBullets: _toggleOptions(
            label: (loc) => loc.bulletList,
            icon: Icons.format_list_bulleted,
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

  QuillToolbarToggleStyleButtonOptions _toggleOptions({
    required String Function(FlutterQuillLocalizations loc) label,
    required IconData icon,
    required QuillIconTheme iconTheme,
  }) {
    return QuillToolbarToggleStyleButtonOptions(
      childBuilder: (dynamic options, dynamic extraOptions) {
        final extra = extraOptions as QuillToolbarToggleStyleButtonExtraOptions;
        final loc = FlutterQuillLocalizations.of(extra.context)!;
        return QuillToolbarIconButton(
          icon: Icon(icon),
          isSelected: extra.isToggled,
          onPressed: extra.onPressed,
          iconTheme: iconTheme,
          tooltip: label(loc),
        );
      },
    );
  }
}
