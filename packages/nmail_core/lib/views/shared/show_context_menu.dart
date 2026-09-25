import 'package:flutter/material.dart';

/// Shows a desktop right-click menu at [position], kept inside the screen.
/// Completes with what an item pops the menu with.
Future<T?> showContextMenu<T>(
  BuildContext context, {
  required Offset position,
  required List<Widget> Function(BuildContext menuContext) children,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<T>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (menuContext) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(onTap: () => Navigator.of(menuContext).pop()),
        ),
        CustomSingleChildLayout(
          delegate: DesktopTextSelectionToolbarLayoutDelegate(anchor: position),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            surfaceTintColor: colorScheme.surfaceTint,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: children(menuContext),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
