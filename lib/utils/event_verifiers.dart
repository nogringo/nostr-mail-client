import 'package:ndk/ndk.dart';

/// Event verifier that skips verification (always returns true)
class NoVerifier implements EventVerifier {
  @override
  Future<bool> verify(Nip01Event event) async => true;
}

/// Switchable event verifier that can change behavior at runtime
class SwitchableVerifier implements EventVerifier {
  EventVerifier _delegate;

  SwitchableVerifier(this._delegate);

  void setDelegate(EventVerifier verifier) {
    _delegate = verifier;
  }

  @override
  Future<bool> verify(Nip01Event event) => _delegate.verify(event);
}
