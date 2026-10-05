import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  AuthController get controller => GetIt.I<AuthController>();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: controller.showMoreOptions,
      builder: (context, showMoreOptions, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NLogin(
            ndkFlutter: controller.ndkFlutter,
            onLoggedIn: () async {
              await controller.onLoggedIn();
              if (!context.mounted) return;
              context.go(
                controller.needsRelayListSetup.value
                    ? AppRoutes.relaySetup
                    : AppRoutes.inbox,
              );
            },
            nsecLabelText: l.authSyncCodeLabel,
            enableNip07Login: false,
            enablePubkeyLogin: false,
            enableBunkerLogin: false,
            enableSignerAppLogin: false,
            enableAccountCreation: false,
          ),
          OutlinedButton.icon(
            onPressed: () {
              ToastHelper.error(
                context,
                l.authInvalidSyncCode,
                description: l.authInvalidSyncCodeDescription,
              );
            },
            icon: const Icon(Icons.login),
            label: Text(l.authLogIn),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => controller.isRegistering.value = true,
            icon: const Icon(Icons.person_add_outlined),
            label: Text(l.authCreateAccount),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  controller.showMoreOptions.value = !showMoreOptions,
              icon: AnimatedRotation(
                turns: showMoreOptions ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more),
              ),
              label: Text(l.authMoreOptions),
            ),
          ),
          AnimatedOpacity(
            opacity: showMoreOptions ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Visibility(
              visible: showMoreOptions,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: NLogin(
                  ndkFlutter: controller.ndkFlutter,
                  onLoggedIn: () async {
                    await controller.onLoggedIn();
                    if (context.mounted) context.go(AppRoutes.inbox);
                  },
                  enableNsecLogin: false,
                  enablePubkeyLogin: false,
                  enableAccountCreation: false,
                  clientMetadata: NostrConfig.nip46ClientMetadata,
                  nostrConnect: NostrConnect(
                    relays: NostrConfig.nostrConnectRelays,
                    clientMetadata: NostrConfig.nip46ClientMetadata,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
