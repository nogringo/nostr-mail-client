import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'from_option_tile.dart';

class FromSelectorSheet extends StatelessWidget {
  const FromSelectorSheet({super.key, required this.controller});

  final ComposeController controller;

  static Future<void> show(BuildContext context, ComposeController controller) {
    return showModalBottomSheet(
      context: context,
      // Compose lives in the shell navigator, which would confine the sheet
      // to the content area instead of the whole window.
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => FromSelectorSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Width of RadioListTile's shrink-wrapped Radio, so the icon centers on it.
    final radioSize =
        kMinInteractiveDimension -
        8 +
        Theme.of(context).visualDensity.baseSizeAdjustment.dx;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.composeSendAs, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Flexible(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => RadioGroup<String>(
                groupValue: controller.selectedFrom?.address,
                onChanged: (address) {
                  controller.selectFrom(
                    controller.fromOptions.firstWhere(
                      (o) => o.address == address,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final option in controller.fromOptions)
                      FromOptionTile(option: option),
                    ListTile(
                      leading: SizedBox.square(
                        dimension: radioSize,
                        child: const Icon(Icons.add),
                      ),
                      title: Text(l.composeCreateNewIdentity),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.settingsIdentitiesNew);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
