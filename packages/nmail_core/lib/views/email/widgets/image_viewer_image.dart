import 'dart:typed_data';

import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/views/shared/show_context_menu.dart';

class ImageViewerImage extends StatelessWidget {
  const ImageViewerImage({
    super.key,
    required this.imageData,
    required this.onCopy,
  });

  final Uint8List imageData;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Center(
        // Swallows taps on the image so only the backdrop closes.
        child: GestureDetector(
          onTap: () {},
          // onSecondaryTap misses macOS trackpad right-clicks here.
          child: Listener(
            onPointerDown: (event) {
              if (event.buttons & kSecondaryMouseButton == 0) return;
              _showMenu(context, event.position);
            },
            child: Image.memory(imageData, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Future<void> _showMenu(BuildContext context, Offset position) {
    final l = AppLocalizations.of(context);
    return showContextMenu(
      context,
      position: position,
      children: (menuContext) => [
        MenuItemButton(
          onPressed: () {
            Navigator.of(menuContext).pop();
            onCopy();
          },
          child: Text(l.emailCopyImage),
        ),
      ],
    );
  }
}
