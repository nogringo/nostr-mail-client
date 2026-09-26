import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';

/// A suggestion's name. A Nostr contact that came without one takes it from
/// the profile as soon as it loads.
class ContactSuggestionName extends StatelessWidget {
  const ContactSuggestionName({super.key, required this.contact, this.style});

  final Contact contact;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (contact.isLegacy || contact.displayName?.isNotEmpty == true) {
      return Text(contact.label, style: style, overflow: TextOverflow.ellipsis);
    }
    return Obx(() {
      final metadata = Get.find<MetadataService>().of(contact.pubkey!).value;
      return Text(
        metadata?.realName ?? contact.label,
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    });
  }
}
