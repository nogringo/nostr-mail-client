class AppConfig {
  /// Debounce duration to prevent excessive syncs
  /// when user returns to the app from background
  static const syncDebounceDuration = Duration(seconds: 60);

  static const sourceCodeUrl = 'https://github.com/nogringo/nostr-mail-client';
  static const licenseName = 'MIT';
  static const licenseUrl = '$sourceCodeUrl/blob/main/LICENSE';

  static const developerNpub =
      'npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te';
  static const developerNostrUrl = 'https://njump.me/$developerNpub';
  static const developerGithubUrl = 'https://github.com/nogringo';
}
