import 'package:flutter/material.dart';

/// Builds one row of a [SettingsGroup], given the position it ended up at so it
/// can pick the matching segmented shape.
typedef SettingsRowBuilder = Widget Function(int index, int count);

/// Card-like group of settings rows sharing one rounded outline.
///
/// Rows are passed as builders so conditional entries stay declarative and the
/// index/count bookkeeping the segmented shape needs never drifts.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.rows});

  final List<SettingsRowBuilder> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed) row(index, rows.length),
      ],
    );
  }
}
