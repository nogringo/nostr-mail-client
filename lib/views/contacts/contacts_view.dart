import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/contacts_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import '../inbox/widgets/app_drawer.dart';
import 'widgets/contact_detail_pane.dart';
import 'widgets/contacts_sidebar.dart';
import 'widgets/mobile_contact_detail_page.dart';
import 'widgets/show_contact_form.dart';

class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ContactsController>()) {
      Get.put(ContactsController());
    }
    final isWide = ResponsiveHelper.isNotMobile(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      drawer: isWide ? null : const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isWide
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: l.inboxMenu,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Text(l.contactsTitle),
        actions: [
          Obx(() {
            final controller = Get.find<ContactsController>();
            if (controller.addressBookService.lastError.value == null) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.cloud_sync_outlined),
              tooltip: l.contactsRetry,
              onPressed: controller.retryBroadcasts,
            );
          }),
          if (!isWide)
            Obx(() {
              final controller = Get.find<ContactsController>();
              return IconButton(
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
              );
            }),
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: l.contactsAdd,
              onPressed: () => _showForm(context),
            ),
        ],
      ),
      body: isWide
          ? const ContactDetailPane()
          : ContactsSidebar(
              showActions: false,
              showSelection: false,
              onContactTap: (contact) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MobileContactDetailPage(uid: contact.uid),
                  ),
                );
              },
            ),
    );
  }

  void _showForm(BuildContext context) {
    showContactForm(context);
  }
}
