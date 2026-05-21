import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/local_queue_controller.dart';
import '../../l10n/generated/app_localizations.dart';

class LocalQueueIndicator extends StatelessWidget {
  const LocalQueueIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LocalQueueController>()) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<LocalQueueController>();
    final l = AppLocalizations.of(context);

    return Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Obx(() {
              final count = controller.totalCount;
              final isVisible = count > 0;
              return IgnorePointer(
                ignoring: !isVisible,
                child: AnimatedSlide(
                  offset: isVisible ? Offset.zero : const Offset(0, 2),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Semantics(
                      button: true,
                      label: l.localQueueIndicatorLabel(count),
                      child: FloatingActionButton.extended(
                        heroTag: 'localQueueFab',
                        onPressed: () => Get.toNamed(AppRoutes.localQueue),
                        icon: const Icon(Icons.cloud_sync_outlined),
                        label: Text(count.toString()),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
