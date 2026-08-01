import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nmail_core/utils/segmented_list_shape.dart';

class AboutLinkTile extends StatelessWidget {
  const AboutLinkTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.index,
    required this.count,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String url;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: 72,
        leading: leading,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => launchUrl(Uri.parse(url)),
      ),
    );
  }
}
