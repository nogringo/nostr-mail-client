import 'dart:async';

import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/services/metadata_service.dart';

/// Never goes to the relays: a profile arrives when the test [resolve]s it.
class FakeMetadataService extends MetadataService {
  final _profiles = <String, Rx<Metadata?>>{};
  final _resolved = StreamController<Metadata>.broadcast();

  @override
  Rx<Metadata?> of(String pubkey) =>
      _profiles.putIfAbsent(pubkey, () => Rx<Metadata?>(null));

  @override
  Stream<Metadata> get resolved => _resolved.stream;

  /// What a relay answering [of] does.
  void resolve(Metadata metadata) {
    of(metadata.pubKey).value = metadata;
    _resolved.add(metadata);
  }

  @override
  void onClose() {}
}
