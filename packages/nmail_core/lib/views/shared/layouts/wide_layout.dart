import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/views/contacts/widgets/contacts_sidebar.dart';
import 'package:nmail_core/views/inbox/widgets/app_sidebar.dart';
import 'package:nmail_core/views/shared/layout_constants.dart';
import 'package:nmail_core/views/shared/left_rail.dart';

class WideLayout extends StatelessWidget {
  const WideLayout({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = GoRouterState.of(context).matchedLocation;
    final isContacts = loc == AppRoutes.contacts;
    return Row(
      children: [
        const LeftRail(),
        Container(
          width: LayoutConstants.sidebarWidth,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(LayoutConstants.borderRadius),
              bottomLeft: Radius.circular(LayoutConstants.borderRadius),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: isContacts ? const ContactsSidebar() : const AppSidebar(),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: colorScheme.outlineVariant,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(LayoutConstants.borderRadius),
                bottomRight: Radius.circular(LayoutConstants.borderRadius),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              // A static divider, as on the inbox toolbar, replaces the Material
              // 3 scrolled-under swap to surfaceContainer, which reads as a
              // full-width color jump behind the centered content of a pane.
              data: theme.copyWith(
                appBarTheme: theme.appBarTheme.copyWith(
                  backgroundColor: colorScheme.surface,
                  scrolledUnderElevation: 0,
                  shape: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              child: body,
            ),
          ),
        ),
      ],
    );
  }
}
