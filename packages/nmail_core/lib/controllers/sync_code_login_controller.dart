import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:nip49/nip49.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/models/sync_code_kind.dart';

enum SyncCodeLoginError { invalidCode, wrongPassword, bunkerFailed }

/// Drives the single login field that takes an nsec, an ncryptsec (with its
/// password) or a bunker URL.
class SyncCodeLoginController extends ChangeNotifier {
  SyncCodeLoginController() {
    code.addListener(_onInputChanged);
    password.addListener(_onInputChanged);
  }

  final code = TextEditingController();
  final password = TextEditingController();

  bool isLoggingIn = false;
  bool isCodeVisible = false;
  SyncCodeLoginError? error;

  /// Set when the bunker asks the user to approve the login on a web page.
  String? bunkerAuthUrl;

  bool _isDisposed = false;
  (String, String) _lastInput = ('', '');

  Ndk get _ndk => GetIt.I<Ndk>();

  SyncCodeKind? get kind => SyncCodeKind.of(code.text);

  bool get canLogIn =>
      !isLoggingIn &&
      code.text.trim().isNotEmpty &&
      (kind != SyncCodeKind.ncryptsec || password.text.isNotEmpty);

  void toggleCodeVisibility() {
    isCodeVisible = !isCodeVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    code.dispose();
    password.dispose();
    super.dispose();
  }

  // Text controllers also notify on cursor moves, which must keep the error.
  void _onInputChanged() {
    final input = (code.text, password.text);
    if (input == _lastInput) return;
    _lastInput = input;
    error = null;
    notifyListeners();
  }

  /// Returns true once an account is logged in and saved.
  Future<bool> logIn() async {
    if (!canLogIn) return false;
    final value = code.text.trim();

    isLoggingIn = true;
    error = null;
    bunkerAuthUrl = null;
    notifyListeners();

    final failure = switch (kind) {
      SyncCodeKind.nsec => _logInWithNsec(value),
      SyncCodeKind.ncryptsec => await _logInWithNcryptsec(value),
      SyncCodeKind.bunker => await _logInWithBunker(value),
      null => SyncCodeLoginError.invalidCode,
    };
    if (failure == null) await GetIt.I<NdkFlutter>().saveAccountsState();

    if (_isDisposed) return failure == null;
    isLoggingIn = false;
    error = failure;
    bunkerAuthUrl = null;
    notifyListeners();
    return failure == null;
  }

  SyncCodeLoginError? _logInWithNsec(String nsec) {
    if (!Nip19.isPrivateKey(nsec)) return SyncCodeLoginError.invalidCode;
    try {
      _logInWithPrivateKey(Nip19.decode(nsec));
      return null;
    } catch (_) {
      return SyncCodeLoginError.invalidCode;
    }
  }

  Future<SyncCodeLoginError?> _logInWithNcryptsec(String ncryptsec) async {
    final String privateKey;
    try {
      privateKey = await Nip49.decrypt(ncryptsec, password.text);
    } catch (_) {
      return SyncCodeLoginError.wrongPassword;
    }
    _logInWithPrivateKey(privateKey);
    return null;
  }

  void _logInWithPrivateKey(String privateKey) {
    final pubkey = Bip340.getPublicKey(privateKey);
    if (_ndk.accounts.hasAccount(pubkey)) {
      _ndk.accounts.switchAccount(pubkey: pubkey);
    } else {
      _ndk.accounts.loginPrivateKey(pubkey: pubkey, privkey: privateKey);
    }
  }

  Future<SyncCodeLoginError?> _logInWithBunker(String bunkerUrl) async {
    try {
      final connection = await _ndk.accounts.loginWithBunkerUrl(
        bunkerUrl: bunkerUrl,
        bunkers: _ndk.bunkers,
        authCallback: (url) {
          if (_isDisposed) return;
          bunkerAuthUrl = url;
          notifyListeners();
        },
        clientMetadata: NostrConfig.nip46ClientMetadata,
      );
      return connection == null ? SyncCodeLoginError.bunkerFailed : null;
    } catch (_) {
      return SyncCodeLoginError.bunkerFailed;
    }
  }
}
