import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/identities_controller.dart';
import 'identity_tile.dart';

class IdentitiesList extends StatelessWidget {
  const IdentitiesList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IdentitiesController>();
    return Obx(() {
      return ReorderableListView.builder(
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: controller.identities.length,
        onReorderItem: controller.reorder,
        itemBuilder: (context, index) {
          final identity = controller.identities[index];
          return IdentityTile(
            key: ObjectKey(identity),
            identity: identity,
            index: index,
          );
        },
      );
    });
  }
}
