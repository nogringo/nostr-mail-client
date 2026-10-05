import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart' hide RelaySet;

import 'package:nmail_core/config/nostr_config.dart';
import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/media_metadata/strip_media_metadata.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'auth_controller.dart';

class ProfileController extends ChangeNotifier {
  ProfileController() {
    final authController = Get.find<AuthController>();
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
  bool isUploadingPicture = false;
  bool showMoreOptions = false;

  bool _isDisposed = false;

  bool get hasChanges {
    final metadata = _currentMetadata;
    if (metadata == null) return true;

    return nameController.text.trim() != (metadata.name ?? '') ||
        displayNameController.text.trim() != (metadata.displayName ?? '') ||
        pictureController.text.trim() != (metadata.picture ?? '') ||
        aboutController.text.trim() != (metadata.about ?? '');
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
    final authController = Get.find<AuthController>();
    final pubkey = authController.publicKey;
    if (pubkey == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final metadata = await Get.find<MetadataService>().load(pubkey);

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

    isUploadingPicture = true;
    notifyListeners();

    try {
      final ndk = GetIt.I<Ndk>();
      final nostrMailService = GetIt.I<NostrMailService>();

      // Check if user has configured servers, otherwise use defaults
      final userServers = await nostrMailService.getBlossomServers();
      final serverUrls = userServers.isNotEmpty
          ? userServers
          : NostrConfig.recommendedBlossomServers;

      final uploadResults = await ndk.blossom.uploadBlob(
        data: stripMediaMetadata(await file.readAsBytes()),
        contentType: file.extension != null ? 'image/${file.extension}' : null,
        serverUrls: serverUrls,
      );
      if (_isDisposed) return;

      if (uploadResults.isEmpty) {
        if (context.mounted) {
          ToastHelper.error(context, l.profileUploadNoServers);
        }
        return;
      }

      final successResult = uploadResults.firstWhere(
        (r) => r.success && r.descriptor != null,
        orElse: () => uploadResults.first,
      );

      if (successResult.success && successResult.descriptor != null) {
        pictureController.text = successResult.descriptor!.url;
      } else {
        if (context.mounted) {
          ToastHelper.error(
            context,
            successResult.error ?? l.profileUploadFailed,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.error(context, l.profileUploadError);
      }
    } finally {
      if (!_isDisposed) {
        isUploadingPicture = false;
        notifyListeners();
      }
    }
  }

  Future<void> saveProfile() async {
    final pubkey = Get.find<AuthController>().publicKey;
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
        relaySet: RelaySet.union([
          RelaySet.explicit(
            {
              ...NostrConfig.popularRelays,
              ...NostrConfig.discoveryRelays,
            }.toList(),
          ),
          RelaySet.outbox(account.pubkey),
        ]),
        pubkey: account.pubkey,
      );

      // Refresh metadata in AuthController
      // Use refresh() to force rebuild even with same object reference
      final authController = Get.find<AuthController>();
      authController.userMetadata.value = metadata;
      authController.userMetadata.refresh();
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
