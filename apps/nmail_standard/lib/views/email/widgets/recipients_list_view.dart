import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nmail_standard/controllers/contacts_controller.dart';
import 'package:nmail_standard/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:nmail_standard/views/contacts/widgets/show_contact_form.dart';
import 'package:nmail_standard/widgets/email_avatar.dart';
import 'package:nmail_standard/widgets/nostr_avatar.dart';

import '../email_controller.dart';

class RecipientsListView extends StatelessWidget {
  const RecipientsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final email = EmailController.to.email;
    if (email == null) return const SizedBox.shrink();

    final to = email.mime.to ?? [];
    final cc = email.mime.cc ?? [];
    final bcc = email.mime.bcc ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (to.isNotEmpty) ...[
          _buildRecipientSection(context, l.emailRecipientTo, to),
        ],
        if (cc.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRecipientSection(context, l.emailRecipientCc, cc),
        ],
        if (bcc.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRecipientSection(context, l.emailRecipientBcc, bcc),
        ],
      ],
    );
  }

  Widget _buildRecipientSection(
    BuildContext context,
    String label,
    List<MailAddress> recipients,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recipients
                .map((recipient) => _buildRecipientChip(context, recipient))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientChip(BuildContext context, MailAddress recipient) {
    final emailAddress = recipient.email;

    if (emailAddress.contains('@nostr')) {
      return _buildNostrChip(context, recipient);
    }

    return _buildLegacyChip(context, recipient);
  }

  Widget _buildNostrChip(BuildContext context, MailAddress recipient) {
    final colorScheme = Theme.of(context).colorScheme;
    final pubkey = extractPubkeyFromAddress(recipient.email);
    final metadata = pubkey != null
        ? EmailController.to.recipientsMetadata[pubkey]
        : null;

    final label = metadata != null
        ? metadata.getBestName()
        : (pubkey != null ? getAnonName(pubkey) : recipient.email);

    return ActionChip(
      shape: const StadiumBorder(),
      backgroundColor: colorScheme.primaryContainer,
      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      avatar: _buildAvatar(recipient, pubkey),
      label: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () =>
          _showContactForm(context, displayName: label, pubkey: pubkey),
    );
  }

  Widget _buildLegacyChip(BuildContext context, MailAddress recipient) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      shape: const StadiumBorder(),
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide(color: colorScheme.outlineVariant),
      label: Text(
        recipient.personalName ?? recipient.email,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      onPressed: () => _showContactForm(
        context,
        displayName: recipient.personalName ?? recipient.email,
        email: recipient.email,
      ),
    );
  }

  Widget _buildAvatar(MailAddress recipient, String? pubkey) {
    if (pubkey == null) {
      return EmailAvatar(mailAddress: recipient, radius: 12);
    }

    return NostrAvatar(pubkey: pubkey, radius: 12);
  }

  void _showContactForm(
    BuildContext context, {
    required String displayName,
    String? email,
    String? pubkey,
  }) {
    if (!Get.isRegistered<ContactsController>()) {
      Get.put(ContactsController());
    }
    showContactForm(
      context,
      initialForm: AddressBookContactForm(
        displayName: displayName,
        emails: email == null || email.isEmpty ? const [] : [email],
        nostrPubkeys: pubkey == null || pubkey.isEmpty ? const [] : [pubkey],
      ),
    );
  }
}
