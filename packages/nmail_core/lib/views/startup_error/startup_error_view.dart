import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/redact_home_paths.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/startup_error_copy_button.dart';
import 'widgets/startup_error_report_button.dart';

class StartupErrorView extends StatelessWidget {
  const StartupErrorView({super.key, required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  /// What the screen shows, copies and files as an issue. Redacted here rather
  /// than at the report button, so the box holds exactly what leaves the app.
  String get _details => redactHomePaths(
    stackTrace == null ? '$error' : '$error\n\n$stackTrace',
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 560,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.startupErrorTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(l.startupErrorBody, style: bodyStyle),
                  if (kIsWeb) ...[
                    const SizedBox(height: 8),
                    Text(l.startupErrorWebHint, style: bodyStyle),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    l.startupErrorDetails,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: SelectableText(
                              _details,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            children: [
                              StartupErrorCopyButton(details: _details),
                              StartupErrorReportButton(details: _details),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
