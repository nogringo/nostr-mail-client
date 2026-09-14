import 'package:ndk/ndk.dart';

import 'package:nmail_core/models/local_part_format.dart';

typedef KeyAddressMatch = ({
  LocalPartFormat format,
  String localPart,
  String domain,
});

/// Matches an address whose local part is the account key as npub, hex or base36.
KeyAddressMatch? matchKeyAddress(String email, String pubkeyHex) {
  final atIndex = email.lastIndexOf('@');
  if (atIndex < 0) return null;
  final local = email.substring(0, atIndex);
  final domain = email.substring(atIndex + 1);

  final LocalPartFormat format;
  if (local == Nip19.encodePubKey(pubkeyHex)) {
    format = LocalPartFormat.npub;
  } else if (local == pubkeyHex) {
    format = LocalPartFormat.hex;
  } else if (local == BigInt.parse(pubkeyHex, radix: 16).toRadixString(36)) {
    format = LocalPartFormat.base36;
  } else {
    return null;
  }
  return (format: format, localPart: local, domain: domain);
}
