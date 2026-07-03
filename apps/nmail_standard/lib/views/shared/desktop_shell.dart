import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import '../../utils/responsive_helper.dart';
import '../inbox/widgets/app_drawer.dart';
import 'layouts/shell_desktop.dart';
import 'layouts/shell_fold.dart';
import 'layouts/shell_web.dart';

class DesktopShell extends StatelessWidget {
  final Widget body;

  const DesktopShell({super.key, required this.body});

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
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        }
      }

      return Container(color: Theme.of(context).colorScheme.primaryContainer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveHelper.isNotMobile(context);

    if (isWide) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(context),
            if (PlatformHelper.isDesktop)
              ShellDesktop(body: body)
            else if (kIsWeb)
              ShellWeb(body: body)
            else
              ShellFold(body: body),
          ],
        ),
      );
    }

    // Mobile layout with drawer
    return Scaffold(
      drawer: const AppDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [_buildBackground(context), body],
      ),
    );
  }
}
