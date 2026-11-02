import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/blossom_cache_image.dart';
import 'package:nmail_core/utils/blossom_utils.dart';
import 'package:nmail_core/utils/media_metadata/strip_media_metadata.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'auth_controller.dart';

class ProfileController extends ChangeNotifier {
  ProfileController() {
    final authController = GetIt.I<AuthController>();
    final metadata = authController.userMetadata.value;
    if (metadata != null) {
      _currentMetadata = metadata;
      nameController.text = metadata.name ?? '';
      displayNameController.text = metadata.displayName ?? '';
      pictureController.text = metadata.picture ?? '';
      aboutController.text = metadata.about ?? '';
      isLoading = false;
    }
    nameController.addListener(notifyListeners);
    displayNameController.addListener(notifyListeners);
    pictureController.addListener(notifyListeners);
    aboutController.addListener(notifyListeners);
    loadMetadata();
  }

  final nameController = TextEditingController();
  final displayNameController = TextEditingController();
  final pictureController = TextEditingController();
  final aboutController = TextEditingController();

  Metadata? _currentMetadata;
  bool isLoading = true;
  bool isSaving = false;
  bool showMoreOptions = false;
  ({String url, String sha256})? _pickedPicture;

  bool _isDisposed = false;

  /// Read from the cache: its upload may not be delivered yet.
  ImageProvider? get pickedPicture {
    final picked = _pickedPicture;
    if (picked == null || pictureController.text.trim() != picked.url) {
      return null;
    }
    return BlossomCacheImage(picked.sha256);
  }

  bool get hasChanges {
    final metadata = _currentMetadata;
    return nameController.text.trim() != (metadata?.name ?? '') ||
        displayNameController.text.trim() != (metadata?.displayName ?? '') ||
        pictureController.text.trim() != (metadata?.picture ?? '') ||
        aboutController.text.trim() != (metadata?.about ?? '');
  }

  @override
  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    displayNameController.dispose();
    pictureController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  void toggleMoreOptions() {
    showMoreOptions = !showMoreOptions;
    notifyListeners();
  }

  Future<void> loadMetadata() async {
    final authController = GetIt.I<AuthController>();
    final pubkey = authController.publicKey;
    if (pubkey == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final metadata = await GetIt.I<MetadataService>().load(pubkey);

      if (metadata != null) {
        authController.userMetadata.value = metadata;
        if (_isDisposed) return;
        _currentMetadata = metadata;
        nameController.text = metadata.name ?? '';
        displayNameController.text = metadata.displayName ?? '';
        pictureController.text = metadata.picture ?? '';
        aboutController.text = metadata.about ?? '';
      }
    } catch (e) {
      if (!_isDisposed) {
        final l = AppLocalizations.of(AppRouter.rootContext!);
        ToastHelper.error(AppRouter.rootContext!, l.profileLoadFailed);
      }
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> pickAndUploadPicture(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final file = await FilePicker.pickFile(
      dialogTitle: l.profileSelectPicture,
      type: FileType.image,
    );
    if (file == null || _isDisposed) return;

    try {
      final data = stripMediaMetadata(await file.readAsBytes());
      final type = lookupMimeType('', headerBytes: data);
      if (type == null || !type.startsWith('image/')) {
        throw StateError('Unknown picture type');
      }

      final pubkey = GetIt.I<AuthController>().publicKey!;
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
      if (_isDisposed) return;

      final url = blossomBlobUrl(server, blob.sha256, type);
      _pickedPicture = (url: url, sha256: blob.sha256);
      pictureController.text = url;
    } catch (e) {
      if (context.mounted) {
        ToastHelper.error(context, l.profileUploadError);
      }
    }
  }

  Future<void> saveProfile() async {
    final pubkey = GetIt.I<AuthController>().publicKey;
    if (pubkey == null) return;

    isSaving = true;
    notifyListeners();

    try {
      // Start from current object to preserve fields like banner, nip05, website, etc.
      final metadata = _currentMetadata ?? Metadata(pubKey: pubkey);

      // Update fields using setters
      final rawName = nameController.text.trim();
      metadata.name = rawName.isEmpty
          ? null
          : rawName.toLowerCase().replaceAll(' ', '');
      metadata.displayName = displayNameController.text.trim().isEmpty
          ? null
          : displayNameController.text.trim();
      metadata.picture = pictureController.text.trim().isEmpty
          ? null
          : pictureController.text.trim();
      metadata.about = aboutController.text.trim().isEmpty
          ? null
          : aboutController.text.trim();

      metadata.updatedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final ndk = GetIt.I<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final signed = await account.signer.sign(metadata.toEvent());
      await ndk.config.cache.saveEvent(signed);
      // Signaling event: broadcast widely (popular + indexers + outbox).
      await GetIt.I<OfflineBroadcast>().broadcast(
        signed,
        relaySet: UrlSet.union([
          UrlSet.explicit(
            {
              ...NostrConfig.popularRelays,
              ...NostrConfig.discoveryRelays,
            }.toList(),
          ),
          UrlSet.outbox(account.pubkey),
        ]),
        pubkey: account.pubkey,
      );

      // Metadata equality only compares the pubkey: cleared first to notify.
      final authController = GetIt.I<AuthController>();
      authController.userMetadata.value = null;
      authController.userMetadata.value = metadata;
      _currentMetadata = metadata;
    } catch (e) {
      if (!_isDisposed) {
        isSaving = false;
        notifyListeners();
        final l = AppLocalizations.of(AppRouter.rootContext!);
        ToastHelper.error(AppRouter.rootContext!, l.profileUpdateFailed);
      }
      return;
    }

    // Reached via `context.go`, so there is typically nothing to pop.
    final router = AppRouter.router;
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.inbox);
    }
  }
}
