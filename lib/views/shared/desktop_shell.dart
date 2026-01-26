import 'package:flutter/material.dart';

import '../../utils/responsive_helper.dart';
import '../inbox/widgets/app_drawer.dart';
import '../inbox/widgets/app_sidebar.dart';
import 'layout_constants.dart';
import 'left_rail.dart';

class DesktopShell extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const DesktopShell({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  Widget _buildBackground(BuildContext context) {
    return Container(color: Theme.of(context).colorScheme.tertiaryContainer);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveHelper.isNotMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (isWide) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(context),
            // Content
            Row(
              children: [
                const LeftRail(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: LayoutConstants.shellPadding,
                  ),
                  child: Container(
                    width: LayoutConstants.sidebarWidth,
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(LayoutConstants.borderRadius),
                        bottomLeft: Radius.circular(
                          LayoutConstants.borderRadius,
                        ),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const AppSidebar(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: LayoutConstants.shellPadding,
                      right: LayoutConstants.shellPadding,
                      bottom: LayoutConstants.shellPadding,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(
                            LayoutConstants.borderRadius,
                          ),
                          bottomRight: Radius.circular(
                            LayoutConstants.borderRadius,
                          ),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Mobile layout with drawer
    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [_buildBackground(context), body],
      ),
    );
  }
}
