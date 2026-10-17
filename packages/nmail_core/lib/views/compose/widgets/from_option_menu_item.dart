import 'package:flutter/material.dart';
import 'package:nmail_core/models/from_option.dart';

import 'from_address_text.dart';

class FromOptionMenuItem extends StatelessWidget {
  const FromOptionMenuItem({
    super.key,
    required this.option,
    required this.groupValue,
    required this.onChanged,
  });

  final FromOption option;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayName = option.displayName;
    final textTheme = Theme.of(context).textTheme;

    return RadioMenuButton<String>(
      value: option.address,
      groupValue: groupValue,
      onChanged: onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FromAddressText(address: option.address),
            if (displayName != null && displayName.isNotEmpty)
              Text(
                displayName,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
