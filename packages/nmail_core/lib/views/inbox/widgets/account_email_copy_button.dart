import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../../shared/account_email_text.dart';

class AccountEmailCopyButton extends StatelessWidget {
  AccountEmailCopyButton({super.key});

  final _copied = false.obs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final email = auth.primaryEmail;
      if (email == null) return const SizedBox.shrink();

      return TextButton.icon(
        onPressed: () => _copy(email),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
        iconAlignment: IconAlignment.end,
        icon: Icon(
          _copied.value ? Icons.check : Icons.copy,
          semanticLabel: l.inboxCopyEmail,
        ),
        label: const AccountEmailText(),
      );
    });
  }

  void _copy(String email) {
    Clipboard.setData(ClipboardData(text: email));
    _copied.value = true;
    Future.delayed(const Duration(seconds: 2), () => _copied.value = false);
  }
}
