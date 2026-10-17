import 'package:flutter/material.dart';

/// Label above a settings group, with an optional line saying what the group
/// configures.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    super.key,
    required String this.title,
    this.description,
  }) : titleSpan = null,
       descriptionSpan = null;

  const SettingsSectionHeader.rich({
    super.key,
    required InlineSpan this.titleSpan,
    this.descriptionSpan,
  }) : title = null,
       description = null;

  final String? title;
  final String? description;
  final InlineSpan? titleSpan;
  final InlineSpan? descriptionSpan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = descriptionSpan ?? _span(this.description);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            titleSpan ?? TextSpan(text: title),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text.rich(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static InlineSpan? _span(String? text) =>
      text == null ? null : TextSpan(text: text);
}
