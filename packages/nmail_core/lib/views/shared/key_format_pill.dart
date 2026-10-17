import 'package:flutter/material.dart';

import 'package:nmail_core/models/local_part_format.dart';

/// Stands in for the key of a key address, so the format does not read as
/// the literal local part.
class KeyFormatPill extends StatelessWidget {
  const KeyFormatPill({super.key, required this.format});

  final LocalPartFormat format;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 2),
      child: Badge(
        label: Text(format.name),
        backgroundColor: colorScheme.secondaryContainer,
        textColor: colorScheme.onSecondaryContainer,
        largeSize: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}
