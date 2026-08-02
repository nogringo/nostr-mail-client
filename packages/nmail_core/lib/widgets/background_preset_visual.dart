import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nmail_core/models/background_preset.dart';

class BackgroundPresetVisual extends StatefulWidget {
  const BackgroundPresetVisual({
    super.key,
    required this.variant,
    this.animate = true,
  });

  final BackgroundPresetVariant variant;
  final bool animate;

  @override
  State<BackgroundPresetVisual> createState() => _BackgroundPresetVisualState();
}

class _BackgroundPresetVisualState extends State<BackgroundPresetVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _canAnimate({required bool disableAnimations}) =>
      widget.animate &&
      !disableAnimations &&
      widget.variant.assetPath == null &&
      (widget.variant.id == 'paper_light' ||
          widget.variant.id == 'midnight_inbox');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
  }

  @override
  void didUpdateWidget(covariant BackgroundPresetVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant.id != widget.variant.id ||
        oldWidget.animate != widget.animate) {
      _stopAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation({required bool shouldAnimate}) {
    if (shouldAnimate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _stopAnimation();
    }
  }

  void _stopAnimation() {
    _controller
      ..stop()
      ..value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = widget.variant.assetPath;
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        package: BackgroundPreset.packageName,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final shouldAnimate = _canAnimate(
      disableAnimations: MediaQuery.of(context).disableAnimations,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAnimation(shouldAnimate: shouldAnimate);
    });

    if (shouldAnimate) {
      return Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _BackgroundPresetPainter(
                widget.variant,
                layer: _BackgroundPaintLayer.base,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _BackgroundPresetPainter(
                  widget.variant,
                  progress: _controller.value,
                  layer: _BackgroundPaintLayer.waves,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      );
    }

    return CustomPaint(
      painter: _BackgroundPresetPainter(widget.variant),
      child: const SizedBox.expand(),
    );
  }
}

enum _BackgroundPaintLayer { all, base, waves }

class _BackgroundPresetPainter extends CustomPainter {
  const _BackgroundPresetPainter(
    this.variant, {
    this.progress = 0,
    this.layer = _BackgroundPaintLayer.all,
  });

  final BackgroundPresetVariant variant;
  final double progress;
  final _BackgroundPaintLayer layer;

