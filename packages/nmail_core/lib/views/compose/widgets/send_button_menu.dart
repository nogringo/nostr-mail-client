import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/send_mode.dart';

class SendButtonMenu extends StatelessWidget {
  const SendButtonMenu({super.key, this.isMobile = false});

  final bool isMobile;

  IconData _getModeIcon(SendMode mode) {
    switch (mode) {
      case SendMode.normal:
        return Icons.lock;
      case SendMode.signed:
        return Icons.draw;
      case SendMode.public:
        return Icons.public;
    }
  }

  String _getModeLabel(AppLocalizations l, SendMode mode) {
    switch (mode) {
      case SendMode.normal:
        return l.composeModePrivateDeniable;
      case SendMode.signed:
        return l.composeModePrivateSigned;
      case SendMode.public:
        return l.composeModePublic;
    }
  }

  String _getModeDescription(AppLocalizations l, SendMode mode) {
    switch (mode) {
      case SendMode.normal:
        return l.composeModePrivateDeniableDescription;
      case SendMode.signed:
        return l.composeModePrivateSignedDescription;
      case SendMode.public:
        return l.composeModePublicDescription;
    }
  }

  Future<void> _showModeMenu(BuildContext context, SendMode currentMode) async {
    final l = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<SendMode>(
      showDragHandle: true,
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.composeChooseSendMode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildModeOption(context, l, SendMode.normal),
              _buildModeOption(context, l, SendMode.signed),
              _buildModeOption(context, l, SendMode.public),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      Get.find<ComposeController>().sendMode.value = selected;
      await Get.find<ComposeController>().firstSend();
    }
  }

  Widget _buildModeOption(
    BuildContext context,
    AppLocalizations l,
    SendMode mode,
  ) {
    return ListTile(
      leading: Icon(_getModeIcon(mode)),
      title: Text(_getModeLabel(l, mode)),
      subtitle: Text(_getModeDescription(l, mode)),
      onTap: () => Navigator.of(context).pop(mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<ComposeController>();

    return Obx(() {
      final isSending = controller.isSending.value;
      final sendLabel = controller.scheduledAt.value != null
          ? l.composeScheduleSend
          : l.composeSend;

      Widget button;

      // On mobile, use a custom button with long-press support
      if (isMobile) {
        button = FilledButton(
          onPressed: isSending ? null : () => controller.firstSend(),
          onLongPress: isSending
              ? null
              : () => _showModeMenu(context, SendMode.normal),
          child: isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(sendLabel),
        );
      } else {
        // Desktop: use FilledButton with dropdown
        button = FilledButton(
          onPressed: isSending ? null : () => controller.firstSend(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: !isSending,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(sendLabel),
              ),
              Visibility(
                visible: isSending,
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          ),
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          if (!isMobile) ...[
            const SizedBox(width: 4),
            MenuAnchor(
              alignmentOffset: const Offset(-8, 0),
              style: MenuStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      width: 2,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
              builder: (context, menuController, child) {
                return IconButton(
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  tooltip: l.composeMoreSendOptions,
                  onPressed: () {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                  },
                );
              },
              menuChildren: [
                MenuItemButton(
                  leadingIcon: Icon(_getModeIcon(SendMode.normal)),
                  onPressed: () async {
                    controller.sendMode.value = SendMode.normal;
                    await controller.firstSend();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getModeLabel(l, SendMode.normal)),
                      Text(
                        _getModeDescription(l, SendMode.normal),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                MenuItemButton(
                  leadingIcon: Icon(_getModeIcon(SendMode.signed)),
                  onPressed: () async {
                    controller.sendMode.value = SendMode.signed;
                    await controller.firstSend();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getModeLabel(l, SendMode.signed)),
                      Text(
                        _getModeDescription(l, SendMode.signed),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                MenuItemButton(
                  leadingIcon: Icon(_getModeIcon(SendMode.public)),
                  onPressed: () async {
                    controller.sendMode.value = SendMode.public;
                    await controller.firstSend();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getModeLabel(l, SendMode.public)),
                      Text(
                        _getModeDescription(l, SendMode.public),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}
