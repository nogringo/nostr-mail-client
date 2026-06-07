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
}