  @override
  void paint(Canvas canvas, Size size) {
    switch (variant.id) {
      case 'paper_light':
        _paintPaperLight(canvas, size);
      case 'midnight_inbox':
        _paintMidnightInbox(canvas, size);
      case 'dawn_sync':
        _paintDawnSync(canvas, size);
      case 'relay_map':
      default:
        _paintRelayMap(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPresetPainter oldDelegate) {
    return oldDelegate.variant.id != variant.id ||
        oldDelegate.layer != layer ||
        (layer != _BackgroundPaintLayer.base &&
            oldDelegate.progress != progress);
  }

  void _paintRelayMap(Canvas canvas, Size size) {
    if (layer == _BackgroundPaintLayer.waves) return;

    final rect = Offset.zero & size;
    _fillLinear(
      canvas,
      rect,
      const [Color(0xFFFFF6EE), Color(0xFFF4C2AA), Color(0xFFAEDDD3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    _softCircle(
      canvas,
      size,
      const Offset(.18, .16),
      .42,
      const Color(0xFFFFD36E),
      .32,
    );
    _softCircle(
      canvas,
      size,
      const Offset(.78, .82),
      .48,
      const Color(0xFF4FB7A5),
      .34,
    );
    _softCircle(
      canvas,
      size,
      const Offset(.08, .72),
      .36,
      const Color(0xFFE56F86),
      .18,
    );
  }

  void _paintPaperLight(Canvas canvas, Size size) {
    if (layer != _BackgroundPaintLayer.waves) {
      final rect = Offset.zero & size;
      _fillLinear(
        canvas,
        rect,
        const [Color(0xFFFCFAF5), Color(0xFFF0E8DD), Color(0xFFD9E5E3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
      );
      _softCircle(
        canvas,
        size,
        const Offset(.12, .2),
        .36,
        const Color(0xFFE7AA93),
        .2,
      );
      _softCircle(
        canvas,
        size,
        const Offset(.86, .68),
        .42,
        const Color(0xFFA9C1BC),
        .3,
      );
    }

    if (layer == _BackgroundPaintLayer.base) return;

    _drawWaves(
      canvas,
      size,
      const Color(0xFF9A806F).withValues(alpha: .11),
      progress: progress,
      count: 8,
      baseYFactor: -.05,
      spacingFactor: .115,
      amplitudeFactor: .018,
      slopeFactor: .18,
    );
  }

  void _paintMidnightInbox(Canvas canvas, Size size) {
    if (layer != _BackgroundPaintLayer.waves) {
      final rect = Offset.zero & size;
      _fillLinear(
        canvas,
        rect,
        const [Color(0xFF131719), Color(0xFF1C2523), Color(0xFF3E4B41)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      _softCircle(
        canvas,
        size,
        const Offset(.25, .32),
        .48,
        const Color(0xFF5F4B6D),
        .18,
      );
      _softCircle(
        canvas,
        size,
        const Offset(.78, .52),
        .5,
        const Color(0xFF1E7A6B),
        .2,
      );
    }

    if (layer == _BackgroundPaintLayer.base) return;

    _drawWaves(
      canvas,
      size,
      const Color(0xFFA7B8A6).withValues(alpha: .12),
      progress: progress,
      count: 6,
      baseYFactor: .18,
      spacingFactor: .12,
      amplitudeFactor: .035,
      slopeFactor: -.02,
    );
  }

  void _paintDawnSync(Canvas canvas, Size size) {
    if (layer == _BackgroundPaintLayer.waves) return;

    final rect = Offset.zero & size;
    _fillLinear(
      canvas,
      rect,
      const [Color(0xFF0E1718), Color(0xFF1D3434), Color(0xFF284A43)],
      begin: Alignment.topRight,
      end: Alignment.bottomRight,
    );
    _softCircle(
      canvas,
      size,
      const Offset(.16, .86),
      .48,
      const Color(0xFF2A8A78),
      .26,
    );
    _softCircle(
      canvas,
      size,
      const Offset(.84, .22),
      .42,
      const Color(0xFF7D6A44),
      .2,
    );
    _softCircle(
      canvas,
      size,
      const Offset(.5, .45),
      .5,
      const Color(0xFF344B6C),
      .16,
    );
  }

  void _fillLinear(
    Canvas canvas,
    Rect rect,
    List<Color> colors, {
    required Alignment begin,
    required Alignment end,
  }) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _softCircle(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Color color,
    double alpha,
  ) {
    final rect = Offset.zero & size;
    final resolvedCenter = Offset(
      size.width * center.dx,
      size.height * center.dy,
    );
    final resolvedRadius = size.longestSide * radius;
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: resolvedCenter, radius: resolvedRadius),
          );
    canvas.drawRect(rect, paint);
  }

  void _drawWaves(
    Canvas canvas,
    Size size,
    Color color, {
    required double progress,
    required int count,
    required double baseYFactor,
    required double spacingFactor,
    required double amplitudeFactor,
    required double slopeFactor,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = math.max(size.shortestSide * .003, 1)
      ..style = PaintingStyle.stroke;

    final phase = progress * math.pi * 2;
    final startX = -size.width * .08;
    final endX = size.width * 1.08;
    final span = endX - startX;

    for (var i = 0; i < count; i++) {
      final path = Path();
      for (var step = 0; step <= 48; step++) {
        final t = step / 48;
        final x = startX + span * t;
        final wave =
            math.sin((t * math.pi * 2.2) + phase + i * .58) *
            size.height *
            amplitudeFactor;
        final drift = math.sin(phase + i * .74) * size.height * .012;
        final y =
            size.height * (baseYFactor + i * spacingFactor) +
            size.height * slopeFactor * t +
            wave +
            drift;

        if (step == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }
}
