import 'dart:async';

import 'package:ndk/ndk.dart';

class FakeEventSigner implements EventSigner {
  final publicKey = 'f' * 64;
  Nip01Event? lastEvent;

  @override
  Future<Nip01Event> sign(Nip01Event event) async {
    lastEvent = event;
    return event.copyWith(sig: 'a' * 128, validSig: true);
  }

  @override
  bool canSign() => true;

  @override
  bool cancelRequest(String requestId) => false;

  @override
  Future<String?> decrypt(String msg, String destPubKey, {String? id}) async =>
      null;

  @override
  Future<String?> decryptNip44({
    required String ciphertext,
    required String senderPubKey,
  }) async => null;

  @override
  Future<void> dispose() async {}

  @override
  Future<String?> encrypt(String msg, String destPubKey, {String? id}) async =>
      null;

  @override
  Future<String?> encryptNip44({
    required String plaintext,
    required String recipientPubKey,
  }) async => null;

  @override
  String getPublicKey() => publicKey;

  @override
  List<PendingSignerRequest> get pendingRequests => const [];

  @override
  Stream<List<PendingSignerRequest>> get pendingRequestsStream =>
      const Stream.empty();
}
