const defaultKeysPath = 'screenshots/seed-keys/screenshot-accounts.json';
const defaultSeedDir = 'screenshots/seed-data';
const defaultBootstrapRelay = 'wss://relay.nmail.li';
const defaultDataRelay = 'wss://test-relay.uid.ovh';

class SeederConfig {
  final String locale;
  final String seedDir;
  final String keysPath;
  final String bootstrapRelay;
  final String dataRelay;
  final bool publish;

  const SeederConfig({
    required this.locale,
    required this.seedDir,
    required this.keysPath,
    required this.bootstrapRelay,
    required this.dataRelay,
    required this.publish,
  });
}
