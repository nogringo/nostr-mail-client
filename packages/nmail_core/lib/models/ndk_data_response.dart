import 'package:rxdart/rxdart.dart';

/// What produced a value, so that a null value is never ambiguous.
enum DataOrigin { cache, relays }

/// One value of a local-first read, tagged with its origin.
///
/// | emission          | meaning                          |
/// | ----------------- | -------------------------------- |
/// | `(value, cache)`  | local value, not confirmed       |
/// | `(null, cache)`   | nothing local yet, still loading |
/// | `(value, relays)` | confirmed value                  |
/// | `(null, relays)`  | confirmed: nothing exists        |
class NdkValue<T> {
  const NdkValue(this.value, this.origin);

  const NdkValue.cache(T? value) : this(value, DataOrigin.cache);

  const NdkValue.relays(T? value) : this(value, DataOrigin.relays);

  final T? value;
  final DataOrigin origin;

  bool get isConfirmed => origin == DataOrigin.relays;
}

/// A read that renders from what is known locally, then refines as relays
/// answer.
///
/// Implements the local-first reads ADR proposed for NDK:
/// https://github.com/relaystr/ndk/pull/702
class NdkDataResponse<T> {
  NdkDataResponse(this._subject);

  final BehaviorSubject<NdkValue<T>> _subject;

  /// Emits a [DataOrigin.cache] value first, then every newer
  /// [DataOrigin.relays] value as it arrives. Closes after EOSE or timeout.
  ///
  /// A value that exists but cannot be read, and an absence that no relay could
  /// confirm, are reported as stream errors, never as `(null, relays)`.
  Stream<NdkValue<T>> get stream => _subject.stream;

  /// The last emitted value, relay-confirmed unless the read concludes on
  /// cache.
  Future<NdkValue<T>> get future => _subject.last;
}
