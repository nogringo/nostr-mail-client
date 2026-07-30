import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';

/// Best known name for [pubkey], resolved reactively from the in-RAM
/// [MetadataService] and falling back to the deterministic anon name.
class NostrDisplayName extends StatelessWidget {
  const NostrDisplayName({super.key, required this.pubkey, this.style});

  final String pubkey;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final metadata = Get.find<MetadataService>().of(pubkey).value;
      return Text(
        metadata?.getBestName() ?? getAnonName(pubkey),
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    });
  }
}
