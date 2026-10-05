import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/identities_controller.dart';
import '../../shared/layout_constants.dart';
import 'identity_tile.dart';

class IdentitiesList extends StatelessWidget {
  const IdentitiesList({super.key, required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<IdentitiesController>();
    // Centered by padding, not a width constraint, to keep the scrollbar at the
    // screen edge: reordering needs the list to own its scroll.
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = max(0.0, (constraints.maxWidth - maxWidth) / 2);
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: EdgeInsets.fromLTRB(
                gutter,
                0,
                gutter,
                LayoutConstants.fabClearance(context),
              ),
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
          },
        );
      },
    );
  }
}
