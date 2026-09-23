import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/scheduled_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import '../inbox/widgets/app_drawer.dart';
import '../shared/app_bar_account_avatar.dart';
import '../shared/layout_constants.dart';
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
                bottom: BorderSide(color: colorScheme.outlineVariant),
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
        // AppBar only centers a leading that is itself an IconButton, so these
        // wrapped ones need their own Center or they fill the 56px slot.
        leading: Obx(() {
          if (controller.hasSelection) {
            return Center(
              child: IconButton(
                icon: const Icon(Icons.close),
                tooltip: l.inboxClearSelection,
                onPressed: controller.clearSelection,
              ),
            );
          }
          return Builder(
            builder: (context) => Center(
              child: IconButton(
                icon: const Icon(Icons.menu),
                tooltip: l.inboxMenu,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
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
        actionsPadding: .only(right: 8),
        actions: [
          Obx(
            () => controller.hasSelection
                ? const ScheduledSelectionActionsBar()
                : const AppBarAccountAvatar(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.compose),
        tooltip: l.inboxCompose,
        child: const Icon(Icons.edit),
      ),
      body: const ScheduledList(bottomPadding: LayoutConstants.fabClearance),
    );
  }
}
