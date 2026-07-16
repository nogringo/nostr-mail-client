import 'dart:convert';
import 'dart:io';

import 'package:ndk/ndk.dart';

class ScreenshotKeys {
  final ScreenshotAccount primary;
  final Map<String, ScreenshotAccount> senders;

  const ScreenshotKeys({required this.primary, required this.senders});

  static Future<ScreenshotKeys> load(String path, String locale) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('Missing keys file: $path');
    }
    final root = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final localeKeys = root[locale] as Map<String, dynamic>?;
    if (localeKeys == null) {
      throw StateError('No keys found for locale "$locale" in $path');
    }
    final sendersJson = localeKeys['senders'] as Map<String, dynamic>? ?? {};
    final bridge = root['bridge'] as String?;
    if (bridge == null) {
      throw StateError('No global bridge key found in $path');
    }
    return ScreenshotKeys(
      primary: ScreenshotAccount.fromNsec(localeKeys['primary'] as String),
      senders: {
        'bridge': ScreenshotAccount.fromNsec(bridge),
        for (final entry in sendersJson.entries)
          entry.key: ScreenshotAccount.fromNsec(entry.value as String),
      },
    );
  }
}

class ScreenshotAccount {
  final String privateKey;
  final String pubkey;

  ScreenshotAccount._({required this.privateKey, required this.pubkey});

  factory ScreenshotAccount.fromNsec(String nsec) {
    final privateKey = Nip19.decode(nsec);
    final pubkey = Bip340EventSignerFactory().derivePublicKey(privateKey);
    return ScreenshotAccount._(privateKey: privateKey, pubkey: pubkey);
  }
}
