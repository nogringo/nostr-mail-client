import 'package:ndk/ndk.dart';

class NostrConfig {
  static const bootstrapRelays = [
    'wss://relay.nmail.li',
    'wss://nostr-01.yakihonne.com',
    'wss://nos.lol',
    'wss://relay.primal.net',
  ];

  /// Popular relays used to broadcast signaling events (kinds 0, 10002,
  /// 10050, 10063) widely for maximum discoverability.
  static const popularRelays = [
    'wss://relay.nmail.li',
    'wss://nostr-01.yakihonne.com',
    'wss://nos.lol',
    'wss://purplepag.es',
    'wss://relay.primal.net',
  ];

  /// Relays that index kind 0 / 10002 for the whole network, queried when the
  /// user's NIP-65 list is not on the bootstrap relays.
  static const discoveryRelays = [
    'wss://purplepag.es',
    'wss://user.kindpag.es',
  ];

  /// NIP-46 relays for QR code logins. Each session keeps the list it logged
  /// in with, so a change only reaches new logins.
  static const nostrConnectRelays = [
    'wss://relay.nmail.li',
    'wss://relay.primal.net',
  ];

  static const nip46ClientMetadata = Nip46ClientMetadata(
    perms: [
      "get_public_key",
      "nip44_encrypt",
      "nip44_decrypt",
      "sign_event:0",
      "sign_event:5",
      "sign_event:13",
      "sign_event:16",
      "sign_event:62",
      "sign_event:1059",
      "sign_event:1301",
      "sign_event:1985",
      "sign_event:1990",
      "sign_event:5905",
      "sign_event:10002",
      "sign_event:10050",
      "sign_event:10063",
      "sign_event:22242",
      "sign_event:24242",
      "sign_event:27235",
      "sign_event:30078",
      "sign_event:31234",
      "sign_event:38522",
    ],
    name: "Nmail",
    url: "https://app.nostrmail.org",
    image:
        "https://raw.githubusercontent.com/nogringo/nostr-mail-client/refs/heads/main/icons/web/icon-512-maskable.png",
  );

  static const recommendedInboxOutboxRelays = [
    'wss://relay.nmail.li',
    'wss://nostr-01.yakihonne.com',
    'wss://relay.primal.net',
  ];

  static const recommendedDmRelays = [
    'wss://relay.nmail.li',
    'wss://auth.nostr1.com',
  ];

  static const recommendedBlossomServers = [
    'https://blossom.nmail.li',
    'https://blossom.ditto.pub',
    'https://blossom.yakihonne.com',
    'https://blossom.primal.net',
  ];

  static const recommendedBridges = ['uid.ovh'];

  /// Scheduler DVM that runs kind:5905 jobs to deliver scheduled emails.
  static const schedulerDvm =
      '25c75b8453b318c591ac8a09455fcdf96d9582d1636e4c0df87c5d43963f26d4';
}
