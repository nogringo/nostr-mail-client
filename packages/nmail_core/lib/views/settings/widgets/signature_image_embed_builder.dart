import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';

/// Renders the images of a signature: blobs of `signature_images`, and the
/// ones picked since the form opened.
class SignatureImageEmbedBuilder extends EmbedBuilder {
  const SignatureImageEmbedBuilder(this.controller);

  final SignatureFormController controller;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final src = embedContext.node.value.data as String;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FutureBuilder<Uint8List?>(
        future: controller.imageBytes(src),
        initialData: controller.resolvedImage(src),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null) return Image.memory(bytes);
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          return Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
        },
      ),
    );
  }
}
