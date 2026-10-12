import 'dart:io';

import 'package:args/command_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<void>(
    'nmail',
    'Email over Nostr from the command line.',
  );

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(64);
  }
}
