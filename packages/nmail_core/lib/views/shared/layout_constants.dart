import 'package:flutter/material.dart';

abstract class LayoutConstants {
  static const double railWidth = kToolbarHeight;
  static const double sidebarWidth = 250;
  static const double shellPadding = 16;
  static const double borderRadius = 16;
  static const double accountMenuWidth = 272;
  static const double windowCaptionHeight = 32;

  /// Space below a scrolling list so its last item clears the FAB. 56 is the
  /// standard FAB height, the second margin a gap above it.
  static const double fabClearance = 56 + 2 * kFloatingActionButtonMargin;
}
