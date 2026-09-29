import 'package:flutter/material.dart';

abstract class LayoutConstants {
  static const double railWidth = kToolbarHeight;
  static const double sidebarWidth = 250;
  static const double shellPadding = 16;
  static const double borderRadius = 16;
  static const double accountMenuWidth = 272;
  static const double windowCaptionHeight = 32;

  /// Space below a scrolling list so its last item clears the FAB. 56 is the
  /// standard FAB height, the second margin a gap above it. Scaffold lifts the
  /// FAB above the system navigation bar, so its inset is added too.
  static double fabClearance(BuildContext context) =>
      56 +
      2 * kFloatingActionButtonMargin +
      MediaQuery.paddingOf(context).bottom;

  /// Inset of the navigation rows from the sidebar and drawer edges, wide
  /// enough for the desktop scrollbar to run beside them, not over them.
  static const double navigationInset = 12;
}
