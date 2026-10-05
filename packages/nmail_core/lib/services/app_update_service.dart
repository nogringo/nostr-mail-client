import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/config/app_config.dart';
import '../app/config/distribution_config.dart';
import '../models/app_release.dart';
import '../utils/reload_page/reload_page.dart';
import '../utils/version_utils.dart';

/// Where the running build gets its updates from.
enum UpdateSource { web, playStore, zapStore, github }

/// Polls the latest GitHub release, whatever the install channel: stores lag
/// behind it for a while, which is accepted.
class AppUpdateService {
  AppUpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const _latestReleaseUrl =
      'https://api.github.com/repos/${AppConfig.githubRepository}/releases/latest';
  static const _checkInterval = Duration(hours: 6);

  final http.Client _client;
  Timer? _timer;
  PackageInfo? _packageInfo;

  /// The latest release when it is newer than the running build, else null.
  final availableUpdate = ValueNotifier<AppRelease?>(null);

  UpdateSource get source {
    if (kIsWeb) return UpdateSource.web;
    if (GetIt.I<DistributionConfig>().distribution == Distribution.zapstore) {
      return UpdateSource.zapStore;
    }
    if (_packageInfo?.installerStore == 'com.android.vending') {
      return UpdateSource.playStore;
    }
    return UpdateSource.github;
  }

  void start() {
    // No App Store link to send iOS users to yet.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return;
    unawaited(check());
    _timer = Timer.periodic(_checkInterval, (_) => check());
  }

  void dispose() {
    _timer?.cancel();
    _client.close();
    availableUpdate.dispose();
  }

  Future<void> check() async {
    try {
      _packageInfo ??= await PackageInfo.fromPlatform();
      final response = await _client.get(
        Uri.parse(_latestReleaseUrl),
        headers: {'Accept': 'application/vnd.github+json'},
      );
      if (response.statusCode != 200) return;

      final release = AppRelease.fromGithubJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      availableUpdate.value =
          isNewerVersion(release.version, _packageInfo!.version)
          ? release
          : null;
    } catch (error) {
      debugPrint('Update check failed: $error');
    }
  }

  Future<void> openUpdate() async {
    final release = availableUpdate.value;
    if (release == null) return;

    final packageName = _packageInfo!.packageName;
    final url = switch (source) {
      UpdateSource.web => null,
      UpdateSource.playStore =>
        'https://play.google.com/store/apps/details?id=$packageName',
      UpdateSource.zapStore => 'https://zapstore.dev/apps/$packageName',
      UpdateSource.github => release.url,
    };
    if (url == null) return reloadPage();

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
