import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

class PendingRequestsOverlay extends StatelessWidget {
  const PendingRequestsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomViewPadding = MediaQuery.of(context).viewPadding.bottom;

    return NPendingRequests(
      ndkFlutter: Get.find(),
      bottomMargin: 16 + bottomViewPadding,
    );
  }
}
