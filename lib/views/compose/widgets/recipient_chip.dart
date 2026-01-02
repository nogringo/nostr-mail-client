import 'package:flutter/material.dart';

import '../../../models/recipient.dart';

class RecipientChip extends StatelessWidget {
  final Recipient recipient;
  final VoidCallback onDelete;

  const RecipientChip({
    super.key,
    required this.recipient,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (recipient.isLoading) {
      return const Chip(
        shape: StadiumBorder(),
        label: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (recipient.isNostr) {
      return _buildNostrChip();
    }

    return _buildLegacyChip();
  }

  Widget _buildNostrChip() {
    return Chip(
      shape: const StadiumBorder(),
      backgroundColor: Colors.deepPurple.shade50,
      side: BorderSide(color: Colors.deepPurple.shade200),
      avatar: _buildAvatar(),
      label: Text(
        recipient.label,
        style: TextStyle(
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: Colors.deepPurple.shade400,
      ),
      onDeleted: onDelete,
    );
  }

  Widget _buildAvatar() {
    if (recipient.picture != null && recipient.picture!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.deepPurple,
        radius: 12,
        backgroundImage: NetworkImage(recipient.picture!),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.deepPurple,
      radius: 12,
      child: Text(
        _getAvatarText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegacyChip() {
    return Chip(
      shape: const StadiumBorder(),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(color: Colors.grey.shade300),
      label: Text(
        recipient.label,
        style: TextStyle(color: Colors.grey.shade700),
      ),
      deleteIcon: Icon(Icons.close, size: 18, color: Colors.grey.shade500),
      onDeleted: onDelete,
    );
  }

  String _getAvatarText() {
    if (recipient.displayName != null && recipient.displayName!.isNotEmpty) {
      return recipient.displayName![0].toUpperCase();
    }
    if (recipient.pubkey != null && recipient.pubkey!.isNotEmpty) {
      return recipient.pubkey![0].toUpperCase();
    }
    return '?';
  }
}
