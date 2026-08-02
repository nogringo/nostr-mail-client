import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/account_deleted_controller.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/vanish_relay_row.dart';

/// Terminal screen of a deletion: the account is off this device, and the
/// relays answer the request to vanish one by one.
class AccountDeletedView extends StatelessWidget {
  const AccountDeletedView({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return GetBuilder<AccountDeletedController>(
      init: AccountDeletedController(requestId: requestId),
      builder: (controller) {
        final relays = controller.relays;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _finish(context);
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // The scroll view spans the full width so its scrollbar sits
                  // against the window edge, not against the centred content.
                  Expanded(
                    child: SingleChildScrollView(
                      child: ResponsiveCenter(
                        maxWidth: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.accountDeletedTitle,
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  if (relays.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        l.accountDeletedRelayCount(
                                          controller.erasedCount,
                                          controller.relayCount,
                                        ),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (relays.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              for (final (index, url) in relays.indexed)
                                VanishRelayRow(
                                  url: url,
                                  isErased: controller.isErased(url),
                                  isNotErased: controller.isNotErased(url),
                                  index: index,
                                  count: relays.length,
                                ),
                              if (controller.hasPendingRelays)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    0,
                                  ),
                                  child: Text(
                                    l.accountDeletedPendingNote,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveCenter(
                    maxWidth: 600,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _finish(context),
                          child: Text(l.actionFinish),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _finish(BuildContext context) {
    final isLoggedIn = Get.find<AuthController>().isLoggedIn.value;
    context.go(isLoggedIn ? AppRoutes.inbox : AppRoutes.login);
  }
}
