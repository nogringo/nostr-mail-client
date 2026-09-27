import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nmail_core/models/compose_attachment.dart';
import 'package:nmail_core/utils/inline_image_source.dart';

/// Renders image embeds: `cid:` URLs from [inlineImages], anything else from
/// the network (an image pasted as HTML from a web page).
class InlineImageEmbedBuilder extends EmbedBuilder {
  const InlineImageEmbedBuilder(this.inlineImages);

  final Map<String, ComposeAttachment> inlineImages;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final url = embedContext.node.value.data as String;
    final contentId = contentIdFromUrl(url);
    final brokenImage = Icon(
      Icons.broken_image_outlined,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final Widget image;
    if (contentId == null) {
      image = Image.network(url, errorBuilder: (_, _, _) => brokenImage);
    } else {
      final bytes = inlineImages[contentId]?.data;
      image = bytes == null ? brokenImage : Image.memory(bytes);
    }
    return Align(alignment: AlignmentDirectional.centerStart, child: image);
  }
}
