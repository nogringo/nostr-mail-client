import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../app/config/app_config.dart';
import '../../../app/config/distribution_config.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'about_link_tile.dart';

class AboutLinksList extends StatelessWidget {
  const AboutLinksList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final distributionConfig = Get.find<DistributionConfig>();
    final hasPrivacyPolicy = distributionConfig.hasPrivacyPolicyUrl;
    final count = hasPrivacyPolicy ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AboutLinkTile(
          leading: SvgPicture.asset(
            'icons/github.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              IconTheme.of(context).color ?? theme.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          title: l.settingsSourceCode,
          subtitle: l.settingsSourceCodeSubtitle,
          url: AppConfig.sourceCodeUrl,
          index: 0,
          count: count,
        ),
        AboutLinkTile(
          leading: const Icon(Icons.balance),
          title: l.settingsLicense,
          subtitle: AppConfig.licenseName,
          url: AppConfig.licenseUrl,
          index: 1,
          count: count,
        ),
        if (hasPrivacyPolicy)
          AboutLinkTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: l.settingsPrivacyPolicy,
            subtitle: l.settingsPrivacyPolicySubtitle,
            url: distributionConfig.privacyPolicyUrl!,
            index: 2,
            count: count,
          ),
      ],
    );
  }
}
