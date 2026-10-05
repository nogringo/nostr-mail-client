import 'dart:async';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart'
    hide RelayListFound;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/entities.dart' hide RelaySet;
import 'package:ndk/ndk.dart' hide RelaySet;

import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/models/relay_list_discovery_result.dart';
import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/relay_list_discovery.dart';
import 'package:nmail_core/utils/relay_hint_parser.dart';

enum RelaySetupStage {
  /// Sweeping every relay worth asking.
  searching,

  /// Nothing answered, so an empty result proves nothing.
  unreachable,

  /// The relays answered and this account has no NIP-65 list.
  missing,
}

enum HintOutcome { notFound, unreachable, nip05NotFound, nip05Unreachable }

/// The way out of this screen the user picked. Each one is slow offline, so the
/// button that started it carries the spinner and the others stay disabled
/// meanwhile.
enum RelaySetupAction { useFound, create }

class RelaySetupController extends ChangeNotifier {
  RelaySetupController() {
    _device.isOffline.addListener(_handleOnlineEdge);
    _startAutoSearch();
  }

  final hintController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final _ndk = GetIt.I<Ndk>();
  final _device = GetIt.I<DeviceConnectivityService>();
  late final RelayListDiscovery _discovery = RelayListDiscovery(
    _ndk,
    device: _device,
  );
  bool _isDisposed = false;

  /// An online edge that landed mid-search, replayed once the search settles.
  bool _searchAgainWhenSettled = false;

  RelaySetupStage stage = RelaySetupStage.searching;

  /// Held back briefly so a search that resolves immediately does not flash a
  /// spinner on the way to the inbox.
  bool showProgress = false;

  bool isSearchingHint = false;
  RelaySetupAction? runningAction;
  HintOutcome? hintOutcome;
  RelayListFound? hintResult;

  bool get isLeaving => runningAction != null;

  String get pubkey => GetIt.I<AuthController>().publicKey!;

  @override
  void dispose() {
    _isDisposed = true;
    _device.isOffline.removeListener(_handleOnlineEdge);
    _discovery.dispose();
    hintController.dispose();
    super.dispose();
  }

  /// The network came back, so recover without waiting for the retry button.
  void _handleOnlineEdge() {
    if (_device.isOffline.value || isLeaving) return;
    if (stage == RelaySetupStage.searching) {
      _searchAgainWhenSettled = true;
      return;
    }
    if (stage != RelaySetupStage.unreachable) return;
    unawaited(_recoverAfterOnlineEdge());
  }

  /// Rides the reconnect the service already scheduled instead of racing it
  /// with one of its own: a force-reconnect fired before the network carries
  /// traffic re-arms NDK's backoff on every relay.
  Future<void> _recoverAfterOnlineEdge() async {
    stage = RelaySetupStage.searching;
    showProgress = true;
    notifyListeners();

    await _device.reconnectSoon();
    if (_isDisposed) return;

    await _startAutoSearch(showProgressNow: true);
  }

