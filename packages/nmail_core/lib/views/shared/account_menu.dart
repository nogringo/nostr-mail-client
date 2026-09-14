import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'account_menu_header.dart';
import 'account_switcher_section.dart';
import 'copy_menu_item.dart';
import 'layout_constants.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({
    super.key,
    required this.alignmentOffset,
    required this.builder,
  });

  final Offset alignmentOffset;
  final MenuAnchorChildBuilder builder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final auth = Get.find<AuthController>();

    return MenuAnchor(
      alignmentOffset: alignmentOffset,
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LayoutConstants.borderRadius),
            side: BorderSide(width: 2, color: colorScheme.outlineVariant),
          ),
        ),
      ),
      menuChildren: [
        const AccountMenuHeader(),
        const Divider(height: 1),
        const AccountSwitcherMenuSection(),
        MenuItemButton(
          leadingIcon: const Icon(Icons.person_add_outlined),
          onPressed: () => context.go(AppRoutes.addAccount),
          child: Text(l.inboxAddAccount),
        ),
        const Divider(height: 1),
        CopyMenuItem(label: l.inboxCopyEmail, value: () => auth.primaryEmail),
        CopyMenuItem(label: l.inboxCopyNpub, value: () => auth.currentNpub),
        MenuItemButton(
          leadingIcon: Icon(Icons.logout, color: colorScheme.error),
          onPressed: auth.logout,
          child: Text(
            l.inboxLogout,
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
      builder: builder,
    );
  }
}
