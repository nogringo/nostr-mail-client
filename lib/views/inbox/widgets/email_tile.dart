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
  Metadata? _metadata;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final ndk = Get.find<NostrMailService>().ndk;
      final metadata = await ndk.metadata.loadMetadata(
        widget.email.senderPubkey,
      );
      if (mounted && metadata != null) {
        setState(() => _metadata = metadata);
      }
    } catch (_) {}
  }

  String get _displayName {
    if (_metadata?.name != null && _metadata!.name!.isNotEmpty) {
      return _metadata!.name!;
    }
    // Fallback to short npub
    final pk = widget.email.senderPubkey;
    if (pk.length > 16) {
      return 'npub...${pk.substring(pk.length - 6)}';
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
    if (_metadata?.picture != null && _metadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_metadata!.picture!),
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
    if (_metadata?.name != null && _metadata!.name!.isNotEmpty) {
      return _metadata!.name![0].toUpperCase();
    }
    final pk = widget.email.senderPubkey;
    return pk.isNotEmpty ? pk[0].toUpperCase() : '?';
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
