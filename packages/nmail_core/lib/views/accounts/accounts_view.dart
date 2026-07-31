import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/accounts_list.dart';

class AccountsView extends StatelessWidget {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return PopScope(
      // Reached via `context.go` from the account menus, so there is nothing to
      // pop and the system back button would otherwise close the app.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _leave(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => _leave(context),
          ),
          title: Text(l.accountsTitle),
        ),
        body: const SafeArea(
          top: false,
          child: ResponsiveCenter(maxWidth: 600, child: AccountsList()),
        ),
      ),
    );
  }

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.inbox);
    }
  }
}
