import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';

import '../utils/nostr_avatar_colors.dart';

/// Pure presentation of a Nostr avatar: the profile picture when available,
/// otherwise a deterministic colored initial derived from the pubkey.
///
/// Stateless and synchronous. [NostrAvatar] feeds it the metadata, either
/// reactively from the in-RAM cache or from an explicit override.
class NostrAvatarVisual extends StatelessWidget {
  final String pubkey;
  final Metadata? metadata;
  final double radius;

  const NostrAvatarVisual({
    super.key,
    required this.pubkey,
    this.metadata,
    this.radius = 20,
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
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor.background,
      child: Text(
        getInitialFromMetadata(pubkey, metadata),
        style: TextStyle(
          color: avatarColor.text,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
