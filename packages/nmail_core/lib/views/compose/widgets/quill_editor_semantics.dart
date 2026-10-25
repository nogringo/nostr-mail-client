import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// With semantics on, Flutter web types into the DOM field of the focused
/// text field node, and Quill builds none. Its own semantics are excluded
/// because its focus node would take the DOM focus from that field.
class QuillEditorSemantics extends StatelessWidget {
  const QuillEditorSemantics({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.child,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([focusNode, controller]),
      builder: (context, child) => Semantics(
        container: true,
        excludeSemantics: true,
        textField: true,
        multiline: true,
        enabled: true,
        focusable: true,
        focused: focusNode.hasFocus,
        onFocus: focusNode.requestFocus,
        value: controller.document.toPlainText(),
        child: child,
      ),
      child: child,
    );
  }
}
