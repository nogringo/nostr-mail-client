import 'dart:typed_data';

import 'package:flutter/material.dart';

/// An image the message carries itself, reached through a `cid:` reference.
class InlineImageView extends StatelessWidget {
  final Future<Uint8List?> bytes;

  /// Bytes already resolved for this image, which skip the empty first frame.
  final Uint8List? initial;

  final String? alt;

  const InlineImageView({
    super.key,
    required this.bytes,
    this.initial,
    this.alt,
  });

  @override
  Widget build(BuildContext context) {
    final alt = this.alt;
    final fallback = alt == null || alt.isEmpty
        ? const SizedBox.shrink()
        : Text(alt);

    return FutureBuilder<Uint8List?>(
      future: bytes,
      initialData: initial,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return snapshot.connectionState == ConnectionState.waiting
              ? const SizedBox.shrink()
              : fallback;
        }
        return Image.memory(
          data,
          // As in WidgetFactory.buildImageWidget: the width and height fwfh
          // derives from the img attributes arrive as tight constraints.
          fit: BoxFit.fill,
          semanticLabel: alt,
          excludeFromSemantics: alt == null,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      },
    );
  }
}
