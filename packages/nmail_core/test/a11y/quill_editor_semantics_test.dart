import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nmail_core/views/compose/widgets/quill_editor_semantics.dart';

void main() {
  testWidgets('a focused editor is the only focused node, as a text field', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = QuillController.basic();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditorSemantics(
            controller: controller,
            focusNode: focusNode,
            child: QuillEditor.basic(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();

    // Flutter web moves the DOM focus to each focused node in turn.
    final focused = find.semantics.byPredicate(
      (node) =>
          node.getSemanticsData().flagsCollection.isFocused == Tristate.isTrue,
    );
    expect(focused, findsOne);
    expect(
      focused.evaluate().single.getSemanticsData().flagsCollection.isTextField,
      isTrue,
    );
    handle.dispose();
  });
}
