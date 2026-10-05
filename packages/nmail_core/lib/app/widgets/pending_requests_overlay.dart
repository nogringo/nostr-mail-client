import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

class PendingRequestsOverlay extends StatelessWidget {
  const PendingRequestsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomViewPadding = MediaQuery.of(context).viewPadding.bottom;

    return NPendingRequests(
      ndkFlutter: GetIt.I<NdkFlutter>(),
      bottomMargin: 16 + bottomViewPadding,
    );
  }
}
