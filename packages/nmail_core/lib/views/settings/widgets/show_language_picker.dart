import 'package:flutter/material.dart';

import 'package:nmail_core/utils/responsive_helper.dart';
import 'language_dialog.dart';
import 'language_sheet.dart';

Future<void> showLanguagePicker(BuildContext context) {
  if (ResponsiveHelper.isMobile(context)) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const LanguageSheet(),
    );
  }

  return showDialog(context: context, builder: (_) => const LanguageDialog());
}
