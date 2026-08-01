import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/about_controller.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// Top row of the identity group, joined to [AboutDeveloperTile] below it.
class AboutAppTile extends StatelessWidget {
  const AboutAppTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<AboutController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: theme.colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: 0, count: 2),
        minTileHeight: 72,
        leading: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'icons/original_transparent_2x.svg',
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSecondaryContainer,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text('Nmail', style: theme.textTheme.headlineMedium),
        subtitle: Obx(
          () => Text(
            controller.version.value,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
