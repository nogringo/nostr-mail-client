import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/utils/blossom_utils.dart';
import 'package:nmail_core/utils/media_metadata/strip_media_metadata.dart';
import 'package:nmail_core/widgets/background_preset_visual.dart';

/// Publishes the current appearance as a community theme.
class ShareThemeController extends ChangeNotifier {
  ShareThemeController({required this.brightness}) {
    titleController.addListener(notifyListeners);
  }

  /// The scheme on screen, the only one a theme can carry.
  final Brightness brightness;

  final titleController = TextEditingController();
  bool isPublishing = false;
  bool _isNsfw = false;
  bool _isDisposed = false;

  String get title => titleController.text.trim();

  bool get isNsfw => _isNsfw;
  set isNsfw(bool value) {
    _isNsfw = value;
    notifyListeners();
  }

  SettingsController get _settings => GetIt.I<SettingsController>();

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
  void dispose() {
    _isDisposed = true;
    titleController.dispose();
    super.dispose();
  }

  /// Throws when the background cannot be queued or the signature fails.
  Future<void> publish() async {
    isPublishing = true;
    notifyListeners();
    try {
      final ndk = GetIt.I<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final unsigned = Nip01Event(
        pubKey: account.pubkey,
        kind: CommunityTheme.kind,
        tags: CommunityTheme.eventTags(
          identifier: CommunityTheme.newIdentifier(title),
          title: title,
          seedColor: _seedColor,
          variant: _settings.paletteStyle.value,
          brightness: brightness,
          image: await _uploadBackground(account.pubkey),
          contentWarning: _isNsfw ? 'NSFW' : null,
        ),
        content: '',
      );
      final signed = await account.signer.sign(unsigned);
      await ndk.config.cache.saveEvent(signed);
      // The outbox alone would miss the relays the themes page reads.
      await GetIt.I<OfflineBroadcast>().broadcast(
        signed,
        relaySet: UrlSet.union([
          UrlSet.explicit(NostrConfig.communityThemeRelays),
          UrlSet.outbox(account.pubkey),
        ]),
        pubkey: account.pubkey,
      );

      final theme = CommunityTheme.fromEvent(signed)!;
      GetIt.I<CommunityThemesController>().showPublished(theme);
      await _settings.markCommunityTheme(theme.address);
    } finally {
      if (!_isDisposed) {
        isPublishing = false;
        notifyListeners();
      }
    }
  }

  Future<({String url, String type})?> _uploadBackground(String pubkey) async {
    final bytes = await _backgroundBytes();
    if (bytes == null) return null;

    final data = stripMediaMetadata(bytes);
    final type = lookupMimeType('', headerBytes: data);
    if (type == null || !type.startsWith('image/')) {
      throw StateError('Unknown background image type');
    }

    final serverSet = UrlSet.fallback([
      UrlSet.blossom(pubkey),
      UrlSet.explicit(NostrConfig.recommendedBlossomServers),
    ]);
    // Cache only: the queue resolves the set again when it uploads.
    final server = switch (await resolveUrlSet(
      serverSet,
      ndkUrlListFn(GetIt.I<Ndk>(), offline: true),
    )) {
      UrlsResolved(:final urls) when urls.isNotEmpty => urls.first,
      _ => NostrConfig.recommendedBlossomServers.first,
    };
    final blob = await GetIt.I<BlossomCache>().put(data, type: type);
    await GetIt.I<OfflineBlossomUpload>().upload(
      sha256: blob.sha256,
      serverSet: UrlSet.union([
        serverSet,
        UrlSet.explicit([server]),
      ]),
      contentType: type,
      pubkey: pubkey,
    );
    return (url: blossomBlobUrl(server, blob.sha256, type), type: type);
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
