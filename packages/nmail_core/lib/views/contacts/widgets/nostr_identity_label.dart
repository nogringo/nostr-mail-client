import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';

class NostrIdentityName extends StatelessWidget {
  final String identifier;

  const NostrIdentityName({super.key, required this.identifier});

  @override
  Widget build(BuildContext context) {
    final pubkey = AddressBookVCardMapper.normalizeNostrPubkey(identifier);
    if (pubkey == null) {
      return const Text('Nostr', overflow: TextOverflow.ellipsis);
    }

    return Obx(() {
      final metadata = Get.find<MetadataService>().of(pubkey).value;
      return Text(
        metadata?.getBestName() ?? getAnonName(pubkey),
        overflow: TextOverflow.ellipsis,
      );
    });
  }
}
