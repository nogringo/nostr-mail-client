import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'contact_list_tile.dart';
import 'contacts_search_field.dart';
import 'show_contact_form.dart';

class ContactsSidebar extends StatelessWidget {
  final bool showActions;
  final bool showSelection;
  final ValueChanged<AddressBookContact>? onContactTap;

  const ContactsSidebar({
    super.key,
    this.showActions = true,
    this.showSelection = true,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ContactsController>()
        ? Get.find<ContactsController>()
        : Get.put(ContactsController());
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          if (showActions)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showForm(context),
                      icon: const Icon(Icons.person_add),
                      label: Text(l.contactsAdd),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => IconButton(
                      icon: controller.addressBookService.isSyncing.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      tooltip: l.contactsSync,
                      onPressed: controller.addressBookService.isSyncing.value
                          ? null
                          : controller.syncContacts,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, showActions ? 0 : 12, 12, 12),
            child: ContactsSearchField(
              controller: controller.queryController,
              hintText: l.contactsSearchHint,
            ),
          ),
          Expanded(
            child: Obx(() {
              final contacts = controller.filteredContacts;
              if (controller.addressBookService.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (contacts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      controller.query.value.trim().isEmpty
                          ? l.contactsEmpty
                          : l.contactsSearchEmpty,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  if (!showSelection) {
                    return ContactListTile(
                      contact: contact,
                      selected: false,
                      onTap: () {
                        controller.select(contact);
                        onContactTap?.call(contact);
                      },
                    );
                  }
                  return Obx(
                    () => ContactListTile(
                      contact: contact,
                      selected: controller.selectedUid.value == contact.uid,
                      onTap: () {
                        controller.select(contact);
                        onContactTap?.call(contact);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context) {
    showContactForm(context);
  }
}
