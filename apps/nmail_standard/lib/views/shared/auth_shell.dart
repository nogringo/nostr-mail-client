import 'package:flutter/material.dart';

import 'desktop_shell.dart';

/// ShellRoute wrapper for authenticated routes. Renders `DesktopShell`
/// (sidebar on wide, drawer on mobile) around the active child route.
///
/// Keeping this as a thin pass-through means tests and previews can target
/// DesktopShell directly, while the router only cares about ShellRoute's
/// expected `(context, state, child)` builder shape.
class AuthShell extends StatelessWidget {
  final Widget child;

  const AuthShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(body: child);
  }
}
