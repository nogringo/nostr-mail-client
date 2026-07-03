import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
}

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= ResponsiveBreakpoints.mobile &&
        width < ResponsiveBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.tablet;
  }

  static bool isNotMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.mobile;
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? sidebar;
  final double sidebarWidth;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.sidebar,
    this.sidebarWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveHelper.isNotMobile(context);

    if (isWide && sidebar != null) {
      return Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: sidebarWidth,
              child: sidebar!,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
