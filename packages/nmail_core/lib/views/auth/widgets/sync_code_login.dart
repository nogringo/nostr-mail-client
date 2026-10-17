import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/sync_code_login_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/sync_code_kind.dart';
import 'package:nmail_core/widgets/controller_builder.dart';
import 'bunker_approval_prompt.dart';

/// One field for every code a user can paste: nsec, ncryptsec or bunker URL.
class SyncCodeLogin extends StatelessWidget {
  const SyncCodeLogin({super.key, required this.onLoggedIn});

  final Future<void> Function() onLoggedIn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ControllerBuilder(
      create: SyncCodeLoginController.new,
      builder: (context, controller) {
        final error = controller.error;
        final isLoggingIn = controller.isLoggingIn;
        final submit = controller.canLogIn ? () => _logIn(controller) : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.authSyncCodeLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextField(
              controller: controller.code,
              enabled: !isLoggingIn,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => submit?.call(),
              decoration: InputDecoration(
                hintText: 'nsec1, ncryptsec1, bunker://',
                errorText: switch (error) {
                  SyncCodeLoginError.invalidCode => l.authInvalidSyncCode,
                  SyncCodeLoginError.bunkerFailed =>
                    l.authBunkerConnectionFailed,
                  _ => null,
                },
              ),
            ),
            if (controller.kind == SyncCodeKind.ncryptsec)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: controller.password,
                  enabled: !isLoggingIn,
                  autofocus: true,
                  obscureText: true,
                  onSubmitted: (_) => submit?.call(),
                  decoration: InputDecoration(
                    labelText: l.authPasswordLabel,
                    errorText: error == SyncCodeLoginError.wrongPassword
                        ? l.authWrongPassword
                        : null,
                  ),
                ),
              ),
            if (controller.bunkerAuthUrl case final url?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: BunkerApprovalPrompt(url: url),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: submit,
              icon: isLoggingIn
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: Text(l.authLogIn),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logIn(SyncCodeLoginController controller) async {
    if (await controller.logIn()) await onLoggedIn();
  }
}
