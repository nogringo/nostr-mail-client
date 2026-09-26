import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/utils/color_contrast.dart';

MailEntry _entry(String color) =>
    MailEntry(id: 'aaaaaaaaaaaaaaaa', name: 'Entry', color: color);

void main() {
  group('MailboxesController.colorOf', () {
    for (final brightness in Brightness.values) {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: brightness,
      );
      for (final (name, background) in [
        ('page', scheme.surface),
        ('dialog', scheme.surfaceContainerHigh),
      ]) {
        test('shows the palette as is on a ${brightness.name} $name', () {
          for (final hex in MailEntryFormController.palette) {
            expect(
              MailboxesController.colorOf(_entry(hex), on: background),
              MailboxesController.parseEntryColor(hex),
              reason: hex,
            );
          }
        });
      }
    }

    test('lifts white off a light page', () {
      final surface = ColorScheme.fromSeed(seedColor: Colors.indigo).surface;
      final shown = MailboxesController.colorOf(_entry('#FFFFFF'), on: surface);
      expect(
        contrastRatio(shown, surface),
        greaterThan(contrastRatio(Colors.white, surface)),
      );
    });

    test('lifts black off a dark page', () {
      final surface = ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ).surface;
      final shown = MailboxesController.colorOf(_entry('#000000'), on: surface);
      expect(
        contrastRatio(shown, surface),
        greaterThan(contrastRatio(Colors.black, surface)),
      );
    });
  });
}
