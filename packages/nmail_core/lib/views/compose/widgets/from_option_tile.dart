import 'package:flutter/material.dart';
import 'package:nmail_core/models/from_option.dart';

import 'from_address_text.dart';

class FromOptionTile extends StatelessWidget {
  const FromOptionTile({super.key, required this.option});

  final FromOption option;

  @override
  Widget build(BuildContext context) {
    final displayName = option.displayName;

    return RadioListTile<String>(
      value: option.address,
      controlAffinity: ListTileControlAffinity.leading,
      title: FromAddressText(address: option.address),
      subtitle: displayName == null || displayName.isEmpty
          ? null
          : Text(displayName, overflow: TextOverflow.ellipsis),
    );
  }
}
