import 'package:flutter/material.dart';

class AboutDistributionChip extends StatelessWidget {
  const AboutDistributionChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: const Text('FOSS'),
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      backgroundColor: colorScheme.secondaryContainer,
      shape: const StadiumBorder(),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
