import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../controllers/inbox_controller.dart';
import '../../../services/nostr_mail_service.dart';
import '../../../utils/responsive_helper.dart';

class EmailTile extends StatefulWidget {
  final Email email;
  final VoidCallback onTap;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;

  const EmailTile({
    super.key,
    required this.email,
    required this.onTap,
    this.isSelected = false,
    this.onToggleSelect,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onRestore,
  });

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
    if (!from.endsWith('@nostr')) {
      return true; // Legacy email like bob@gmail.com
    }

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
    final isWide = ResponsiveHelper.isDesktop(context);

    if (isWide) {
      return _buildCompactTile(context);
    }
    return _buildDefaultTile(context);
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final isInTrash =
        Get.find<InboxController>().currentFolder.value == MailFolder.trash;
    final colorScheme = Theme.of(context).colorScheme;

    final menuChildren = <Widget>[
      if (!isInTrash) ...[
        MenuItemButton(
          leadingIcon: const Icon(Icons.reply),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onReply?.call();
          },
          child: const Text('Reply'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.forward),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onForward?.call();
          },
          child: const Text('Forward'),
        ),
        const Divider(height: 1),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete_outline),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onDelete?.call();
          },
          child: const Text('Move to trash'),
        ),
      ] else ...[
        MenuItemButton(
          leadingIcon: const Icon(Icons.restore_from_trash),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onRestore?.call();
          },
          child: const Text('Restore'),
        ),
        MenuItemButton(
          leadingIcon: Icon(Icons.delete_forever, color: colorScheme.error),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onDelete?.call();
          },
          child: Text(
            'Delete permanently',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
    ];

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(onTap: () => Navigator.of(context).pop()),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              surfaceTintColor: colorScheme.surfaceTint,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: menuChildren,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTile(BuildContext context) {
    final subject = widget.email.subject.isEmpty
        ? '(No subject)'
        : widget.email.subject;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        GestureDetector(
          onSecondaryTapUp: (details) =>
              _showContextMenu(context, details.globalPosition),
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              color: widget.isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Checkbox(
                      value: widget.isSelected,
                      onChanged: widget.onToggleSelect != null
                          ? (_) => widget.onToggleSelect!()
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Row(
                      children: [
                        _buildAvatar(context, compact: true),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('—', style: TextStyle(color: Colors.grey[400])),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 3,
                          child: Text(
                            widget.email.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _formatDate(widget.email.date),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildDefaultTile(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onSecondaryTapUp: (details) =>
              _showContextMenu(context, details.globalPosition),
          child: ListTile(
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
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, {bool compact = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = compact ? 14.0 : 20.0;
    final mainAvatar = _buildMainAvatar(colorScheme, radius: radius);

    if (!_isViaBridge || _bridgeMetadata?.picture == null) {
      return mainAvatar;
    }

    // Show bridge badge on avatar
    final badgeRadius = compact ? 7.0 : 10.0;
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
              radius: badgeRadius,
              backgroundImage: NetworkImage(_bridgeMetadata!.picture!),
              backgroundColor: colorScheme.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainAvatar(ColorScheme colorScheme, {double radius = 20}) {
    if (_senderMetadata?.picture != null &&
        _senderMetadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(_senderMetadata!.picture!),
        backgroundColor: colorScheme.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        _getInitial(),
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
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
