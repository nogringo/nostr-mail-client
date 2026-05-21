import 'package:flutter/material.dart';

import '../../../utils/relay_utils.dart';

enum DeliveryTargetStatus { acked, failed, pending }

class DeliveryTargetRow extends StatelessWidget {
  const DeliveryTargetRow({
    super.key,
    required this.url,
    required this.status,
    this.errorMessage,
  });

  final String url;
  final DeliveryTargetStatus status;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, color) = switch (status) {
      DeliveryTargetStatus.acked => (
        Icons.check_circle,
        colorScheme.tertiary,
      ),
      DeliveryTargetStatus.failed => (Icons.cancel, colorScheme.error),
      DeliveryTargetStatus.pending => (
        Icons.hourglass_empty,
        colorScheme.onSurfaceVariant,
      ),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(formatRelayUrl(url)),
      subtitle: errorMessage != null ? Text(errorMessage!) : null,
      trailing: Icon(icon, color: color),
    );
  }
}
