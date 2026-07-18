import 'dart:async';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/push_registration_service.dart';
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
        await _nostrMailService.initClient();
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
    await _nostrMailService.initClient();
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
    // authStateChanges fires before initClient() runs, so SettingsController's
    // listener sees an uninitialized client and can't read the synced
    // signature. Now that the Nostr client is up (and its private-settings
    // cache primed by NostrMailClient.create()), pull it into the Rx.
    await Get.find<SettingsController>().reloadSyncedSettings();
    if (Get.find<SettingsController>().notificationsEnabled.value &&
        Get.isRegistered<PushRegistrationService>()) {
      final pushService = Get.find<PushRegistrationService>();
      await pushService.prepareCurrentTransport();
      await pushService.registerCurrentTransport();
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
    await broadcastQueue.broadcast(signedMetadata, relays: signalingTargets);

    // NIP-65 relay list (kind 10002)
    final signedNip65 = await account.signer.sign(
      userRelayList.toNip65().toEvent(),
    );
    await ndk.config.cache.saveUserRelayList(userRelayList);
    await broadcastQueue.broadcast(signedNip65, relays: signalingTargets);

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
    await broadcastQueue.broadcast(signedDm, relays: signalingTargets);

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
    await broadcastQueue.broadcast(signedBlossom, relays: signalingTargets);

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

    final generation = ++_accountSwitchGeneration;

    if (_nostrMailService.isClientInitialized) {
      _nostrMailService.client.stopWatching();
    }
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

    if (Get.isRegistered<InboxController>()) {
      await Get.find<InboxController>().activateForCurrentAccount(
        folder: MailFolder.inbox,
      );
      if (generation != _accountSwitchGeneration) return;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      if (Get.find<SettingsController>().notificationsEnabled.value &&
          Get.isRegistered<PushRegistrationService>()) {
        await Get.find<PushRegistrationService>().disableCurrentTransport();
      }
      if (Get.isRegistered<InboxController>()) {
        await Get.find<InboxController>().resetForAccountChange();
      }
      if (Get.isRegistered<ScheduledController>()) {
        await Get.delete<ScheduledController>();
      }
      await _nostrMailService.logout();
      await ndkFlutter.saveAccountsState();
      _refreshAccountsState();

      // Reset all auth state
      isLoggedIn.value = false;
      userMetadata.value = null;
      isRegistering.value = false;
      username.value = '';
      usernameController.clear();
      showMoreOptions.value = false;

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
