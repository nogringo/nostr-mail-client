import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/nostr_apps_marquee_controller.dart';
import 'package:nmail_core/models/showcased_nostr_app.dart';
import 'nostr_app_tile.dart';

class NostrAppsMarquee extends StatefulWidget {
  const NostrAppsMarquee({super.key});

  @override
  State<NostrAppsMarquee> createState() => _NostrAppsMarqueeState();
}

class _NostrAppsMarqueeState extends State<NostrAppsMarquee>
    with SingleTickerProviderStateMixin {
  static const _copies = 2;

  late final _controller = NostrAppsMarqueeController(
    copies: _copies,
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidthWithoutDuplicates =
        NostrAppTile.width * (ShowcasedNostrApp.all.length - 1);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidthWithoutDuplicates),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0, 0.1, 0.9, 1],
        ).createShader(bounds),
        child: SingleChildScrollView(
          controller: _controller.scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var copy = 0; copy < _copies; copy++)
                for (final app in ShowcasedNostrApp.all)
                  ExcludeSemantics(
                    excluding: copy > 0,
                    child: NostrAppTile(app: app),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
