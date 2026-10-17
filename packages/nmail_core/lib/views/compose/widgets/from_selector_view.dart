import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/views/shared/layout_constants.dart';

import 'from_address_text.dart';
import 'from_avatar_view.dart';
import 'from_option_menu_item.dart';
import 'from_selector_sheet.dart';

class FromSelectorView extends StatelessWidget {
  const FromSelectorView({super.key, required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final selected = controller.selectedFrom;
    final hasName = selected?.displayName?.isNotEmpty ?? false;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 4),
          child: Text(
            l.composeFrom,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          ),
        ),
        Expanded(
          child: MenuAnchor(
            style: MenuStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    LayoutConstants.borderRadius,
                  ),
                  side: BorderSide(width: 2, color: colorScheme.outlineVariant),
                ),
              ),
            ),
            menuChildren: [
              for (final option in controller.fromOptions)
                FromOptionMenuItem(
                  option: option,
                  groupValue: selected?.address,
                  onChanged: (address) => controller.selectFrom(
                    controller.fromOptions.firstWhere(
                      (o) => o.address == address,
                    ),
                  ),
                ),
              const Divider(),
              MenuItemButton(
                leadingIcon: const Icon(Icons.add, size: Checkbox.width),
                onPressed: () => context.push(AppRoutes.settingsIdentitiesNew),
                child: Text(l.composeCreateNewIdentity),
              ),
            ],
            builder: (context, menuController, _) => Semantics(
              button: true,
              child: InkWell(
                onTap: () {
                  if (ResponsiveHelper.isMobile(context)) {
                    FromSelectorSheet.show(context, controller);
                  } else if (menuController.isOpen) {
                    menuController.close();
                  } else {
                    menuController.open();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                  child: selected == null
                      ? Text(
                          l.stateLoadingEllipsis,
                          style: TextStyle(color: colorScheme.outline),
                        )
                      : Row(
                          children: [
                            FromAvatarView(option: selected),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasName) ...[
                                    Text(
                                      selected.displayName!,
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    FromAddressText(
                                      address: selected.address,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ] else
                                    FromAddressText(
                                      address: selected.address,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
