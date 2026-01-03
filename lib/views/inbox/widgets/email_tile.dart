import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../services/nostr_mail_service.dart';

class EmailTile extends StatefulWidget {
  final Email email;
  final VoidCallback onTap;

  const EmailTile({super.key, required this.email, required this.onTap});

  @override
  State<EmailTile> createState() => _EmailTileState();
}

class _EmailTileState extends State<EmailTile> {
  Metadata? _senderMetadata;
  Metadata? _bridgeMetadata;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  /// Check if this email was relayed through a bridge
  bool get _isViaBridge {
    final from = widget.email.from;
    if (!from.contains('@')) return false;
    if (!from.endsWith('@nostr'))
      return true; // Legacy email like bob@gmail.com

    // Check if the pubkey in from matches senderPubkey
    final localPart = from.split('@').first;

    // Try npub format
    if (localPart.startsWith('npub1')) {
      try {
        final decodedPubkey = Nip19.decode(localPart);
        return decodedPubkey != widget.email.senderPubkey;
      } catch (_) {
        return true;
      }
    }

    // Try hex format (64 chars)
    if (localPart.length == 64 &&
        RegExp(r'^[a-fA-F0-9]+$').hasMatch(localPart)) {
      return localPart.toLowerCase() != widget.email.senderPubkey.toLowerCase();
    }

    return true;
  }

  Future<void> _loadMetadata() async {
    try {
      final ndk = Get.find<NostrMailService>().ndk;

      // Load bridge/sender metadata
      final senderMeta = await ndk.metadata.loadMetadata(
        widget.email.senderPubkey,
      );
      if (mounted && senderMeta != null) {
        setState(() {
          if (_isViaBridge) {
            _bridgeMetadata = senderMeta;
          } else {
            _senderMetadata = senderMeta;
          }
        });
      }

      // If from contains a pubkey (npub or hex), load its metadata too
      if (_isViaBridge) {
        final from = widget.email.from;
        if (from.endsWith('@nostr')) {
          final localPart = from.split('@').first;
          String? pubkey;

          if (localPart.startsWith('npub1')) {
            try {
              pubkey = Nip19.decode(localPart);
            } catch (_) {}
          } else if (localPart.length == 64 &&
              RegExp(r'^[a-fA-F0-9]+$').hasMatch(localPart)) {
            pubkey = localPart.toLowerCase();
          }

          if (pubkey != null) {
            final fromMeta = await ndk.metadata.loadMetadata(pubkey);
            if (mounted && fromMeta != null) {
              setState(() => _senderMetadata = fromMeta);
            }
          }
        }
      }
    } catch (_) {}
  }

  String get _displayName {
    // Always show the from address/name
    if (_senderMetadata?.name != null && _senderMetadata!.name!.isNotEmpty) {
      return _senderMetadata!.name!;
    }
    return widget.email.from;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: widget.onTap,
          leading: _buildAvatar(context),
          title: Text(
            widget.email.subject.isEmpty
                ? '(No subject)'
                : widget.email.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                widget.email.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          trailing: Text(
            _formatDate(widget.email.date),
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          isThreeLine: true,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mainAvatar = _buildMainAvatar(colorScheme);

    if (!_isViaBridge || _bridgeMetadata?.picture == null) {
      return mainAvatar;
    }

    // Show bridge badge on avatar
    return Stack(
      clipBehavior: Clip.none,
      children: [
        mainAvatar,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
            child: CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage(_bridgeMetadata!.picture!),
              backgroundColor: colorScheme.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainAvatar(ColorScheme colorScheme) {
    if (_senderMetadata?.picture != null &&
        _senderMetadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_senderMetadata!.picture!),
        backgroundColor: colorScheme.primaryContainer,
      );
    }
    return CircleAvatar(
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        _getInitial(),
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitial() {
    if (_senderMetadata?.name != null && _senderMetadata!.name!.isNotEmpty) {
      return _senderMetadata!.name![0].toUpperCase();
    }
    final from = widget.email.from;
    return from.isNotEmpty ? from[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
