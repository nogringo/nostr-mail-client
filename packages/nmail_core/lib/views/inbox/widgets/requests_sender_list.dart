import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/utils/sender_groups.dart';
import 'request_sender_tile.dart';

/// Requests, one row per sender rather than per email: a verdict applies to
/// the sender.
class RequestsSenderList extends StatelessWidget {
  final double bottomPadding;

  const RequestsSenderList({super.key, this.bottomPadding = 0});

  InboxController get controller => GetIt.I<InboxController>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
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
      },
    );
  }
}
