import 'package:get/get.dart';
import 'package:sembast/sembast.dart';

import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/storage_service.dart';

/// Unsubscriptions waiting for the push server to acknowledge them.
///
/// They outlive the account they concern, so a logout or a removal made offline
/// still unsubscribes on a later launch. Hence their own store, away from the
/// settings that go with an account's local data, and hence the protocol
/// leaving `disable` unauthenticated: replaying needs no key.
class PendingPushDisables {
  PendingPushDisables({Database? db, PushRegistrationService? registration})
    : _dbOverride = db,
      _registrationOverride = registration;

  static final _store = intMapStoreFactory.store('pending_push_disables');

  final Database? _dbOverride;
  final PushRegistrationService? _registrationOverride;
  Future<void>? _flushing;

  Database get _db => _dbOverride ?? Get.find<StorageService>().db;
  PushRegistrationService get _registration =>
      _registrationOverride ?? Get.find<PushRegistrationService>();

  Future<void> add({
    required String pubkey,
    required PushTransport transport,
  }) async {
    await _store.add(_db, {
      'pubkey': pubkey,
      'destination': transport.destination,
      'transport': transport.toJson(),
    });
  }

  /// Drops what [pubkey] has queued for [transport], once it subscribed again:
  /// replaying the disable would undo the subscription that just succeeded.
  Future<void> dropFor({
    required String pubkey,
    required PushTransport transport,
  }) async {
    await _store.delete(
      _db,
      finder: Finder(
        filter: Filter.and([
          Filter.equals('pubkey', pubkey),
          Filter.equals('destination', transport.destination),
        ]),
      ),
    );
  }

  Future<void> flush() {
    return _flushing ??= _flush().whenComplete(() => _flushing = null);
  }

  Future<void> _flush() async {
    for (final record in await _store.find(_db)) {
      final pubkey = record.value['pubkey'];
      final stored = record.value['transport'];
      final transport = stored is Map
          ? PushTransport.fromJson(Map<String, dynamic>.from(stored))
          : null;

      if (pubkey is! String || transport == null) {
        await _store.record(record.key).delete(_db);
        continue;
      }

      final delivery = await _registration.disable(transport, pubkey: pubkey);
      if (delivery != PushDelivery.unreachable) {
        await _store.record(record.key).delete(_db);
      }
    }
  }
}
