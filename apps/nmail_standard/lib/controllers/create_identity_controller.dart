import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_router.dart';
import '../controllers/auth_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/local_part_format.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import '../utils/toast_helper.dart';

class CreateIdentityController extends GetxController {
  final nameController = TextEditingController();
  final localPartController = TextEditingController();
  final bridgeController = TextEditingController();
  List<String> availableBridges = [];
  List<MailAddress> existingIdentities = [];
  late String myNpub;
  late String myHex;
  late String myBase36;
  LocalPartFormat? selectedFormat;
  String? selectedBridge;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final _nostrMailService = Get.find<NostrMailService>();

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(update);
    localPartController.addListener(update);
    bridgeController.addListener(update);
    _loadUserData();
    _loadBridges();
  }

  @override
  void onClose() {
    nameController.removeListener(update);
    localPartController.removeListener(update);
    bridgeController.removeListener(update);
    nameController.dispose();
    localPartController.dispose();
    bridgeController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    final auth = Get.find<AuthController>();
    myHex = auth.publicKey!;
    myNpub = auth.npub!;
    myBase36 = BigInt.parse(myHex, radix: 16).toRadixString(36);
  }

  Future<void> _loadBridges() async {
    try {
      final settings = await _nostrMailService.client.getPrivateSettings();
      final bridges = settings?.bridges ?? [];

      availableBridges = bridges;
      existingIdentities = settings?.identities ?? [];
    } catch (_) {
      availableBridges = [];
      existingIdentities = [];
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void useNpub() {
    localPartController.text = myNpub;
    selectedFormat = LocalPartFormat.npub;
    update();
  }

  void useHex() {
    localPartController.text = myHex;
    selectedFormat = LocalPartFormat.hex;
    update();
  }

  void useBase36() {
    localPartController.text = myBase36;
    selectedFormat = LocalPartFormat.base36;
    update();
  }

  void checkLocalPartFormat() {
    final text = localPartController.text;
    if (text != myNpub &&
        text != myHex &&
        text != myBase36 &&
        selectedFormat != null) {
      selectedFormat = null;
      update();
    }
  }

  void selectBridge(String bridge) {
    selectedBridge = bridge;
    if (bridgeController.text != bridge) {
      bridgeController.text = bridge;
    }
    update();
  }

  void checkBridgeFormat() {
    final text = bridgeController.text.trim();
    if (text != selectedBridge && selectedBridge != null) {
      selectedBridge = null;
      update();
    }
  }

  bool get hasRequiredFields {
    final localPart = localPartController.text.trim();
    final bridge = bridgeController.text.trim();

    if (localPart.isEmpty) return false;
    if (bridge.isEmpty) return false;

    return true;
  }

  bool get hasExactDuplicate {
    final identity = buildIdentity();
    if (identity == null) return false;

    return _identityExists(existingIdentities, identity);
  }

  bool validateForm() {
    if (isLoading.value) return false;
    if (!hasRequiredFields) return false;
    if (hasExactDuplicate) return false;

    return true;
  }

  bool get isFormValid => validateForm();

  MailAddress? buildIdentity() {
    final name = nameController.text.trim().isEmpty
        ? null
        : nameController.text.trim();
    final localPart = localPartController.text.trim();
    final bridge = bridgeController.text.trim();

    if (bridge.isEmpty) return null;

    final email = '$localPart@$bridge';
    return MailAddress(name, email);
  }

  Future<void> saveIdentity() async {
    if (!isFormValid) return;
    if (isSaving.value) return;

    final newIdentity = buildIdentity();
    if (newIdentity == null) return;

    isSaving.value = true;
    update();

    try {
      final settings = await _nostrMailService.client.getPrivateSettings();
      final existingIdentities = settings?.identities ?? [];
      this.existingIdentities = existingIdentities;
      if (_identityExists(existingIdentities, newIdentity)) {
        update();
        return;
      }

      final updatedIdentities = [...existingIdentities, newIdentity];

      await _nostrMailService.client.updatePrivateSettings(
        identities: updatedIdentities,
      );

      AppRouter.router.pop();
    } catch (e) {
      if (Get.context != null) {
        final l = AppLocalizations.of(Get.context!);
        ToastHelper.error(Get.context!, l.createIdentityFailed(e.toString()));
      }
    } finally {
      _stopSaving();
    }
  }

  void _stopSaving() {
    if (isClosed) return;

    isSaving.value = false;
    update();
  }

  bool _identityExists(
    List<MailAddress> existingIdentities,
    MailAddress newIdentity,
  ) {
    final email = _normalizedEmail(newIdentity);
    final name = _normalizedName(newIdentity);
    return existingIdentities.any((identity) {
      return _normalizedEmail(identity) == email &&
          _normalizedName(identity) == name;
    });
  }

  String _normalizedEmail(MailAddress identity) {
    return identity.email.trim().toLowerCase();
  }

  String _normalizedName(MailAddress identity) {
    return (identity.personalName ?? '').trim();
  }
}
