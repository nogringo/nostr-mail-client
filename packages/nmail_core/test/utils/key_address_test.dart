import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/local_part_format.dart';
import 'package:nmail_core/utils/key_address.dart';

void main() {
  const hex =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  final npub = Nip19.encodePubKey(hex);
  final base36 = BigInt.parse(hex, radix: 16).toRadixString(36);

  test('matches each key format and keeps the domain', () {
    expect(matchKeyAddress('$npub@uid.ovh', hex)?.format, LocalPartFormat.npub);
    expect(matchKeyAddress('$hex@uid.ovh', hex)?.format, LocalPartFormat.hex);
    expect(
      matchKeyAddress('$base36@uid.ovh', hex)?.format,
      LocalPartFormat.base36,
    );
    expect(matchKeyAddress('$npub@uid.ovh', hex)?.domain, 'uid.ovh');
  });

  test('ignores custom local parts and other keys', () {
    expect(matchKeyAddress('alice@uid.ovh', hex), isNull);
    expect(
      matchKeyAddress('${hex.replaceFirst('0', 'f')}@uid.ovh', hex),
      isNull,
    );
  });
}
