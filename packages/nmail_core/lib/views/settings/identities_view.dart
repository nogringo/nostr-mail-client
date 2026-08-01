import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/identities_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/identities_empty_state.dart';
import 'widgets/identities_list.dart';

class IdentitiesView extends StatelessWidget {
  const IdentitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<IdentitiesController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.identitiesTitle),
        actionsPadding: .only(right: 8),
        actions: [
          Obx(() {
            final canSave = controller.hasChanges && !controller.isSaving.value;
            return FilledButton(
              onPressed: canSave ? controller.saveChanges : null,
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.actionSave),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.settingsIdentitiesNew);
          await controller.loadData();
        },
        tooltip: l.identitiesCreate,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              SizedBox(
                height: 4,
                child: controller.isRefreshing.value
                    ? const LinearProgressIndicator()
                    : null,
              ),
              Expanded(
                child: ResponsiveCenter(
                  maxWidth: 600,
                  child: controller.identities.isEmpty
                      ? const IdentitiesEmptyState()
                      : const IdentitiesList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
