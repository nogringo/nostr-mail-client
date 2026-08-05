class NostrConfig {
  static const bootstrapRelays = [
    'wss://relay.nmail.li',
    'wss://nostr-01.yakihonne.com',
    'wss://nos.lol',
    'wss://relay.damus.io',
    'wss://relay.primal.net',
  ];

  /// Popular relays used to broadcast signaling events (kinds 0, 10002,
  /// 10050, 10063) widely for maximum discoverability.
  static const popularRelays = [
    'wss://relay.nmail.li',
    'wss://nostr-01.yakihonne.com',
    'wss://nos.lol',
    'wss://purplepag.es',
    'wss://relay.damus.io',
    'wss://relay.primal.net',
  ];

  /// Relays that index kind 0 / 10002 for the whole network, queried when the
  /// user's NIP-65 list is not on the bootstrap relays.
  static const discoveryRelays = [
    'wss://purplepag.es',
    'wss://user.kindpag.es',
  ];

  static const recommendedInboxOutboxRelays = [
    'wss://relay.nmail.li',
    'wss://nostr-01.yakihonne.com',
    'wss://relay.damus.io',
    'wss://relay.primal.net',
  ];

  static const recommendedDmRelays = [
    'wss://auth.nostr1.com',
    'wss://relay.nmail.li',
  ];

  static const recommendedBlossomServers = [
    'https://blossom.nmail.li',
    'https://blossom.yakihonne.com',
    'https://blossom.primal.net',
  ];

  static const recommendedBridges = ['uid.ovh'];

  /// Scheduler DVM that runs kind:5905 jobs to deliver scheduled emails.
  static const schedulerDvm =
      '25c75b8453b318c591ac8a09455fcdf96d9582d1636e4c0df87c5d43963f26d4';
}
