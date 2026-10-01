import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/utils/sender_groups.dart';
import 'request_sender_tile.dart';

/// Requests, one row per sender rather than per email: a verdict applies to
/// the sender.
class RequestsSenderList extends GetView<InboxController> {
  final double bottomPadding;

  const RequestsSenderList({super.key, this.bottomPadding = 0});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = groupBySender(controller.emails);
      return ListView.separated(
        padding: EdgeInsets.only(bottom: bottomPadding),
        itemCount: groups.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) => RequestSenderTile(
          key: ValueKey(groups[index].senderKey),
          group: groups[index],
        ),
      );
    });
  }
}
