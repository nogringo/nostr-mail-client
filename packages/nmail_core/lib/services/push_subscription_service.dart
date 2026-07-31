import 'dart:convert';

import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/services/pending_push_disables.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/storage_service.dart';

/// Keeps this device's push subscriptions in sync with the per-account
/// notification setting. Every account that has notifications on stays
/// subscribed, not only the active one, so mail addressed to a background
/// account still reaches the device.
class PushSubscriptionService extends GetxService {
  PushSubscriptionService({
    StorageService? storage,
    Ndk? ndk,
    PushRegistrationService? registration,
    PendingPushDisables? pending,
  }) : _storageOverride = storage,
       _ndkOverride = ndk,
       _registrationOverride = registration,
       _pending = pending ?? PendingPushDisables();

  static String enabledKey(String pubkey) => 'notifications_enabled_$pubkey';

  /// Written when the setting was still device-wide. Adopted by the account
  /// that wrote it, then deleted.
  static const preMultiAccountEnabledKey = 'notifications_enabled';

  /// What the push server holds for an account, as `{transport, language}`.
  /// Its presence answers "is this account subscribed", its content answers
  /// "with what", so an unchanged subscription is never signed again and a
  /// dropped one targets the transport that actually carried it.
  static String registrationKey(String pubkey) => 'push_registration_$pubkey';

  /// Subscribed before this device recorded its subscriptions, so the transport
  /// is unknown. Never matches a current one, so it is refreshed on sight.
  static const _untrackedSubscription = '{}';

  final StorageService? _storageOverride;
  final Ndk? _ndkOverride;
  final PushRegistrationService? _registrationOverride;
  final PendingPushDisables _pending;

  StorageService get _storage => _storageOverride ?? Get.find<StorageService>();
  Ndk get _ndk => _ndkOverride ?? Get.find<Ndk>();
  PushRegistrationService get _registration =>
      _registrationOverride ?? Get.find<PushRegistrationService>();

  Future<bool> isEnabled(String pubkey) async =>
      await _storage.getSetting<bool>(enabledKey(pubkey)) ?? false;

  /// Reads the setting for [pubkey], adopting [preMultiAccountEnabledKey] on
  /// first read. That flag was written by the account that was active back
  /// then, which is the one restored at the upgraded launch.
  Future<bool> resolveEnabled(String pubkey) async {
    final scoped = await _storage.getSetting<bool>(enabledKey(pubkey));
    if (scoped != null) return scoped;

    final inherited = await _storage.getSetting<bool>(
      preMultiAccountEnabledKey,
    );
    if (inherited == null) return false;

    await _storage.saveSetting(enabledKey(pubkey), inherited);
    await _storage.deleteSetting(preMultiAccountEnabledKey);
    if (inherited) {
      await _storage.saveSetting(
        registrationKey(pubkey),
        _untrackedSubscription,
      );
    }
    return inherited;
  }

  Future<bool> hasEnabledAccount() async {
    for (final pubkey in _ndk.accounts.accounts.keys) {
      if (await isEnabled(pubkey)) return true;
    }
    return false;
  }

  /// Stores the user's intent, then syncs the server best-effort: whatever
  /// fails is replayed on the next launch, switch or transport change.
  Future<void> setEnabled({required String pubkey, required bool value}) async {
    await _storage.saveSetting(enabledKey(pubkey), value);
    await refreshAccount(pubkey);
  }

  /// Aligns the server with the setting of [pubkey], in both directions: a
  /// subscription the transport outdated, or one a failed disable left behind.
  Future<void> refreshAccount(String pubkey) async {
    if (await isEnabled(pubkey)) {
      await _subscribe(pubkey);
    } else {
      await _unsubscribe(pubkey);
    }
  }

  /// Realigns every account. Called once the transport is known and whenever it
  /// changes (new FCM token, new UnifiedPush endpoint) or the notification
  /// language changes.
  Future<void> syncAll() async {
    await _pending.flush();
    if (_registration.currentTransport == null) return;

    for (final pubkey in _ndk.accounts.accounts.keys.toList(growable: false)) {
      await refreshAccount(pubkey);
    }
  }

  /// Retries the unsubscriptions that never reached the server. Needs no
  /// account and no transport, so it runs at startup whatever the state.
  Future<void> flushPendingDisables() => _pending.flush();

  /// Unsubscribes [pubkey] and drops its setting, for logout and account
  /// removal. The push payload carries no pubkey, so a subscription left behind
  /// would keep notifying this device for an account it can no longer open.
  Future<void> forget(String pubkey) async {
    await _unsubscribe(pubkey);
    await _storage.deleteSetting(enabledKey(pubkey));
  }

  Future<void> _subscribe(String pubkey) async {
    final transport = _registration.currentTransport;
    final account = _ndk.accounts.accounts[pubkey];
    if (transport == null || account == null) return;

    final subscription = _describe(transport);
    if (await _storage.getSetting<String>(registrationKey(pubkey)) ==
        subscription) {
      return;
    }

    if (await _registration.register(transport, account: account)) {
      await _storage.saveSetting(registrationKey(pubkey), subscription);
      await _pending.dropFor(pubkey: pubkey, transport: transport);
    }
  }

  Future<void> _unsubscribe(String pubkey) async {
    final subscription = await _storage.getSetting<String>(
      registrationKey(pubkey),
    );
    if (subscription == null) return;

    // The transport that carried the subscription, which is not the current one
    // when the token rotated while this account sat in the background.
    final transport =
        _transportOf(subscription) ?? _registration.currentTransport;
    if (transport == null) return;

    await _storage.deleteSetting(registrationKey(pubkey));
    await _pending.add(pubkey: pubkey, transport: transport);
    await _pending.flush();
  }

  String _describe(PushTransport transport) => jsonEncode({
    'transport': transport.toJson(),
    'language': _registration.languageTag,
  });

  PushTransport? _transportOf(String subscription) {
    try {
      final transport =
          (jsonDecode(subscription) as Map<String, dynamic>)['transport'];
      if (transport is! Map<String, dynamic>) return null;
      return PushTransport.fromJson(transport);
    } catch (_) {
      return null;
    }
  }
}
