import 'package:nmail_core/l10n/generated/app_localizations.dart';

class ShowcasedNostrApp {
  const ShowcasedNostrApp({
    required this.name,
    required this.assetPath,
    required this.usage,
  });

  static const packageName = 'nmail_core';

  final String name;
  final String assetPath;
  final String Function(AppLocalizations l) usage;

  static final all = <ShowcasedNostrApp>[
    ShowcasedNostrApp(
      name: 'Nmail',
      assetPath: 'assets/nostr_apps/nmail.webp',
      usage: (l) => l.onboardingAppUsageEmail,
    ),
    ShowcasedNostrApp(
      name: 'Wisp',
      assetPath: 'assets/nostr_apps/wisp.webp',
      usage: (l) => l.onboardingAppUsageSocial,
    ),
    ShowcasedNostrApp(
      name: 'YakiHonne',
      assetPath: 'assets/nostr_apps/yakihonne.webp',
      usage: (l) => l.onboardingAppUsageArticles,
    ),
    ShowcasedNostrApp(
      name: 'diVine',
      assetPath: 'assets/nostr_apps/divine.webp',
      usage: (l) => l.onboardingAppUsageShortVideos,
    ),
    ShowcasedNostrApp(
      name: 'Wavlake',
      assetPath: 'assets/nostr_apps/wavlake.webp',
      usage: (l) => l.onboardingAppUsageMusic,
    ),
    ShowcasedNostrApp(
      name: 'White Noise',
      assetPath: 'assets/nostr_apps/white_noise.webp',
      usage: (l) => l.onboardingAppUsageMessaging,
    ),
    ShowcasedNostrApp(
      name: 'HiveTalk',
      assetPath: 'assets/nostr_apps/hivetalk.webp',
      usage: (l) => l.onboardingAppUsageVideoCalls,
    ),
    ShowcasedNostrApp(
      name: 'Primal',
      assetPath: 'assets/nostr_apps/primal.webp',
      usage: (l) => l.onboardingAppUsageSocial,
    ),
    ShowcasedNostrApp(
      name: 'Zapstore',
      assetPath: 'assets/nostr_apps/zapstore.webp',
      usage: (l) => l.onboardingAppUsageAppStore,
    ),
    ShowcasedNostrApp(
      name: 'zap.stream',
      assetPath: 'assets/nostr_apps/zap_stream.webp',
      usage: (l) => l.onboardingAppUsageLiveStreaming,
    ),
    ShowcasedNostrApp(
      name: 'Flotilla',
      assetPath: 'assets/nostr_apps/flotilla.webp',
      usage: (l) => l.onboardingAppUsageCommunities,
    ),
    ShowcasedNostrApp(
      name: 'Coinos',
      assetPath: 'assets/nostr_apps/coinos.webp',
      usage: (l) => l.onboardingAppUsagePayments,
    ),
  ];
}
