import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../utils/platform_helper.dart';
import '../../utils/responsive_helper.dart';
import '../inbox/widgets/app_drawer.dart';
import '../inbox/widgets/app_sidebar.dart';
import 'layout_constants.dart';
import 'left_rail.dart';

class DesktopShell extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const DesktopShell({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  Widget _buildBackground(BuildContext context) {
    return Obx(() {
      final image = Get.find<SettingsController>().backgroundImage.value;

      if (image != null && image.isNotEmpty) {
        // Native: local file path
        if (PlatformHelper.isNative) {
          final file = File(image);
          if (file.existsSync()) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          }
        } else {
          // Web: URL
          return Image.network(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => Container(
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
          );
        }
      }

      return Container(color: Theme.of(context).colorScheme.tertiaryContainer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveHelper.isNotMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isDesktop = PlatformHelper.isDesktop;

    if (isWide) {
      Widget content = Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(context),
            Padding(
              padding: EdgeInsets.only(
                top: isDesktop ? LayoutConstants.windowCaptionHeight : 0,
              ),
              child: Row(
                children: [
                  const LeftRail(),
                  Padding(
                    padding: EdgeInsets.only(
                      top: isDesktop ? 0 : LayoutConstants.shellPadding,
                      bottom: LayoutConstants.shellPadding,
                    ),
                    child: Container(
                      width: LayoutConstants.sidebarWidth,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                            LayoutConstants.borderRadius,
                          ),
                          bottomLeft: Radius.circular(
                            LayoutConstants.borderRadius,
                          ),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const AppSidebar(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: isDesktop ? 0 : LayoutConstants.shellPadding,
                      bottom: LayoutConstants.shellPadding,
                    ),
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: isDesktop ? 0 : LayoutConstants.shellPadding,
                        right: LayoutConstants.shellPadding,
                        bottom: LayoutConstants.shellPadding,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(
                              LayoutConstants.borderRadius,
                            ),
                            bottomRight: Radius.circular(
                              LayoutConstants.borderRadius,
                            ),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      return content;
    }

    // Mobile layout with drawer
    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [_buildBackground(context), body],
      ),
    );
  }
}
