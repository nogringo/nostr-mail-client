import 'package:nostr_mail/nostr_mail.dart' show PrivateSettings;

import 'package:nmail_core/config/nostr_config.dart';

/// The address to share with non-Nostr senders, so never `<npub>@nostr`.
String primaryEmailAddress({required String npub, PrivateSettings? settings}) {
  final identity = settings?.identities?.firstOrNull;
  if (identity != null) return identity.email;

  final bridge =
      settings?.bridges?.firstOrNull ?? NostrConfig.recommendedBridges.first;
  return '$npub@$bridge';
}
