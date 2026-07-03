import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import '../app/config/nostr_config.dart';
import '../app/routes/app_router.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/nostr_mail_service.dart';
import '../utils/toast_helper.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final displayNameController = TextEditingController();
  final pictureController = TextEditingController();
  final aboutController = TextEditingController();

  final Rx<Metadata?> _currentMetadata = Rx<Metadata?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingPicture = false.obs;
  final RxBool showMoreOptions = false.obs;

  bool get hasChanges {
    final metadata = _currentMetadata.value;
    if (metadata == null) return true;

    return nameController.text.trim() != (metadata.name ?? '') ||
        displayNameController.text.trim() != (metadata.displayName ?? '') ||
        pictureController.text.trim() != (metadata.picture ?? '') ||
        aboutController.text.trim() != (metadata.about ?? '');
  }

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    if (metadata != null) {
      _currentMetadata.value = metadata;
      nameController.text = metadata.name ?? '';
      displayNameController.text = metadata.displayName ?? '';
      pictureController.text = metadata.picture ?? '';
      aboutController.text = metadata.about ?? '';
      isLoading.value = false;
    }
    loadMetadata();
  }

  Future<void> loadMetadata() async {
    final authController = Get.find<AuthController>();
    final pubkey = authController.publicKey;
    if (pubkey == null) {
      isLoading.value = false;
      return;
    }

    try {
      final ndk = Get.find<Ndk>();
      final metadata = await ndk.metadata.loadMetadata(pubkey);

      if (metadata != null) {
        authController.userMetadata.value = metadata;
        _currentMetadata.value = metadata;
        nameController.text = metadata.name ?? '';
        displayNameController.text = metadata.displayName ?? '';
        pictureController.text = metadata.picture ?? '';
        aboutController.text = metadata.about ?? '';
      }
    } catch (e) {
      if (!isClosed) {
        final l = AppLocalizations.of(Get.context!);
        ToastHelper.error(Get.context!, l.profileLoadFailed);
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
        update();
      }
    }
  }

  Future<void> pickAndUploadPicture(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(
      dialogTitle: l.profileSelectPicture,
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    final file = result.files.single;
    isUploadingPicture.value = true;
    update();

    try {
      final ndk = Get.find<Ndk>();
      final nostrMailService = Get.find<NostrMailService>();

      // Check if user has configured servers, otherwise use defaults
      final userServers = await nostrMailService.getBlossomServers();
      final serverUrls = userServers.isNotEmpty
          ? userServers
          : NostrConfig.recommendedBlossomServers;

      final uploadResults = await ndk.blossom.uploadBlob(
        data: file.bytes!,
        contentType: file.extension != null ? 'image/${file.extension}' : null,
        serverUrls: serverUrls,
      );

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
      if (!isClosed) {
        isUploadingPicture.value = false;
        update();
      }
    }
  }

  Future<void> saveProfile() async {
    final pubkey = Get.find<AuthController>().publicKey;
    if (pubkey == null) return;

    isSaving.value = true;
    update();

    try {
      // Start from current object to preserve fields like banner, nip05, website, etc.
      final metadata = _currentMetadata.value ?? Metadata(pubKey: pubkey);

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

      final ndk = Get.find<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final signed = await account.signer.sign(metadata.toEvent());
      await ndk.config.cache.saveMetadata(metadata);
      // Signaling event: broadcast widely (popular + outbox).
      final outbox = await Get.find<NostrMailService>().getOutboxRelays();
      await Get.find<OfflineBroadcast>().broadcast(
        signed,
        relays: {...NostrConfig.popularRelays, ...outbox}.toList(),
      );

      // Refresh metadata in AuthController
      // Use refresh() to force rebuild even with same object reference
      final authController = Get.find<AuthController>();
      authController.userMetadata.value = metadata;
      authController.userMetadata.refresh();

      AppRouter.router.pop();
    } catch (e) {
      if (!isClosed) {
        isSaving.value = false;
        update();
        final l = AppLocalizations.of(Get.context!);
        ToastHelper.error(Get.context!, l.profileUpdateFailed);
      }
    }
  }
}
