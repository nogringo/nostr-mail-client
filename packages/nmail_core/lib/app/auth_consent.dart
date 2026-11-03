import 'package:ndk/ndk.dart';

import '../config/nostr_config.dart';

/// The account's own relays and Blossom servers, as (relay urls, server urls).
typedef OwnHostLists = ({Set<String> relays, Set<String> servers});

/// Loads the lists the logged-in account itself published. Returning null
/// (or throwing) means "unknown" and the caller stays conservative.
typedef OwnHostListsLoader = Future<OwnHostLists?> Function(String pubkey);

/// Resolves the [Ndk] lazily: at bootstrap the handler exists before the
/// instance does, and the first auth question only fires once it runs.
typedef NdkGetter = Ndk Function();

/// Answers ndk's `authHandler`: may this relay or Blossom server see the
/// account's pubkey?
///
/// A yes lets the host tie the account to the connection's IP, so the answer
/// is only yes for hosts the account itself published (NIP-65 kind 10002,
/// DM relays kind 10050, Blossom servers kind 10063/10013) and for the
/// app's built-in defaults. Relays and servers that arrive from other
/// people's lists — discovery results, a recipient's DM relays, attachment
/// hosts named in incoming mail — get a no, and the request stays on the
/// anonymous connection instead.
///
/// Fail-closed: while the own lists are still loading, or when they cannot
/// be read, anything outside the defaults is a no.
class AuthConsent {
  AuthConsent({
    required OwnHostListsLoader loadOwnLists,
    Set<String> defaults = const {},
  }) : _loadOwnLists = loadOwnLists,
       _defaults = defaults.map(_normalize).toSet();

  /// Loader wired to ndk's NIP-65 and Blossom-server-list use cases.
  static OwnHostListsLoader loaderFor(NdkGetter ndk) => (pubkey) async {
    final n = ndk();
    final relays = await n.userRelayLists.getSingleUserRelayList(pubkey);
    final servers = await n.blossomUserServerList.getUserServerList(
      pubkeys: [pubkey],
    );
    return (
      relays: relays?.relays.keys.toSet() ?? <String>{},
      servers: servers?.toSet() ?? <String>{},
    );
  };

  final OwnHostListsLoader _loadOwnLists;
  final Set<String> _defaults;

  String? _loadedFor;
  Set<String> _allowed = const {};
  bool _loading = false;

  static String _normalize(String url) {
    var u = url.trim().toLowerCase();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  /// May [url] be sent [pubkey]'s identity? The `authHandler` signature.
  Future<bool> call(String url, String pubkey) => allow(url, pubkey);

  Future<bool> allow(String url, String pubkey) async {
    final host = _normalize(url);
    // Defaults never need the network, so answering them cannot recurse into
    // ndk while ndk is the one asking.
    if (_defaults.contains(host)) {
      return true;
    }
    if (_loading) {
      // An auth question arrived while the own lists are being fetched (the
      // fetch itself hit a challenging relay). Stay anonymous this once
      // rather than recurse.
      return false;
    }
    if (_loadedFor != pubkey) {
      _loading = true;
      try {
        final own = await _loadOwnLists(pubkey);
        _allowed = {
          ..._defaults,
          ...?own?.relays.map(_normalize),
          ...?own?.servers.map(_normalize),
        };
        _loadedFor = pubkey;
      } catch (_) {
        // Keep whatever was allowed before; unknown lists fail closed below.
        _allowed = _defaults;
        _loadedFor = pubkey;
      } finally {
        _loading = false;
      }
    }
    return _allowed.contains(host);
  }
}
