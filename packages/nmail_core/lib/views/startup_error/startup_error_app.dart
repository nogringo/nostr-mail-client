import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';

import 'package:nmail_core/app/widgets/window_caption_bar.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'startup_error_view.dart';

/// Stands in for `MainApp` when the bootstrap throws: no service, theme or
/// router exists at that point, so this builds the little it needs itself.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    // Not the system accent: reading it runs a plugin, and a plugin is exactly
    // the kind of thing that may have just failed.
    const seed = Colors.blue;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nmail',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales.toList()
        ..remove(const Locale('en'))
        ..insert(0, const Locale('en')),
      home: StartupErrorView(error: error, stackTrace: stackTrace),
      builder: (context, child) {
        if (!PlatformHelper.isDesktop) return child!;
        final window = ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const WindowCaptionBar(),
              Expanded(child: child!),
            ],
          ),
        );

        if (PlatformHelper.isMacOS) return window;
        return DragToResizeArea(child: window);
      },
    );
  }
}
