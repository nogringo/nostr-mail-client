import 'dart:async';
import 'dart:io';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/services/account_local_data_service.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// Native builds keep a gallery of background files on disk. Web holds a
/// single image: a picked file kept in the Blossom cache, or a pasted URL.
class BackgroundsController extends GetxController {
  final savedImages = <File>[].obs;
  final isBusy = false.obs;

  SettingsController get _settings => Get.find<SettingsController>();

  @override
  void onInit() {
    super.onInit();
    loadSavedImages();
  }

  Future<void> loadSavedImages() async {
    if (!PlatformHelper.isNative) return;

    try {
      final dir = await _backgroundsDir();
      final files = await dir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      if (isClosed) return;
      savedImages.value = files;
    } catch (_) {
      if (!isClosed) savedImages.clear();
    }
  }

  Future<void> select(String? value) async {
    final previous = _settings.backgroundImage.value;
    await _settings.setBackgroundImage(value);
    if (previous != value) {
      await Get.find<AccountLocalDataService>().releaseCachedBackground(
        previous,
      );
    }
  }

  Future<PlatformFile?> pickImage() =>
      FilePicker.pickFile(type: FileType.image);

  Future<void> addPickedImage(BuildContext context, PlatformFile picked) {
    return PlatformHelper.isNative
        ? _copyToGallery(context, picked)
        : _copyToCache(context, picked);
  }

  Future<void> addFromUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      await select(null);
      return;
    }

    await (PlatformHelper.isNative
        ? _downloadToGallery(context, url)
        : _selectRemoteUrl(context, url));
  }

  Future<void> deleteImage(BuildContext context, File file) async {
    final l = AppLocalizations.of(context);
    try {
      await file.delete();
      savedImages.removeWhere((saved) => saved.path == file.path);
      if (_settings.backgroundImage.value == file.path) await select(null);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundDeleteFailed);
      }
    }
  }

  Future<void> _copyToGallery(BuildContext context, PlatformFile picked) async {
    final l = AppLocalizations.of(context);
    final sourcePath = picked.path;
    if (sourcePath == null) return;

    try {
      final dir = await _backgroundsDir();
      final saved = await File(sourcePath).copy(p.join(dir.path, picked.name));
      savedImages.removeWhere((image) => image.path == saved.path);
      savedImages.insert(0, saved);
      await select(saved.path);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundCopyFailed);
      }
    }
  }

  Future<void> _downloadToGallery(BuildContext context, String url) async {
    final l = AppLocalizations.of(context);
    isBusy.value = true;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      var extension = url.split('.').last.split('?').first;
      if (extension.length > 4) {
        extension = response.headers['content-type']?.split('/').last ?? 'jpg';
      }

      final dir = await _backgroundsDir();
      final name = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final saved = File(p.join(dir.path, name));
      await saved.writeAsBytes(response.bodyBytes);

      savedImages.insert(0, saved);
      await select(saved.path);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundDownloadFailed);
      }
    } finally {
      if (!isClosed) isBusy.value = false;
    }
  }

  Future<void> _selectRemoteUrl(BuildContext context, String url) async {
    final l = AppLocalizations.of(context);
    isBusy.value = true;

    try {
      final completer = Completer<void>();
      final stream = NetworkImage(url).resolve(const ImageConfiguration());
      final listener = ImageStreamListener((image, _) {
        image.dispose();
        completer.complete();
      }, onError: (error, _) => completer.completeError(error));
      stream.addListener(listener);
      try {
        await completer.future.timeout(const Duration(seconds: 10));
      } finally {
        stream.removeListener(listener);
      }

      await select(url);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundUrlError);
      }
    } finally {
      if (!isClosed) isBusy.value = false;
    }
  }

  Future<void> _copyToCache(BuildContext context, PlatformFile picked) async {
    final l = AppLocalizations.of(context);
    isBusy.value = true;

    try {
      final blob = await Get.find<BlossomCache>().put(
        await picked.readAsBytes(),
        type: picked.extension != null ? 'image/${picked.extension}' : null,
        pinned: true,
      );
      await select(BackgroundPreset.cachedImageValue(blob.sha256));
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundCopyFailed);
      }
    } finally {
      if (!isClosed) isBusy.value = false;
    }
  }

  Future<Directory> _backgroundsDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(
      p.join(appDir.path, SettingsController.backgroundsDirName),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
