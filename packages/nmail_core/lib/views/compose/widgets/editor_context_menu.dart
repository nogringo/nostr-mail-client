import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/views/shared/show_context_menu.dart';

/// The browser menu is disabled on the web and flutter_quill shows none there.
class EditorContextMenu extends StatelessWidget {
  const EditorContextMenu({
    super.key,
    required this.controller,
    required this.child,
  });

  final ComposeController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Listener(
      onPointerDown: (event) {
        if (event.buttons & kSecondaryMouseButton == 0) return;
        _showMenu(context, event.position);
      },
      child: child,
    );
  }

  Future<void> _showMenu(BuildContext context, Offset position) {
    final quill = controller.quillController;
    final hasSelection = !quill.selection.isCollapsed;
    final labels = MaterialLocalizations.of(context);
    final isApple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    SingleActivator shortcut(LogicalKeyboardKey key) =>
        SingleActivator(key, meta: isApple, control: !isApple);

    return showContextMenu(
      context,
      position: position,
      children: (menuContext) {
        VoidCallback run(VoidCallback action) => () {
          Navigator.of(menuContext).pop();
          action();
        };
        return [
          MenuItemButton(
            onPressed: hasSelection
                ? run(() => quill.clipboardSelection(false))
                : null,
            shortcut: shortcut(LogicalKeyboardKey.keyX),
            child: Text(labels.cutButtonLabel),
          ),
          MenuItemButton(
            onPressed: hasSelection
                ? run(() => quill.clipboardSelection(true))
                : null,
            shortcut: shortcut(LogicalKeyboardKey.keyC),
            child: Text(labels.copyButtonLabel),
          ),
          MenuItemButton(
            onPressed: run(controller.pasteFromClipboard),
            shortcut: shortcut(LogicalKeyboardKey.keyV),
            child: Text(labels.pasteButtonLabel),
          ),
          const Divider(height: 1),
          MenuItemButton(
            onPressed: run(
              () => quill.updateSelection(
                TextSelection(
                  baseOffset: 0,
                  extentOffset: quill.document.length - 1,
                ),
                ChangeSource.local,
              ),
            ),
            shortcut: shortcut(LogicalKeyboardKey.keyA),
            child: Text(labels.selectAllButtonLabel),
          ),
        ];
      },
    );
  }
}
