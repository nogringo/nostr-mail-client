import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'account_menu_header.dart';
import 'account_switcher_section.dart';
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
        MenuItemButton(
          leadingIcon: const Icon(Icons.copy),
          onPressed: () {
            final npub = auth.currentNpub;
            if (npub != null) {
              Clipboard.setData(ClipboardData(text: npub));
            }
          },
          child: Text(l.inboxCopyNpub),
        ),
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
