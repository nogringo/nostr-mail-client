import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// Native builds keep a gallery of background files on disk. Web has nowhere
/// to put them, so it holds a single URL, pasted or uploaded to Blossom.
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

  Future<void> select(String? path) => _settings.setBackgroundImage(path);

  Future<PlatformFile?> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: !PlatformHelper.isNative,
    );
    return result?.files.single;
  }

  Future<void> addPickedImage(BuildContext context, PlatformFile picked) {
    return PlatformHelper.isNative
        ? _copyToGallery(context, picked)
        : _uploadToBlossom(context, picked);
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
      stream.addListener(
        ImageStreamListener(
          (_, _) => completer.complete(),
          onError: (error, _) => completer.completeError(error),
        ),
      );
      await completer.future.timeout(const Duration(seconds: 10));

      await select(url);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundUrlError);
      }
    } finally {
      if (!isClosed) isBusy.value = false;
    }
  }

  // TODO: encrypt the image before upload, decrypt on display
  Future<void> _uploadToBlossom(
    BuildContext context,
    PlatformFile picked,
  ) async {
    final bytes = picked.bytes;
    if (bytes == null) return;

    final l = AppLocalizations.of(context);
    isBusy.value = true;

    try {
      final userServers = await Get.find<NostrMailService>()
          .getBlossomServers();
      final results = await Get.find<Ndk>().blossom.uploadBlob(
        data: bytes,
        contentType: picked.extension != null
            ? 'image/${picked.extension}'
            : null,
        serverUrls: userServers.isNotEmpty
            ? userServers
            : NostrConfig.recommendedBlossomServers,
      );

      final uploaded = results
          .where((result) => result.success && result.descriptor != null)
          .toList();

      if (uploaded.isEmpty) {
        if (context.mounted) {
          final error = results.isEmpty ? null : results.first.error;
          ToastHelper.error(context, error ?? l.profileUploadFailed);
        }
        return;
      }

      await select(uploaded.first.descriptor!.url);
    } catch (e) {
      if (context.mounted) ToastHelper.error(context, e.toString());
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
