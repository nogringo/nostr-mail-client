import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/scheduled_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'scheduled_email_tile.dart';

class ScheduledList extends GetView<ScheduledController> {
  const ScheduledList({super.key});

  Future<void> _cancel(BuildContext context, ScheduledEmail email) async {
    try {
      await controller.cancel(email.packageId);
    } catch (e) {
      if (context.mounted) {
        final l = AppLocalizations.of(context);
        ToastHelper.error(
          context,
          l.scheduledCancelFailed,
          description: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.isLoading.value && controller.scheduled.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.resync,
        child: controller.scheduled.isEmpty
            ? LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.scheduledEmpty,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.scheduled.length,
                itemBuilder: (context, index) {
                  final email = controller.scheduled[index];
                  return Obx(
                    () => ScheduledEmailTile(
                      key: ValueKey(email.packageId),
                      email: email,
                      isSelected: controller.isSelected(email.packageId),
                      selectionMode: controller.hasSelection,
                      onToggleSelect: () =>
                          controller.toggleSelection(email.packageId),
                      onCancel: () => _cancel(context, email),
                      onOpen: () => context.push(
                        AppRoutes.compose,
                        extra: {'scheduledEmail': email},
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}
