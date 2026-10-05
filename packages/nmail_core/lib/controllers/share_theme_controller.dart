import 'package:blossom_cache/blossom_cache.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FirstWhereExt;
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:ndk/ndk.dart' hide RelaySet;

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/media_metadata/strip_media_metadata.dart';
import 'package:nmail_core/widgets/background_preset_visual.dart';

/// Publishes the current appearance as a community theme.
class ShareThemeController extends GetxController {
  ShareThemeController({required this.brightness});

  /// The scheme on screen, the only one a theme can carry.
  final Brightness brightness;

  final titleController = TextEditingController();
  final title = ''.obs;
  final isNsfw = false.obs;
  final isPublishing = false.obs;

  SettingsController get _settings => Get.find<SettingsController>();

  Color get _seedColor => brightness == Brightness.dark
      ? _settings.darkSeedColor.value
      : _settings.lightSeedColor.value;

  ColorScheme get colorScheme => ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
    dynamicSchemeVariant: _settings.paletteStyle.value,
  );

  String? get _background => _settings.backgroundImage.value;

  /// The preset on screen, a bundled image or painted by the app.
  BackgroundPresetVariant? get presetVariant =>
      BackgroundPreset.resolve(_background)?.variantForBrightness(brightness);

  ImageProvider? get customImage {
    final background = _background;
    return BackgroundPreset.isCustomImageValue(background)
        ? BackgroundPreset.customImage(background!)
        : null;
  }

  /// False only for a plain color background.
  bool get hasBackgroundImage => presetVariant != null || customImage != null;

  @override
  void onInit() {
    super.onInit();
    titleController.addListener(
      () => title.value = titleController.text.trim(),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  /// Throws when the background upload or the signature fails.
  Future<void> publish() async {
    isPublishing.value = true;
    try {
      final ndk = GetIt.I<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final unsigned = Nip01Event(
        pubKey: account.pubkey,
        kind: CommunityTheme.kind,
        tags: CommunityTheme.eventTags(
          identifier: CommunityTheme.newIdentifier(title.value),
          title: title.value,
          seedColor: _seedColor,
          variant: _settings.paletteStyle.value,
          brightness: brightness,
          image: await _uploadBackground(),
          contentWarning: isNsfw.value ? 'NSFW' : null,
        ),
        content: '',
      );
      final signed = await account.signer.sign(unsigned);
      await ndk.config.cache.saveEvent(signed);
      // The outbox alone would miss the relays the themes page reads.
      await GetIt.I<OfflineBroadcast>().broadcast(
        signed,
        relaySet: RelaySet.union([
          RelaySet.explicit(NostrConfig.communityThemeRelays),
          RelaySet.outbox(account.pubkey),
        ]),
        pubkey: account.pubkey,
      );

      final theme = CommunityTheme.fromEvent(signed)!;
      GetIt.I<CommunityThemesController>().showPublished(theme);
      await _settings.markCommunityTheme(theme.address);
    } finally {
      if (!isClosed) isPublishing.value = false;
    }
  }

  Future<({String url, String type})?> _uploadBackground() async {
    final bytes = await _backgroundBytes();
    if (bytes == null) return null;

    final data = stripMediaMetadata(bytes);
    final type = lookupMimeType('', headerBytes: data);
    if (type == null || !type.startsWith('image/')) {
      throw StateError('Unknown background image type');
    }

    final userServers = await Get.find<NostrMailService>().getBlossomServers();
    final results = await GetIt.I<Ndk>().blossom.uploadBlob(
      data: data,
      contentType: type,
      serverUrls: userServers.isNotEmpty
          ? userServers
          : NostrConfig.recommendedBlossomServers,
    );
    final uploaded = results.firstWhereOrNull(
      (result) => result.success && result.descriptor != null,
    );
    if (uploaded == null) throw StateError('Background upload failed');
    return (url: uploaded.descriptor!.url, type: type);
  }

  Future<Uint8List?> _backgroundBytes() async {
    final sha256 = BackgroundPreset.cachedImageSha256(_background);
    if (sha256 != null) {
      final bytes = await GetIt.I<BlossomCache>().get(sha256);
      if (bytes == null) throw StateError('Background image not in cache');
      return bytes;
    }

    final variant = presetVariant;
    if (variant == null) return null;
    final asset = variant.assetPath;
    if (asset == null) return renderBackgroundPreset(variant);
    final data = await rootBundle.load(
      'packages/${BackgroundPreset.packageName}/$asset',
    );
    return data.buffer.asUint8List();
  }
}
