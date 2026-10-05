import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/contacts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import '../inbox/widgets/app_drawer.dart';
import 'widgets/contact_actions.dart';
import 'widgets/contact_detail_pane.dart';
import 'widgets/contacts_overflow_menu.dart';
import 'widgets/contacts_sidebar.dart';
import 'widgets/mobile_contact_detail_page.dart';
import 'widgets/show_contact_form.dart';
import '../shared/drawer_menu_button.dart';

class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<ContactsController>();
    final isWide = ResponsiveHelper.isNotMobile(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      drawer: isWide ? null : const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actionsPadding: .only(right: 8),
        leading: isWide
            ? null
            // AppBar only centers a leading that is itself an IconButton,
            // so a wrapped one needs its own Center or it fills the 56px slot.
            : const Center(child: DrawerMenuButton()),
        title: Text(l.contactsTitle),
        actions: [
          ValueListenableBuilder(
            valueListenable: controller.addressBookService.lastError,
            builder: (context, lastError, _) {
              if (lastError == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.cloud_sync_outlined),
                tooltip: l.contactsRetry,
                onPressed: controller.retryBroadcasts,
              );
            },
          ),
          if (isWide)
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final contact = controller.selectedContact;
                if (contact == null) return const SizedBox.shrink();
                return ContactActions(contact: contact);
              },
            ),
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: l.contactsAdd,
              onPressed: () => _showForm(context),
            ),
          const ContactsOverflowMenu(),
        ],
      ),
      body: isWide
          ? const ContactDetailPane()
          : ContactsSidebar(
              showActions: false,
              showSelection: false,
              enablePullToRefresh: true,
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
