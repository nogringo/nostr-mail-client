import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:sembast/sembast.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';

class DebugToolsController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();
  final _storageService = Get.find<StorageService>();

  Future<void> createOldTrashedEmail(BuildContext context) async {
    final l = AppLocalizations.of(context);
    try {
      final client = _nostrMailService.client;
      final myPubkey = _nostrMailService.getPublicKey();

      if (myPubkey == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.debugNotAuthenticated),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      final builder = MessageBuilder.prepareMultipartAlternativeMessage();
      builder.from = [MailAddress('Debug Test', 'debug@nostr.com')];
      builder.to = [
        MailAddress('Myself', '${Nip19.encodePubKey(myPubkey)}@nostr'),
      ];
      builder.subject =
          'Test Old Email - ${DateTime.now().millisecondsSinceEpoch}';
      builder.addTextPlain(
        'This is a test email that is 31 days old for testing the delete old emails feature.',
      );

      final message = builder.buildMimeMessage();

      await client.sendMime(message, to: [NostrRecipient.fromPubkey(myPubkey)]);

      await Future.delayed(const Duration(milliseconds: 500));

      final sentEmails = await client.getSentEmails();
      final testEmail = sentEmails.lastWhere(
        (email) => email.subject?.contains('Test Old Email') ?? false,
        orElse: () => throw Exception('Could not find test email'),
      );

      await client.moveToTrash(testEmail.id);

      final db = _storageService.db;
      final labelsStore = stringMapStoreFactory.store('labels');
      final labelKey = '${testEmail.id}:folder:trash';
      final labelRecord = await labelsStore.record(labelKey).get(db);

      if (labelRecord != null) {
        final thirtyOneDaysAgoTimestamp =
            DateTime.now()
                .subtract(const Duration(days: 31))
                .millisecondsSinceEpoch ~/
            1000;

        await labelsStore.record(labelKey).update(db, {
          'timestamp': thirtyOneDaysAgoTimestamp,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.debugTestEmailCreated),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.debugTestEmailPartial),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.debugError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