  Future<void> _startAutoSearch({bool showProgressNow = false}) async {
    stage = RelaySetupStage.searching;
    showProgress = showProgressNow;
    notifyListeners();

    if (!showProgressNow) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isDisposed || stage != RelaySetupStage.searching) return;
        showProgress = true;
        notifyListeners();
      });
    }

    final result = await _discovery.searchEverywhere(pubkey);
    if (_isDisposed) return;
    if (result is RelayListFound) return _adoptAndContinue(result);

    stage = result is RelayListUnreachable
        ? RelaySetupStage.unreachable
        : RelaySetupStage.missing;
    notifyListeners();

    if (!_searchAgainWhenSettled) return;
    _searchAgainWhenSettled = false;
    if (stage == RelaySetupStage.unreachable) await _recoverAfterOnlineEdge();
  }

  Future<void> retryAutoSearch() async {
    if (isLeaving || stage == RelaySetupStage.searching) return;

    stage = RelaySetupStage.searching;
    showProgress = true;
    notifyListeners();

    // Capped because the pass awaits each relay in turn: offline that is 4s
    // apiece, and this one is on a button rather than a background edge.
    await _device.reconnectNow().timeout(
      const Duration(seconds: 6),
      onTimeout: () {},
    );
    if (_isDisposed) return;

    await _startAutoSearch(showProgressNow: true);
  }

  Future<void> _adoptAndContinue(RelayListFound found) async {
    await _discovery.adopt(found);
    if (_isDisposed) return;
    await _continueToInbox();
  }

  Future<void> _continueToInbox() async {
    await GetIt.I<AuthController>().completeLogin();
    // The router already left this screen, and the user may have moved on.
    if (_isDisposed) return;
    AppRouter.router.go(AppRoutes.inbox);
  }

  void clearHintOutcome() {
    if (hintOutcome == null) return;
    hintOutcome = null;
    notifyListeners();
  }

  Future<void> searchHint() async {
    if (isSearchingHint || isLeaving) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final hint = parseRelayHint(hintController.text).hint;
    if (hint == null) return;

    isSearchingHint = true;
    hintOutcome = null;
    hintResult = null;
    notifyListeners();

    try {
      final relays = hint.kind == RelayHintKind.nip05
          ? await _resolveNip05Relays(hint.value)
          : hint.relays;
      if (_isDisposed) return;
      if (relays == null) return;

      final result = await _discovery.searchOn(pubkey, relays);
      if (_isDisposed) return;
      switch (result) {
        case RelayListFound():
          hintResult = result;
        case RelayListUnreachable():
          hintOutcome = HintOutcome.unreachable;
        case RelayListMissing():
          hintOutcome = HintOutcome.notFound;
      }
    } finally {
      if (!_isDisposed) {
        isSearchingHint = false;
        notifyListeners();
      }
    }
  }

  /// Returns null when the identifier itself could not be resolved, having
  /// already recorded the outcome to show.
  Future<List<String>?> _resolveNip05Relays(String identifier) async {
    final resolved = await _ndk.nip05.resolve(identifier);
    if (_isDisposed) return null;
    switch (resolved) {
      case Nip05Found(data: final data):
        final relays = data.relays ?? const <String>[];
        if (relays.isEmpty) {
          hintOutcome = HintOutcome.nip05NotFound;
          return null;
        }
        return relays;
      case Nip05NotFound():
        hintOutcome = HintOutcome.nip05NotFound;
        return null;
      case Nip05ResolveError():
        hintOutcome = HintOutcome.nip05Unreachable;
        return null;
    }
  }

  Future<void> useFoundList() async {
    final found = hintResult;
    if (found == null || isLeaving) return;
    runningAction = RelaySetupAction.useFound;
    notifyListeners();
    try {
      await _discovery.adopt(found);
      if (_isDisposed) return;
      await _continueToInbox();
    } finally {
      if (!_isDisposed) {
        runningAction = null;
        notifyListeners();
      }
    }
  }

  void discardFoundList() {
    hintResult = null;
    notifyListeners();
  }

  Future<void> createRelayList() async {
    if (isLeaving) return;
    runningAction = RelaySetupAction.create;
    notifyListeners();
    try {
      final account = _ndk.accounts.getLoggedAccount()!;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final userRelayList = UserRelayList(
        pubKey: account.pubkey,
        relays: {
          for (final r in NostrConfig.recommendedInboxOutboxRelays)
            r: ReadWriteMarker.readWrite,
        },
        createdAt: now,
        refreshedTimestamp: now,
      );
      final signed = await account.signer.sign(
        userRelayList.toNip65().toEvent(),
      );
      await _ndk.config.cache.saveUserRelayList(userRelayList);
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
      if (_isDisposed) return;
      await _continueToInbox();
    } finally {
      if (!_isDisposed) {
        runningAction = null;
        notifyListeners();
      }
    }
  }
}
