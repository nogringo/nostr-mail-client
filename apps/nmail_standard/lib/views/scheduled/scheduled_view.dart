import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scheduled_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import '../inbox/widgets/app_drawer.dart';
import 'widgets/scheduled_list.dart';
import 'widgets/scheduled_selection_actions_bar.dart';

class ScheduledView extends GetView<ScheduledController> {
  const ScheduledView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (ResponsiveHelper.isNotMobile(context)) {
      return Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.only(left: 16, right: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Obx(() {
              if (controller.hasSelection) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: l.inboxClearSelection,
                      onPressed: controller.clearSelection,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.inboxSelectedCount(controller.selectedIds.length),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    const ScheduledSelectionActionsBar(),
                  ],
                );
              }
              return Row(
                children: [
                  Text(
                    l.folderScheduled,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: controller.isSyncing.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    tooltip: l.inboxSync,
                    onPressed: controller.isSyncing.value
                        ? null
                        : controller.resync,
                  ),
                ],
              );
            }),
          ),
          const Expanded(child: ScheduledList()),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: Obx(() {
          if (controller.hasSelection) {
            return IconButton(
              icon: const Icon(Icons.close),
              tooltip: l.inboxClearSelection,
              onPressed: controller.clearSelection,
            );
          }
          return Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: l.inboxMenu,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          );
        }),
        title: Obx(
          () => Text(
            controller.hasSelection
                ? '${controller.selectedIds.length}'
                : l.folderScheduled,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 8),
        actions: [
          Obx(
            () => controller.hasSelection
                ? const ScheduledSelectionActionsBar()
                : const SizedBox.shrink(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const ScheduledList(),
    );
  }
}
