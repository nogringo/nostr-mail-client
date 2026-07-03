import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../controllers/about_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.put(AboutController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l.settingsVersion),
          subtitle: Obx(
            () => Text(
              controller.version.value.isEmpty ? '-' : controller.version.value,
            ),
          ),
        ),
        ListTile(
          leading: SvgPicture.asset(
            'icons/github.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              IconTheme.of(context).color ??
                  Theme.of(context).colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          title: Text(l.settingsSourceCode),
          subtitle: Text(l.settingsSourceCodeSubtitle),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => launchUrl(Uri.parse(AppConfig.sourceCodeUrl)),
        ),
        ListTile(
          leading: const Icon(Icons.construction_rounded),
          title: Text(l.settingsEarlyAccess),
          subtitle: Text(l.settingsEarlyAccessMessage),
          isThreeLine: true,
        ),
      ],
    );
  }
}
