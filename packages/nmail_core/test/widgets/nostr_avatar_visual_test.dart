import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/widgets/nostr_avatar_visual.dart';

void main() {
  final pubkey = 'a' * 64;
  final profile = Metadata(pubKey: pubkey, name: 'Paul');

  testWidgets('a given name replaces the profile name for the initial', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NostrAvatarVisual(pubkey: pubkey, metadata: profile),
      ),
    );
    expect(find.text('P'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: NostrAvatarVisual(
          pubkey: pubkey,
          metadata: profile,
          name: 'Tonton',
        ),
      ),
    );
    expect(find.text('T'), findsOneWidget);
  });
}
