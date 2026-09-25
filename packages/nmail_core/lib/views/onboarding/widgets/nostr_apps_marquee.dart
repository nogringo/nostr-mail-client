import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/nostr_apps_marquee_controller.dart';
import 'package:nmail_core/models/showcased_nostr_app.dart';
import 'nostr_app_tile.dart';

class NostrAppsMarquee extends StatelessWidget {
  const NostrAppsMarquee({super.key});

  static const _copies = 2;

  @override
  Widget build(BuildContext context) {
    final maxWidthWithoutDuplicates =
        NostrAppTile.width * (ShowcasedNostrApp.all.length - 1);

    return GetBuilder<NostrAppsMarqueeController>(
      init: NostrAppsMarqueeController(copies: _copies),
      global: false,
      builder: (controller) => ConstrainedBox(
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
            controller: controller.scrollController,
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
      ),
    );
  }
}
