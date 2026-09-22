import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nmail_core/utils/inline_image_source.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/views/email/widgets/inline_image_view.dart';

/// Renders the images an email carries in its own MIME parts.
///
/// A `cid:` URL names a part of the message being read, not something anything
/// could fetch, so the factory resolves it instead of letting it reach
/// [NetworkImage].
class EmailWidgetFactory extends WidgetFactory {
  @override
  Widget? buildImageWidget(BuildTree tree, ImageSource src) {
    final contentId = contentIdFromUrl(src.url);
    if (contentId == null) return super.buildImageWidget(tree, src);

    final controller = EmailController.to;
    final bytes = controller.inlineImageBytes(contentId);
    final image = src.image;
    return InlineImageView(
      bytes: bytes,
      initial: controller.resolvedInlineImage(contentId),
      alt: image?.alt ?? image?.title,
    );
  }

  @override
  DecorationImage? buildDecorationImage(
    BuildTree tree,
    String? url, {
    AlignmentGeometry alignment = Alignment.topLeft,
    BoxFit fit = BoxFit.scaleDown,
    ImageRepeat repeat = ImageRepeat.noRepeat,
  }) {
    // A background takes an ImageProvider up front, which inline bytes cannot
    // supply. Dropping it beats a NetworkImage that throws on every layout.
    if (contentIdFromUrl(url) != null) return null;

    return super.buildDecorationImage(
      tree,
      url,
      alignment: alignment,
      fit: fit,
      repeat: repeat,
    );
  }
}
