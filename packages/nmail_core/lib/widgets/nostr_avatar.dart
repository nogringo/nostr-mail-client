import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/services/metadata_service.dart';
import 'nostr_avatar_visual.dart';

/// Circular Nostr avatar.
///
/// By default the metadata (picture, name initial) is resolved reactively from
/// the in-RAM [MetadataService] keyed by [pubkey], so it never re-flashes once
/// loaded and updates in place when it arrives. Pass [metadata] to override
/// that lookup with a value you already hold: the signed-in user, a live
/// profile-edit preview, or a synthetic metadata built from local data.
class NostrAvatar extends StatelessWidget {
  final String pubkey;
  final Metadata? metadata;
  final double radius;

  /// See [NostrAvatarVisual.name].
  final String? name;

  const NostrAvatar({
    super.key,
    required this.pubkey,
    this.metadata,
    this.radius = 20,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    // Explicit override, or no pubkey to resolve: render synchronously.
    if (metadata != null || pubkey.isEmpty) {
      return NostrAvatarVisual(
        pubkey: pubkey,
        metadata: metadata,
        radius: radius,
        name: name,
      );
    }
    return ValueListenableBuilder(
      valueListenable: GetIt.I<MetadataService>().of(pubkey),
      builder: (context, metadata, _) => NostrAvatarVisual(
        pubkey: pubkey,
        metadata: metadata,
        radius: radius,
        name: name,
      ),
    );
  }
}
