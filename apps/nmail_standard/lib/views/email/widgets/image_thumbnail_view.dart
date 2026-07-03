import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class ImageThumbnailView extends StatelessWidget {
  final AttachmentRef ref;
  final Email email;

  const ImageThumbnailView({super.key, required this.ref, required this.email});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: Get.find<NostrMailService>().client.getAttachmentBytes(
        email,
        ref,
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (data == null) {
          return Icon(
            Icons.broken_image,
            size: 24,
            color: Theme.of(context).colorScheme.error,
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            data,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                size: 24,
                color: Theme.of(context).colorScheme.error,
              );
            },
          ),
        );
      },
    );
  }
}
