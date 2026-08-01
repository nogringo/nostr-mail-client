import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutIconLinkButton extends StatelessWidget {
  const AboutIconLinkButton({
    super.key,
    required this.asset,
    required this.tooltip,
    required this.url,
  });

  final String asset;
  final String tooltip;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      icon: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          colorScheme.onSecondaryContainer,
          BlendMode.srcIn,
        ),
      ),
      tooltip: tooltip,
      onPressed: () => launchUrl(Uri.parse(url)),
    );
  }
}
