import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/utils/nostr_avatar_colors.dart';

/// Pure presentation of a Nostr avatar: the profile picture when available,
/// otherwise a deterministic colored initial derived from the pubkey.
///
/// Stateless and synchronous. [NostrAvatar] feeds it the metadata, either
/// reactively from the in-RAM cache or from an explicit override.
class NostrAvatarVisual extends StatelessWidget {
  final String pubkey;
  final Metadata? metadata;
  final double radius;

  /// Takes the place of the profile name for the initial: the name the user
  /// gave a contact.
  final String? name;

  const NostrAvatarVisual({
    super.key,
    required this.pubkey,
    this.metadata,
    this.radius = 20,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = getAvatarColorFromPubkey(pubkey);
    final pictureUrl = metadata?.picture;

    if (pictureUrl != null && pictureUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(pictureUrl),
        backgroundColor: avatarColor.background,
        onBackgroundImageError: (e, s) {},
      );
    }
    final givenName = name?.trim() ?? '';
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor.background,
      child: Text(
        givenName.isNotEmpty
            ? givenName[0].toUpperCase()
            : getInitialFromMetadata(pubkey, metadata),
        style: TextStyle(
          color: avatarColor.text,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
