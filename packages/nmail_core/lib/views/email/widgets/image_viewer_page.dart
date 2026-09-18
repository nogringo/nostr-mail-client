import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/views/shared/window_caption_inset.dart';
import 'image_viewer_image.dart';

Future<void> showImageViewerPage(
  BuildContext context, {
  required String filename,
  required Future<Uint8List?> imageData,
  required VoidCallback onDownload,
  required ValueChanged<Uint8List> onCopy,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ImageViewerPage(
        filename: filename,
        imageData: imageData,
        onDownload: onDownload,
        onCopy: onCopy,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({
    super.key,
    required this.filename,
    required this.imageData,
    required this.onDownload,
    required this.onCopy,
  });

  final String filename;
  final Future<Uint8List?> imageData;
  final VoidCallback onDownload;
  final ValueChanged<Uint8List> onCopy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: Theme(
          data: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
              brightness: Brightness.dark,
            ),
          ),
          child: WindowCaptionInset(
            child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: const CloseButton(),
                title: Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actionsPadding: .only(right: 8),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: onDownload,
                    tooltip: l.emailDownload,
                  ),
                ],
              ),
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: FutureBuilder<Uint8List?>(
                  future: imageData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data;
                    if (data == null) {
                      return Center(child: Text(l.emailImageLoadFailed));
                    }
                    return ImageViewerImage(
                      imageData: data,
                      onCopy: () => onCopy(data),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
