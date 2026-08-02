import 'dart:io';

import 'package:args/args.dart';
import 'package:ndk/ndk.dart';

import 'config.dart';
import 'keys.dart';
import 'paths.dart';
import 'seed.dart';
import 'seeder.dart';

Future<void> runScreenshotSeeder(List<String> arguments) async {
  try {
    await _run(arguments);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

Future<void> _run(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('locale', abbr: 'l', defaultsTo: 'en')
    ..addOption('seed-dir', defaultsTo: defaultSeedDir)
    ..addOption('keys', defaultsTo: defaultKeysPath)
    ..addOption('bootstrap-relay', defaultsTo: defaultBootstrapRelay)
    ..addOption('data-relay', defaultsTo: defaultDataRelay)
    ..addOption('blossom-server', defaultsTo: defaultBlossomServer)
    ..addFlag('publish', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false);

  final args = parser.parse(arguments);
  if (args['help'] as bool) {
    stdout.writeln('Usage: dart run screenshot_seeder [options]');
    stdout.writeln(parser.usage);
    return;
  }

  final repoRoot = findRepoRoot();
  final config = SeederConfig(
    locale: args['locale'] as String,
    seedDir: resolvePath(args['seed-dir'] as String, repoRoot),
    keysPath: resolvePath(args['keys'] as String, repoRoot),
    bootstrapRelay: args['bootstrap-relay'] as String,
    dataRelay: args['data-relay'] as String,
    blossomServer: args['blossom-server'] as String,
    publish: args['publish'] as bool,
  );

  final seed = await ScreenshotSeed.load(config);
  final keys = await ScreenshotKeys.load(config.keysPath, config.locale);

  _printPlan(config, seed, keys);

  final seeder = ScreenshotSeeder(config: config, seed: seed, keys: keys);
  if (!config.publish) {
    stdout.writeln('');
    stdout.writeln('Messages');
    await seeder.printInboxPreview();
    stdout.writeln('');
    stdout.writeln('Dry run only. Re-run with --publish to broadcast events.');
    return;
  }

  await seeder.run();
}

void _printPlan(SeederConfig config, ScreenshotSeed seed, ScreenshotKeys keys) {
  stdout.writeln('Screenshot seeder');
  stdout.writeln('  locale: ${config.locale}');
  stdout.writeln('  seed: ${seed.path}');
  stdout.writeln('  keys: ${config.keysPath}');
  stdout.writeln('  bootstrap relay: ${config.bootstrapRelay}');
  stdout.writeln('  data relay: ${config.dataRelay}');
  stdout.writeln('  blossom server: ${config.blossomServer}');
  stdout.writeln('  mode: ${config.publish ? 'publish' : 'dry-run'}');
  stdout.writeln('');
  stdout.writeln('Accounts');
  stdout.writeln('  primary: ${Nip19.encodePubKey(keys.primary.pubkey)}');
  for (final entry in keys.senders.entries) {
    stdout.writeln('  ${entry.key}: ${Nip19.encodePubKey(entry.value.pubkey)}');
  }
  stdout.writeln('');
  stdout.writeln('Seed data');
  stdout.writeln('  contacts: ${seed.contacts.length}');
  stdout.writeln('  inbox emails: ${seed.inbox.length}');
}
