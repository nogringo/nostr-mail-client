import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class NostrAppsMarqueeController {
  NostrAppsMarqueeController({
    required this.copies,
    required TickerProvider vsync,
  }) {
    _ticker = vsync.createTicker(_onTick)..start();
  }

  static const _pixelsPerSecond = 30.0;

  final int copies;
  final scrollController = ScrollController();
  late final Ticker _ticker;

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

  void dispose() {
    _ticker.dispose();
    scrollController.dispose();
  }
}
