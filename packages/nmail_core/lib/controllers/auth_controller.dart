import 'dart:async';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/data_layer/repositories/signers/nip46_event_signer.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/account_signer_kind.dart';
import 'package:nmail_core/services/account_local_data_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:flutter/material.dart';
import 'inbox_controller.dart';
import 'scheduled_controller.dart';
import 'settings_controller.dart';

class AuthController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final showMoreOptions = false.obs;
  final isRegistering = false.obs;
  final showSyncCodeExplanation = false.obs;
  final username = ''.obs;
  final usernameController = TextEditingController();
  final Rxn<Metadata> userMetadata = Rxn<Metadata>();
  final accountPubkeys = <String>[].obs;
  final activePubkey = RxnString();
  final activeNpub = RxnString();

  /// Account whose switch or removal is running, so the accounts list can show
  /// progress on that row and ignore taps on the others.
  final pendingAccountPubkey = RxnString();

  StreamSubscription<Account?>? _authSubscription;
  int _accountSwitchGeneration = 0;

  Ndk get ndk => Get.find();
  NdkFlutter get ndkFlutter => Get.find();

  Future<AuthController> init() async {
    isLoading.value = true;
    try {
      await ndkFlutter.restoreAccountsState();
      _refreshAccountsState();

      if (ndk.accounts.getPublicKey() != null) {
        await _nostrMailService.activateForCurrentAccount();
        isLoggedIn.value = true;
        // Non-blocking metadata load
        loadUserMetadata();
      }
    } catch (_) {
      // Keep isLoggedIn as false
    } finally {
      isLoading.value = false;
    }
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    // Sync controller with observable
    // TODO: Simplify registration state by reading usernameController.text
    // directly if no UI needs to observe username reactively.
    usernameController.addListener(() {
      username.value = usernameController.text;
    });
    _authSubscription = ndk.accounts.authStateChanges.listen((_) {
      _refreshAccountsState();
    });
    // In case it wasn't called in main (testing/standalone)
    if (!isLoggedIn.value && ndk.accounts.getPublicKey() == null) {
      init();
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    usernameController.dispose();
    super.onClose();
  }

  Future<void> loadUserMetadata() async {
    final pk = publicKey;
    if (pk == null) return;

    try {
      final metadata = await ndk.metadata.loadMetadata(pk);
      if (publicKey != pk) return;
      userMetadata.value = metadata;
    } catch (_) {}
  }

  Future<void> onLoggedIn() async {
    // Adding an account from /accounts/add runs this while another account is
    // still watched, so drop its subscriptions before starting the new ones.
    await _nostrMailService.resetForAccountChange();
    await _nostrMailService.activateForCurrentAccount();
    _refreshAccountsState();
    userMetadata.value = null;
    if (Get.isRegistered<InboxController>()) {
      await Get.find<InboxController>().activateForCurrentAccount(
        folder: MailFolder.inbox,
      );
    }
    if (Get.isRegistered<ScheduledController>()) {
      await Get.delete<ScheduledController>();
    }
    isLoggedIn.value = true;
    loadUserMetadata();
    // authStateChanges fires before the client is attached to the new account,
    // so SettingsController's listener can't read the synced signature yet.
    // Now that the private-settings cache is primed, pull it into the Rx.
    await Get.find<SettingsController>().reloadSyncedSettings();
    final pubkey = publicKey;
    if (pubkey != null && Get.isRegistered<PushSubscriptionService>()) {
      await Get.find<PushSubscriptionService>().refreshAccount(pubkey);
    }
  }

  Future<void> register() async {
    final isEmpty = username.value.trim().isEmpty;
    final context = Get.context;

    if (isEmpty && context != null) {
      ToastHelper.error(
        context,
        AppLocalizations.of(context).authEnterUsername,
      );
      return;
    }

    if (isEmpty) return;

    isLoading.value = true;

    final keyPair = Bip340.generatePrivateKey();
    ndk.accounts.loginPrivateKey(
      privkey: keyPair.privateKey!,
      pubkey: keyPair.publicKey,
    );
    _refreshAccountsState();

    await ndkFlutter.saveAccountsState();

    final rawName = username.value.trim();
    final formattedName = rawName.toLowerCase().replaceAll(' ', '');

    final metadata = Metadata(
      pubKey: keyPair.publicKey,
      name: formattedName,
      displayName: rawName,
    );

    final relays = {
      for (var r in NostrConfig.recommendedInboxOutboxRelays)
        r: ReadWriteMarker.readWrite,
    };

    final account = ndk.accounts.getLoggedAccount()!;
    final broadcastQueue = Get.find<OfflineBroadcast>();

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final userRelayList = UserRelayList(
      pubKey: account.pubkey,
      relays: relays,
      createdAt: now,
      refreshedTimestamp: now,
    );
    // Signaling events: broadcast widely (popular + outbox).
    final signalingTargets = {
      ...NostrConfig.popularRelays,
      ...userRelayList.writeUrls,
    }.toList();

    // Metadata (kind 0)
    final signedMetadata = await account.signer.sign(metadata.toEvent());
    await ndk.config.cache.saveMetadata(metadata);
    await broadcastQueue.broadcast(
      signedMetadata,
      relays: signalingTargets,
      pubkey: account.pubkey,
    );

    // NIP-65 relay list (kind 10002)
    final signedNip65 = await account.signer.sign(
      userRelayList.toNip65().toEvent(),
    );
    await ndk.config.cache.saveUserRelayList(userRelayList);
    await broadcastQueue.broadcast(
      signedNip65,
      relays: signalingTargets,
      pubkey: account.pubkey,
    );

    // DM relay list (kind 10050)
    final dmRelays = NostrConfig.recommendedDmRelays;
    final unsignedDm = Nip01Event(
      pubKey: account.pubkey,
      kind: dmRelayListKind,
      tags: dmRelays.map((r) => ['relay', r]).toList(),
      content: '',
    );
    final signedDm = await account.signer.sign(unsignedDm);
    await ndk.config.cache.saveEvent(signedDm);
    await broadcastQueue.broadcast(
      signedDm,
      relays: signalingTargets,
      pubkey: account.pubkey,
    );

    // Blossom user server list (kind 10063)
    final blossomServers = NostrConfig.recommendedBlossomServers;
    final unsignedBlossom = Nip01Event(
      pubKey: account.pubkey,
      kind: blossomServerListKind,
      tags: [
        for (final s in blossomServers) ['server', s],
      ],
      content: '',
    );
    final signedBlossom = await account.signer.sign(unsignedBlossom);
    await ndk.config.cache.saveEvent(signedBlossom);
    await broadcastQueue.broadcast(
      signedBlossom,
      relays: signalingTargets,
      pubkey: account.pubkey,
    );

    // Must be set BEFORE onLoggedIn flips isLoggedIn, otherwise the router's
    // refreshListenable bounces the user off /login before this screen renders.
    showSyncCodeExplanation.value = true;

    await onLoggedIn();

    // Clear registration state
    username.value = '';
    usernameController.clear();
    isRegistering.value = false;

    isLoading.value = false;
  }

  void continueToInbox() {
    showSyncCodeExplanation.value = false;
    AppRouter.router.go(AppRoutes.inbox);
  }

  Future<void> switchAccount(String pubkey) async {
    if (pubkey == publicKey) return;
    if (!ndk.accounts.hasAccount(pubkey)) return;
    if (pendingAccountPubkey.value != null) return;

    final generation = ++_accountSwitchGeneration;
    pendingAccountPubkey.value = pubkey;

    try {
      await _nostrMailService.resetForAccountChange();
      if (Get.isRegistered<InboxController>()) {
        await Get.find<InboxController>().resetForAccountChange();
        if (generation != _accountSwitchGeneration) return;
      }
      if (Get.isRegistered<ScheduledController>()) {
        await Get.delete<ScheduledController>();
        if (generation != _accountSwitchGeneration) return;
      }

      ndk.accounts.switchAccount(pubkey: pubkey);
      _refreshAccountsState();
      userMetadata.value = null;
      unawaited(ndkFlutter.saveAccountsState());
      unawaited(loadUserMetadata());
      AppRouter.router.go(AppRoutes.inbox);

      await _nostrMailService.activateForCurrentAccount();
      if (generation != _accountSwitchGeneration) return;

      // Not awaited: the cached signature lands before the first await inside,
      // and the relay refresh behind it is best-effort.
      unawaited(Get.find<SettingsController>().reloadSyncedSettings());

      // Catches up on a push transport that changed while this account was in
      // the background.
      if (Get.isRegistered<PushSubscriptionService>()) {
        unawaited(Get.find<PushSubscriptionService>().refreshAccount(pubkey));
      }

      if (Get.isRegistered<InboxController>()) {
        await Get.find<InboxController>().activateForCurrentAccount(
          folder: MailFolder.inbox,
        );
        if (generation != _accountSwitchGeneration) return;
      }
    } finally {
      // Only release our own lock: a switch that bailed out on a stale
      // generation must not unlock the operation that superseded it.
      if (pendingAccountPubkey.value == pubkey) {
        pendingAccountPubkey.value = null;
      }
    }
  }

  /// Asks the relays to erase the active account (NIP-62 request to vanish),
  /// then removes it from this device. Returns the queued request so the
  /// caller can follow its delivery relay by relay.
  ///
  /// Works offline: the request is signed and queued locally, and the queue
  /// retries it until every relay has answered. It is queued unattributed, so
  /// the account wipe behind it, which drops that account's queue, cannot take
  /// the request down with it.
  ///
  /// Throws when the signer refuses, which leaves the account untouched.
  Future<QueuedBroadcast> deleteAccount({String reason = ''}) async {
    final account = ndk.accounts.getLoggedAccount();
    if (account == null) throw StateError('No account to delete');
    if (pendingAccountPubkey.value != null) {
      throw StateError('Another account operation is running');
    }

    final pubkey = account.pubkey;
    // Cache reads only: deleting an account must not depend on the network.
    final userRelayList = await ndk.config.cache.loadUserRelayList(pubkey);
    final dmRelays = await _nostrMailService.getDmRelays();
    // A relay only honours a request it receives, so aim at every relay this
    // account could have reached: read and write alike, not just the outbox.
    final targets = {
      ...NostrConfig.popularRelays,
      ...NostrConfig.bootstrapRelays,
      ...?userRelayList?.relays.keys,
      ...dmRelays,
    }.toList();

    final unsignedVanish = Nip01Event(
      pubKey: pubkey,
      kind: vanishRequestKind,
      tags: [
        ['relay', vanishAllRelays],
      ],
      content: reason,
    );
    final signedVanish = await account.signer.sign(unsignedVanish);
    final queued = await Get.find<OfflineBroadcast>().broadcast(
      signedVanish,
      relays: targets,
    );

    await removeAccount(pubkey);
    return queued;
  }

  /// Removes [pubkey] from this device and erases its local data. The active
  /// account goes through [logout] so the fallback switch, push cleanup and
  /// navigation stay in one place.
  Future<void> removeAccount(String pubkey) async {
    if (!ndk.accounts.hasAccount(pubkey)) return;
    if (pendingAccountPubkey.value != null) return;

    pendingAccountPubkey.value = pubkey;
    try {
      if (pubkey == publicKey) {
        await logout();
        return;
      }

      // Snapshot rather than bump: removing an idle account must not abort the
      // tail of a switch that is already in flight.
      final generation = _accountSwitchGeneration;

      if (Get.isRegistered<PushSubscriptionService>()) {
        await Get.find<PushSubscriptionService>().forget(pubkey);
      }

      await Get.find<AccountLocalDataService>().clearLocalAccountData(
        pubkey: pubkey,
      );

      // A switch or logout during the wipe may have made this account the
      // active one, and removing it then would clear the logged pubkey and
      // leave the app logged in with no account.
      if (generation != _accountSwitchGeneration) return;
      if (!ndk.accounts.hasAccount(pubkey) || pubkey == publicKey) return;

      // Releases the remote signer connection for bunker accounts.
      await accountFor(pubkey)?.dispose();
      ndk.accounts.removeAccount(pubkey: pubkey);
      await ndkFlutter.saveAccountsState();
      // removeAccount only emits on authStateChanges when it drops the logged
      // account, so refresh the observables ourselves.
      _refreshAccountsState();
    } finally {
      if (pendingAccountPubkey.value == pubkey) {
        pendingAccountPubkey.value = null;
      }
    }
  }

  Future<void> logout({bool clearLocalData = true}) async {
    isLoading.value = true;
    try {
      ++_accountSwitchGeneration;
      final removedPubkey = publicKey;
      if (removedPubkey != null &&
          Get.isRegistered<PushSubscriptionService>()) {
        await Get.find<PushSubscriptionService>().forget(removedPubkey);
      }
      final fallbackPubkey = otherAccountPubkeys.firstOrNull;
      if (Get.isRegistered<InboxController>()) {
        await Get.find<InboxController>().resetForAccountChange();
      }
      if (Get.isRegistered<ScheduledController>()) {
        await Get.delete<ScheduledController>();
      }
      if (clearLocalData && removedPubkey != null) {
        await Get.find<AccountLocalDataService>().clearLocalAccountData(
          pubkey: removedPubkey,
        );
      }
      await _nostrMailService.logout();
      if (fallbackPubkey != null) {
        ndk.accounts.switchAccount(pubkey: fallbackPubkey);
        await _nostrMailService.activateForCurrentAccount();
        unawaited(Get.find<SettingsController>().reloadSyncedSettings());
        if (Get.isRegistered<PushSubscriptionService>()) {
          unawaited(
            Get.find<PushSubscriptionService>().refreshAccount(fallbackPubkey),
          );
        }
      }
      await ndkFlutter.saveAccountsState();
      _refreshAccountsState();
      userMetadata.value = null;

      isRegistering.value = false;
      username.value = '';
      usernameController.clear();
      showMoreOptions.value = false;

      if (fallbackPubkey == null) {
        isLoggedIn.value = false;
        AppRouter.router.go(AppRoutes.login);
        return;
      }

      unawaited(loadUserMetadata());
      if (Get.isRegistered<InboxController>()) {
        await Get.find<InboxController>().activateForCurrentAccount(
          folder: MailFolder.inbox,
        );
      }
      AppRouter.router.go(AppRoutes.inbox);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutAll({bool clearLocalData = true}) async {
    isLoading.value = true;
    try {
      ++_accountSwitchGeneration;
      if (Get.isRegistered<PushSubscriptionService>()) {
        final pushSubscriptions = Get.find<PushSubscriptionService>();
        for (final pubkey in accountPubkeys.toList(growable: false)) {
          await pushSubscriptions.forget(pubkey);
        }
      }
      if (Get.isRegistered<InboxController>()) {
        await Get.find<InboxController>().resetForAccountChange();
      }
      if (Get.isRegistered<ScheduledController>()) {
        await Get.delete<ScheduledController>();
      }
      if (clearLocalData) {
        await Get.find<AccountLocalDataService>().clearAllLocalData();
      }

      await _nostrMailService.resetForAccountChange();
      for (final pubkey in accountPubkeys.toList(growable: false)) {
        ndk.accounts.removeAccount(pubkey: pubkey);
      }
      await ndkFlutter.saveAccountsState();
      _refreshAccountsState();
      userMetadata.value = null;

      isRegistering.value = false;
      username.value = '';
      usernameController.clear();
      showMoreOptions.value = false;
      isLoggedIn.value = false;
      AppRouter.router.go(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  String? get publicKey => activePubkey.value;

  String? get currentPubkey => activePubkey.value;

  String? get currentNpub => activeNpub.value;

  bool get hasMultipleAccounts => accountPubkeys.length > 1;

  List<String> get otherAccountPubkeys {
    final current = activePubkey.value;
    return accountPubkeys.where((pubkey) => pubkey != current).toList();
  }

  Account? accountFor(String pubkey) => ndk.accounts.accounts[pubkey];

  AccountSignerKind signerKindOf(String pubkey) {
    final account = accountFor(pubkey);
    if (account == null) return AccountSignerKind.external;
    // Class before AccountType: extensions, signer apps and bunkers are all
    // reported as AccountType.externalSigner.
    final signer = account.signer;
    if (signer is Nip07EventSigner) return AccountSignerKind.browserExtension;
    if (signer is Nip55EventSigner) return AccountSignerKind.signerApp;
    if (signer is Nip46EventSigner) return AccountSignerKind.bunker;
    if (account.type == AccountType.privateKey) {
      return AccountSignerKind.privateKey;
    }
    return AccountSignerKind.external;
  }

  void _refreshAccountsState() {
    accountPubkeys.assignAll(ndk.accounts.accounts.keys);
    final pubkey = ndk.accounts.getPublicKey();
    activePubkey.value = pubkey;
    activeNpub.value = pubkey == null ? null : Nip19.encodePubKey(pubkey);
  }

  String? get npub {
    final pk = publicKey;
    if (pk == null) return null;
    return Nip19.encodePubKey(pk);
  }

  String? getNsec() {
    final account = ndk.accounts.getLoggedAccount();
    if (account == null || account.type != AccountType.privateKey) return null;

    final privateKey = (account.signer as dynamic).privateKey as String?;
    if (privateKey == null) return null;

    return Nip19.encodePrivateKey(privateKey);
  }
}
