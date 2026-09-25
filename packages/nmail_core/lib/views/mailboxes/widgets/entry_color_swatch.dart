import 'package:flutter/material.dart';

/// One choice of [EntryColorPicker]. A null [color] is the automatic one.
class EntryColorSwatch extends StatelessWidget {
  final Color? color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const EntryColorSwatch({
    super.key,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _size = 36.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = this.color;
    final foreground = color == null
        ? colorScheme.onSurfaceVariant
        : ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        excludeSemantics: true,
        child: Material(
          color: color ?? colorScheme.surfaceContainerHighest,
          shape: CircleBorder(
            side: selected
                ? BorderSide(color: colorScheme.onSurface, width: 2)
                : BorderSide(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: _size,
              child: selected
                  ? Icon(Icons.check, color: foreground)
                  : color == null
                  ? Icon(Icons.auto_awesome_outlined, color: foreground)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
