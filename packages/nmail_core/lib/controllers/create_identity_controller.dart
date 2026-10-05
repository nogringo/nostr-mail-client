import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../app/routes/app_router.dart';
import '../controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/local_part_format.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class CreateIdentityController extends ChangeNotifier {
  CreateIdentityController() {
    nameController.addListener(notifyListeners);
    localPartController.addListener(notifyListeners);
    bridgeController.addListener(notifyListeners);
    _loadUserData();
    _loadBridges();
  }

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
  bool isLoading = true;
  bool isSaving = false;
  bool _isDisposed = false;

  final _nostrMailService = GetIt.I<NostrMailService>();

  @override
  void dispose() {
    _isDisposed = true;
    nameController.removeListener(notifyListeners);
    localPartController.removeListener(notifyListeners);
    bridgeController.removeListener(notifyListeners);
    nameController.dispose();
    localPartController.dispose();
    bridgeController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final auth = Get.find<AuthController>();
    myHex = auth.publicKey!;
    myNpub = auth.npub!;
    myBase36 = BigInt.parse(myHex, radix: 16).toRadixString(36);
  }

  Future<void> _loadBridges() async {
    try {
      final settings = await _nostrMailService.client.getLocalPrivateSettings();
      final bridges = settings?.bridges ?? [];

      availableBridges = bridges;
      existingIdentities = settings?.identities ?? [];
    } catch (_) {
      availableBridges = [];
      existingIdentities = [];
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void useNpub() {
    localPartController.text = myNpub;
    selectedFormat = LocalPartFormat.npub;
    notifyListeners();
  }

  void useHex() {
    localPartController.text = myHex;
    selectedFormat = LocalPartFormat.hex;
    notifyListeners();
  }

  void useBase36() {
    localPartController.text = myBase36;
    selectedFormat = LocalPartFormat.base36;
    notifyListeners();
  }

  void checkLocalPartFormat() {
    final text = localPartController.text;
    if (text != myNpub &&
        text != myHex &&
        text != myBase36 &&
        selectedFormat != null) {
      selectedFormat = null;
      notifyListeners();
    }
  }

  void selectBridge(String bridge) {
    selectedBridge = bridge;
    if (bridgeController.text != bridge) {
      bridgeController.text = bridge;
    }
    notifyListeners();
  }

  void checkBridgeFormat() {
    final text = bridgeController.text.trim();
    if (text != selectedBridge && selectedBridge != null) {
      selectedBridge = null;
      notifyListeners();
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
    if (isLoading) return false;
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
    if (isSaving) return;

    final newIdentity = buildIdentity();
    if (newIdentity == null) return;

    isSaving = true;
    notifyListeners();

    try {
      final settings = await _nostrMailService.client.getLocalPrivateSettings();
      final existingIdentities = settings?.identities ?? [];
      this.existingIdentities = existingIdentities;
      if (_identityExists(existingIdentities, newIdentity)) {
        return;
      }

      final updatedIdentities = [...existingIdentities, newIdentity];

      await _nostrMailService.client.updatePrivateSettings(
        identities: updatedIdentities,
      );

      AppRouter.router.pop();
    } catch (e) {
      if (AppRouter.rootContext != null) {
        final l = AppLocalizations.of(AppRouter.rootContext!);
        ToastHelper.error(
          AppRouter.rootContext!,
          l.createIdentityFailed(e.toString()),
        );
      }
    } finally {
      _stopSaving();
    }
  }

  void _stopSaving() {
    if (_isDisposed) return;

    isSaving = false;
    notifyListeners();
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
