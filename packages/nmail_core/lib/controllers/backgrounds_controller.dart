import 'dart:typed_data';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// The gallery of saved backgrounds, kept in the Blossom cache.
class BackgroundsController extends ChangeNotifier {
  BackgroundsController() {
    loadSavedImages();
  }

  static const _cachedGalleryKey = 'background_gallery';

  /// Newest first, as background values.
  final savedImages = <String>[];
  bool isBusy = false;

  bool _isDisposed = false;

  SettingsController get _settings => Get.find<SettingsController>();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadSavedImages() async {
    try {
      final images = await _listCachedGallery();
      if (_isDisposed) return;
      savedImages
        ..clear()
        ..addAll(images);
    } catch (_) {
      if (_isDisposed) return;
      savedImages.clear();
    }
    notifyListeners();
  }

  Future<void> select(String? value) => _settings.setBackgroundImage(value);

  Future<PlatformFile?> pickImage() =>
      FilePicker.pickFile(type: FileType.image);

  Future<void> addFromUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      await select(null);
      return;
    }

    await _downloadToCache(context, url);
  }

  Future<void> deleteImage(BuildContext context, String value) async {
    final l = AppLocalizations.of(context);
    try {
      await _deleteCachedImage(value);
      if (_settings.backgroundImage.value == value) await select(null);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundDeleteFailed);
      }
    }
  }

  Future<List<String>> _listCachedGallery() async {
    final cache = GetIt.I<BlossomCache>();
    final stored =
        await GetIt.I<StorageService>().getSetting<List>(_cachedGalleryKey) ??
        const [];

    // Removing an account deletes its background from the cache, not from
    // this list.
    final images = <String>[];
    for (final value in stored.cast<String>()) {
      final sha256 = BackgroundPreset.cachedImageSha256(value);
      if (sha256 != null && await cache.head(sha256) != null) {
        images.add(value);
      }
    }
    return images;
  }

  Future<void> _downloadToCache(BuildContext context, String url) async {
    final l = AppLocalizations.of(context);
    isBusy = true;
    notifyListeners();

    try {
      await select(await downloadToGallery(url));
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundUrlError);
      }
    } finally {
      if (!_isDisposed) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> addPickedImage(BuildContext context, PlatformFile picked) async {
    final l = AppLocalizations.of(context);
    isBusy = true;
    notifyListeners();

    try {
      await select(
        await _addToCachedGallery(
          await picked.readAsBytes(),
          picked.extension != null ? 'image/${picked.extension}' : null,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundCopyFailed);
      }
    } finally {
      if (!_isDisposed) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  /// Returns the background value of the saved image, without selecting it.
  Future<String> downloadToGallery(String url) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }
    (await decodeImageFromList(response.bodyBytes)).dispose();

    return _addToCachedGallery(
      response.bodyBytes,
      response.headers['content-type'],
    );
  }

  Future<String> _addToCachedGallery(Uint8List bytes, String? type) async {
    final blob = await GetIt.I<BlossomCache>().put(
      bytes,
      type: type,
      pinBy: BlossomCache.defaultHolder,
    );
    final value = BackgroundPreset.cachedImageValue(blob.sha256);
    savedImages.remove(value);
    savedImages.insert(0, value);
    notifyListeners();
    await _saveCachedGallery();
    return value;
  }

  Future<void> _deleteCachedImage(String value) async {
    final sha256 = BackgroundPreset.cachedImageSha256(value);
    if (sha256 != null) await GetIt.I<BlossomCache>().delete(sha256);
    savedImages.remove(value);
    notifyListeners();
    await _saveCachedGallery();
  }

  Future<void> _saveCachedGallery() {
    return GetIt.I<StorageService>().saveSetting(
      _cachedGalleryKey,
      savedImages.toList(),
    );
  }
}
