import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nmail_core/app/config/distribution_config.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/platform_helper.dart';

class UnifiedPushDistributorHelpTile extends StatefulWidget {
  const UnifiedPushDistributorHelpTile({super.key});

  @override
  State<UnifiedPushDistributorHelpTile> createState() =>
      _UnifiedPushDistributorHelpTileState();
}

class _UnifiedPushDistributorHelpTileState
    extends State<UnifiedPushDistributorHelpTile>
    with WidgetsBindingObserver {
  Future<bool> _hasDistributorFuture = Future<bool>.value(true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshDistributorState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(_refreshDistributorState);
    }
  }

  void _refreshDistributorState() {
    final config = Get.find<DistributionConfig>();
    _hasDistributorFuture =
        config.hasUnifiedPushDistributor?.call() ?? Future<bool>.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformHelper.isAndroid) return const SizedBox.shrink();

    final config = Get.find<DistributionConfig>();
    if (!config.canCheckUnifiedPushDistributor) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: _hasDistributorFuture,
      builder: (context, snapshot) {
        final hasDistributor = snapshot.data ?? true;
        if (hasDistributor) return const SizedBox.shrink();

        final l = AppLocalizations.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notifications_paused_outlined,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.settingsUnifiedPushDistributorMissingTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.settingsUnifiedPushDistributorMissingSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(config.unifiedPushDistributorInstallUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(
                            l.settingsUnifiedPushDistributorInstallSunup,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
