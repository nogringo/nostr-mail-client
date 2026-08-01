import 'package:flutter/material.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/responsive_helper.dart';

import 'layout_constants.dart';

/// Keeps full-screen routes clear of the window controls the hidden title bar
/// draws over the top strip. Narrow windows are already inset by `MainApp`,
/// wide routes inside the auth shell by `ShellDesktop`.
///
/// Reported as view padding rather than a `Padding` so the app bar absorbs the
/// strip and paints it, including its scrolled-under color.
class WindowCaptionInset extends StatelessWidget {
  const WindowCaptionInset({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!PlatformHelper.isDesktop || ResponsiveHelper.isMobile(context)) {
      return child;
    }

    final mediaQuery = MediaQuery.of(context);
    const caption = LayoutConstants.windowCaptionHeight;

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(
          top: mediaQuery.padding.top + caption,
        ),
        viewPadding: mediaQuery.viewPadding.copyWith(
          top: mediaQuery.viewPadding.top + caption,
        ),
      ),
      child: child,
    );
  }
}
