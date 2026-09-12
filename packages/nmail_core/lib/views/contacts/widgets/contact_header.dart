import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../controllers/contacts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'contact_avatar.dart';
import 'contact_copy_feedback.dart';

class ContactHeader extends StatelessWidget {
  final AddressBookContact contact;

  const ContactHeader({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = contact.index.formattedName;
    final copy = _copyNameAction(context, name);
    final label = Padding(
      // Horizontal inset keeps the glyphs clear of the pill's curve, and the
      // gap after the avatar is shortened so the name barely moves.
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        name,
        style: Theme.of(context).textTheme.headlineSmall,
        // One line, so the pill stays a pill: a wrapped name would make it
        // two lines tall and as wide as the row.
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      children: [
        ContactAvatar(contact: contact, radius: 32),
        const SizedBox(width: 8),
        Expanded(
          child: copy == null
              ? label
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: l.actionCopy,
                    triggerMode: TooltipTriggerMode.manual,
                    child: Semantics(
                      button: true,
                      child: InkWell(
                        onTap: copy,
                        customBorder: const StadiumBorder(),
                        child: label,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  VoidCallback? _copyNameAction(BuildContext context, String name) {
    if (name.trim().isEmpty) return null;
    return () => _copyName(context, name);
  }

  void _copyName(BuildContext context, String name) {
    Get.find<ContactsController>().copyText(name);
    showContactCopyFeedback(context, AppLocalizations.of(context).authCopied);
  }
}
