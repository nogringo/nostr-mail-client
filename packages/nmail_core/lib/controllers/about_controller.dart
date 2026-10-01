import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class AboutController extends GetxController {
  static const _tapsToUnlockDebugTools = 7;

  final version = ''.obs;
  var _versionTaps = 0;

  @override
  void onInit() {
    super.onInit();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version.value = info.version;
  }

  void onVersionTap(BuildContext context) {
    final settings = Get.find<SettingsController>();
    if (settings.debugToolsUnlocked.value) return;
    if (++_versionTaps < _tapsToUnlockDebugTools) return;

    settings.unlockDebugTools();
    ToastHelper.success(
      context,
      AppLocalizations.of(context).aboutDebugToolsUnlocked,
    );
  }
}
