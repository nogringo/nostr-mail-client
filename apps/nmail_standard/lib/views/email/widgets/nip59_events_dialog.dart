import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Shows a responsive NIP-59 events dialog.
/// - Mobile (<600px): Bottom sheet with slide-up animation
/// - Desktop: Centered dialog with fade animation
Future<void> showNip59EventsDialog({
  required BuildContext context,
  required Nip01Event? giftWrap,
  required Nip01Event? seal,
  required Nip01Event? rumor,
}) async {
  final l = AppLocalizations.of(context);
  final isMobile = MediaQuery.of(context).size.width < 600;

  if (isMobile) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _Nip59EventsContent(
          giftWrap: giftWrap,
          seal: seal,
          rumor: rumor,
        );
      },
    );
  } else {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l.emailNip59Dismiss,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _Nip59EventsContent(
          giftWrap: giftWrap,
          seal: seal,
          rumor: rumor,
          isDesktop: true,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }
}

class _Nip59EventsContent extends StatelessWidget {
  final Nip01Event? giftWrap;
  final Nip01Event? seal;
  final Nip01Event? rumor;
  final bool isDesktop;

  const _Nip59EventsContent({
    this.giftWrap,
    this.seal,
    this.rumor,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktop(context);
    }
    return _buildBottomSheet(context);
  }

  Widget _buildBottomSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  EventCard(
                    event: giftWrap,
                    kind: 1059,
                    label: l.emailNip59GiftWrap,
                  ),
                  const SizedBox(height: 12),
                  EventCard(event: seal, kind: 13, label: l.emailNip59Seal),
                  const SizedBox(height: 12),
                  EventCard(event: rumor, kind: 1301, label: l.emailNip59Rumor),
                  // const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    EventCard(
                      event: giftWrap,
                      kind: 1059,
                      label: l.emailNip59GiftWrap,
                    ),
                    const SizedBox(height: 16),
                    EventCard(event: seal, kind: 13, label: l.emailNip59Seal),
                    const SizedBox(height: 16),
                    EventCard(
                      event: rumor,
                      kind: 1301,
                      label: l.emailNip59Rumor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
      child: Row(
        children: [
          Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            l.emailNip59Title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          const CloseButton(),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Nip01Event? event;
  final int kind;
  final String label;

  EventCard({super.key, this.event, required this.kind, required this.label});

  final RxBool _copied = false.obs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildHeaderRow(context),
          if (event != null) ...[
            const Divider(height: 1),
            HighlightView(
              const JsonEncoder.withIndent(
                '  ',
              ).convert(Nip01EventModel.fromEntity(event!).toJson()),
              language: 'json',
              theme: isDark ? a11yDarkTheme : a11yLightTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => TextButton.icon(
                    onPressed: _copyJson,
                    icon: Icon(
                      _copied.value ? Icons.check : Icons.copy,
                      key: ValueKey(_copied.value),
                    ),
                    label: Text(l.emailNip59CopyJson),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(
        children: [
          Chip(
            label: Text(
              l.emailNip59Kind(kind),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          if (event == null) ...[
            const Spacer(),
            Text(
              l.emailNip59NotAvailable,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _copyJson() {
    if (event == null) return;

    final json = const JsonEncoder.withIndent(
      '  ',
    ).convert(Nip01EventModel.fromEntity(event!).toJson());

    Clipboard.setData(ClipboardData(text: json));
    _copied.value = true;
    Future.delayed(const Duration(seconds: 2), () => _copied.value = false);
  }
}
