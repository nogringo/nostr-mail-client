import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Quill's default placeholder is larger than the text and not themed.
DefaultStyles quillEditorStyles(BuildContext context) {
  final paragraph = DefaultStyles.getInstance(context).paragraph!;
  return DefaultStyles(
    placeHolder: DefaultTextBlockStyle(
      paragraph.style.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      paragraph.horizontalSpacing,
      paragraph.verticalSpacing,
      paragraph.lineSpacing,
      null,
    ),
  );
}
