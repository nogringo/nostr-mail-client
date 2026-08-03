import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';

import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/models/relay_list_discovery_result.dart';
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

/// The way out of this screen the user picked. Every one of them ends in
/// [AuthController.completeLogin], which is slow offline, so the button that
/// started it carries the spinner and the others stay disabled meanwhile.
enum RelaySetupAction { useFound, create, continueWithout }

class RelaySetupController extends GetxController {
  final hintController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final _ndk = Get.find<Ndk>();
  late final RelayListDiscovery _discovery = RelayListDiscovery(_ndk);

  RelaySetupStage stage = RelaySetupStage.searching;

  /// Held back briefly so a search that resolves immediately does not flash a
  /// spinner on the way to the inbox.
  bool showProgress = false;

  bool isSearchingHint = false;
  RelaySetupAction? runningAction;
  HintOutcome? hintOutcome;
  RelayListFound? hintResult;

  bool get isLeaving => runningAction != null;

  String get pubkey => Get.find<AuthController>().publicKey!;

  @override
  void onInit() {
    super.onInit();
    _startAutoSearch();
  }

  @override
  void onClose() {
    _discovery.dispose();
    hintController.dispose();
    super.onClose();
  }

  Future<void> _startAutoSearch({bool showProgressNow = false}) async {
    stage = RelaySetupStage.searching;
    showProgress = showProgressNow;
    update();

    if (!showProgressNow) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (isClosed || stage != RelaySetupStage.searching) return;
        showProgress = true;
        update();
      });
    }

    final result = await _discovery.searchEverywhere(pubkey);
    if (isClosed) return;
    if (result is RelayListFound) return _adoptAndContinue(result);

    stage = result is RelayListUnreachable
        ? RelaySetupStage.unreachable
        : RelaySetupStage.missing;
    update();
  }

  Future<void> retryAutoSearch() async {
    if (isLeaving || stage == RelaySetupStage.searching) return;

    stage = RelaySetupStage.searching;
    showProgress = true;
    update();

    // A failed connect blocks the next try for FAIL_RELAY_CONNECT_TRY_AFTER_
    // SECONDS, and `requests.query` never forces, so without this the button
    // does nothing at all for a minute. Capped because tryReconnect awaits
    // each relay in turn: offline that is 4s apiece.
    //
    // TODO: an app-wide connectivity_plus service would make this button a
    // fallback rather than the only way back: call tryReconnect on the
    // none -> connected edge (debounced, iOS and macOS emit duplicates), and
    // let `RelayListDiscovery` answer Unreachable straight away on `none`
    // instead of waiting out its timeout. Only its negative is trustworthy,
    // so relay connectivity stays the source of truth.
    await _ndk.connectivity.tryReconnect().timeout(
      const Duration(seconds: 6),
      onTimeout: () {},
    );
    if (isClosed) return;

    await _startAutoSearch(showProgressNow: true);
  }

  Future<void> _adoptAndContinue(RelayListFound found) async {
    await _discovery.adopt(found);
    if (isClosed) return;
    await _continueToInbox();
  }

  Future<void> _continueToInbox() async {
    await Get.find<AuthController>().completeLogin();
    AppRouter.router.go(AppRoutes.inbox);
  }

  void clearHintOutcome() {
    if (hintOutcome == null) return;
    hintOutcome = null;
    update();
  }

  Future<void> searchHint() async {
    if (isSearchingHint || isLeaving) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final hint = parseRelayHint(hintController.text).hint;
    if (hint == null) return;

    isSearchingHint = true;
    hintOutcome = null;
    hintResult = null;
    update();

    try {
      final relays = hint.kind == RelayHintKind.nip05
          ? await _resolveNip05Relays(hint.value)
          : hint.relays;
      if (isClosed) return;
      if (relays == null) return;

      final result = await _discovery.searchOn(pubkey, relays);
      if (isClosed) return;
      switch (result) {
        case RelayListFound():
          hintResult = result;
        case RelayListUnreachable():
          hintOutcome = HintOutcome.unreachable;
        case RelayListMissing():
          hintOutcome = HintOutcome.notFound;
      }
    } finally {
      if (!isClosed) {
        isSearchingHint = false;
        update();
      }
    }
  }

  /// Returns null when the identifier itself could not be resolved, having
  /// already recorded the outcome to show.
  Future<List<String>?> _resolveNip05Relays(String identifier) async {
    final resolved = await _ndk.nip05.resolve(identifier);
    if (isClosed) return null;
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
    update();
    try {
      await _discovery.adopt(found);
      if (isClosed) return;
      await _continueToInbox();
    } finally {
      if (!isClosed) {
        runningAction = null;
        update();
      }
    }
  }

  void discardFoundList() {
    hintResult = null;
    update();
  }

  Future<void> createRelayList() async {
    if (isLeaving) return;
    runningAction = RelaySetupAction.create;
    update();
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
      await Get.find<OfflineBroadcast>().broadcast(
        signed,
        relays: {
          ...NostrConfig.popularRelays,
          ...NostrConfig.discoveryRelays,
          ...userRelayList.writeUrls,
        }.toList(),
        pubkey: account.pubkey,
      );
      if (isClosed) return;
      await _continueToInbox();
    } finally {
      if (!isClosed) {
        runningAction = null;
        update();
      }
    }
  }

  Future<void> continueWithoutList() async {
    if (isLeaving) return;
    runningAction = RelaySetupAction.continueWithout;
    update();
    try {
      await _continueToInbox();
    } finally {
      if (!isClosed) {
        runningAction = null;
        update();
      }
    }
  }
}
