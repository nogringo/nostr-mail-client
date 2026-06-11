import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';

import '../utils/string_color.dart';

class EmailAvatar extends StatelessWidget {
  final MailAddress mailAddress;
  final double radius;

  const EmailAvatar({super.key, required this.mailAddress, this.radius = 20});

  Color _getAvatarColor(BuildContext context) {
    if (mailAddress.email.isEmpty) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    return getStringColor(mailAddress.email);
  }

  String _getInitial() {
    if (mailAddress.email.isEmpty) return '?';
    // Use personal name if available, otherwise use first letter of email address
    if (mailAddress.hasPersonalName) {
      return mailAddress.personalName![0].toUpperCase();
    }
    if (mailAddress.email.isNotEmpty) {
      return mailAddress.email[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(context);
    final isDark =
        ThemeData.estimateBrightnessForColor(avatarColor) == Brightness.dark;

    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      child: Text(
        _getInitial(),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
