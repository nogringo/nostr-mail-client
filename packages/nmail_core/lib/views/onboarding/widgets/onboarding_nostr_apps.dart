import 'package:flutter/material.dart';

import 'package:nmail_core/models/showcased_nostr_app.dart';
import 'nostr_app_tile.dart';
import 'nostr_apps_marquee.dart';

class OnboardingNostrApps extends StatelessWidget {
  const OnboardingNostrApps({super.key});

  @override
  Widget build(BuildContext context) {
    if (!MediaQuery.disableAnimationsOf(context)) {
      return const NostrAppsMarquee();
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: NostrAppTile.width * 4,
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 16,
          children: [
            for (final app in ShowcasedNostrApp.all) NostrAppTile(app: app),
          ],
        ),
      ),
    );
  }
}
