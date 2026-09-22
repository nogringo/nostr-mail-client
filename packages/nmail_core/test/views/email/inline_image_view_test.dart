import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/views/email/widgets/inline_image_view.dart';

/// A one pixel PNG, small enough to decode in a test.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

void main() {
  group('InlineImageView', () {
    testWidgets('shows nothing while the bytes are loading', (tester) async {
      final completer = Completer<Uint8List?>();
      await _pump(
        tester,
        InlineImageView(bytes: completer.future, alt: 'Logo'),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.text('Logo'), findsNothing);

      completer.complete(_png);
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('paints on the first frame when bytes are already resolved', (
      tester,
    ) async {
      await _pump(
        tester,
        InlineImageView(bytes: Completer<Uint8List?>().future, initial: _png),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('falls back to the alt text when the image is missing', (
      tester,
    ) async {
      await _pump(
        tester,
        InlineImageView(bytes: Future.value(), alt: 'Logo Nmail'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Logo Nmail'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('stays out of the way when a missing image has no alt', (
      tester,
    ) async {
      await _pump(tester, InlineImageView(bytes: Future.value()));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNothing);
      expect(find.byType(Text), findsNothing);
    });
  });
}
