import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Image.asset('icons/original_transparent_3x.png', width: 80, height: 80),
        const SizedBox(height: 24),
        Text(
          l.authHeaderTitle,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
