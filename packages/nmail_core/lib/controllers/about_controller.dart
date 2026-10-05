import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class AboutController extends ChangeNotifier {
  AboutController() {
    _loadVersion();
  }

  static const _tapsToUnlockDebugTools = 7;

  String version = '';
  var _versionTaps = 0;

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    notifyListeners();
  }

  void onVersionTap(BuildContext context) {
    final settings = GetIt.I<SettingsController>();
    if (settings.debugToolsUnlocked.value) return;
    if (++_versionTaps < _tapsToUnlockDebugTools) return;

    settings.unlockDebugTools();
    ToastHelper.success(
      context,
      AppLocalizations.of(context).aboutDebugToolsUnlocked,
    );
  }
}
