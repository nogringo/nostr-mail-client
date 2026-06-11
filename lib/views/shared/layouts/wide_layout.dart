import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail_client/app/routes/app_routes.dart';
import 'package:nostr_mail_client/views/contacts/widgets/contacts_sidebar.dart';
import 'package:nostr_mail_client/views/inbox/widgets/app_sidebar.dart';
import 'package:nostr_mail_client/views/shared/layout_constants.dart';
import 'package:nostr_mail_client/views/shared/left_rail.dart';

class WideLayout extends StatelessWidget {
  const WideLayout({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            child: body,
          ),
        ),
      ],
    );
  }
}
