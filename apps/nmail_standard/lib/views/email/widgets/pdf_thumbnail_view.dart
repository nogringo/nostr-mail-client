import 'package:flutter/material.dart';

class PdfThumbnailView extends StatelessWidget {
  const PdfThumbnailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.picture_as_pdf,
          size: 20,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
