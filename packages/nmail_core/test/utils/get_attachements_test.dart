import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/get_attachements.dart';

void main() {
  group('Attachment utils', () {
    test('formatFileSize formats bytes, KB, MB and GB', () {
      expect(formatFileSize(512), '512 B');
      expect(formatFileSize(1536), '1.5 KB');
      expect(formatFileSize(2 * 1024 * 1024), '2.0 MB');
      expect(formatFileSize(3 * 1024 * 1024 * 1024), '3.0 GB');
    });

    test(
      'isImageFile detects supported image extensions case-insensitively',
      () {
        expect(isImageFile('photo.JPG'), isTrue);
        expect(isImageFile('avatar.webp'), isTrue);
        expect(isImageFile('document.pdf'), isFalse);
      },
    );

    test('isPdfFile only accepts pdf extensions case-insensitively', () {
      expect(isPdfFile('invoice.PDF'), isTrue);
      expect(isPdfFile('invoice.pdf.backup'), isFalse);
    });

    test('getAttachmentIcon maps common attachment groups', () {
      expect(getAttachmentIcon('image.png'), Icons.image);
      expect(getAttachmentIcon('file.pdf'), Icons.picture_as_pdf);
      expect(getAttachmentIcon('archive.zip'), Icons.folder_zip);
      expect(getAttachmentIcon('source.dart'), Icons.code);
      expect(getAttachmentIcon('unknown.bin'), Icons.attach_file);
    });
  });
}
