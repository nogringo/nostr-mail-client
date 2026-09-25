import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class NostrAppsMarqueeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  NostrAppsMarqueeController({required this.copies});

  static const _pixelsPerSecond = 30.0;

  final int copies;
  final scrollController = ScrollController();
  late final Ticker _ticker;

  @override
  void onInit() {
    super.onInit();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final cycleWidth =
        (position.maxScrollExtent + position.viewportDimension) / copies;
    if (cycleWidth <= 0) return;
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final offset = (seconds * _pixelsPerSecond) % cycleWidth;
    scrollController.jumpTo(offset.clamp(0.0, position.maxScrollExtent));
  }

  @override
  void onClose() {
    _ticker.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
