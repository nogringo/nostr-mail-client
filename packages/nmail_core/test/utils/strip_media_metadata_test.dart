import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/media_metadata/exif_orientation.dart';
import 'package:nmail_core/utils/media_metadata/strip_media_metadata.dart';

/// The fixtures carry a GPS position, a capture date, the device model and
/// a description, written with exiftool or ffmpeg. `video.mkv` has CRC-32
/// elements and `video.webm` was streamed, so its sizes are unknown.
Uint8List fixture(String name) =>
    File('test/fixtures/media_metadata/$name').readAsBytesSync();

bool contains(Uint8List bytes, String text) {
  final needle = latin1.encode(text);
  outer:
  for (var i = 0; i + needle.length <= bytes.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (bytes[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}

const secrets = ['iPhone 15 Pro', '2026:09:18', 'secret', '+48.8566'];

void main() {
  group('stripMediaMetadata', () {
    for (final name in [
      'photo.jpg',
      'photo.png',
      'photo.webp',
      'photo.heic',
      'photo.avif',
      'animation.gif',
      'video.mp4',
      'video.mov',
      'video.mkv',
      'video.webm',
    ]) {
      test('removes the metadata of $name', () {
        final original = fixture(name);
        expect(
          secrets.any((secret) => contains(original, secret)),
          isTrue,
          reason: 'the fixture must carry metadata',
        );

        final stripped = stripMediaMetadata(original);

        for (final secret in secrets) {
          expect(contains(stripped, secret), isFalse, reason: secret);
        }
      });
    }

    test('keeps the JPEG orientation and drops the trailer', () {
      final original = fixture('photo.jpg');
      expect(contains(original, 'SAMSUNG'), isTrue);

      final stripped = stripMediaMetadata(original);

      expect(contains(stripped, 'SAMSUNG'), isFalse);
      expect(stripped.sublist(stripped.length - 2), [0xFF, 0xD9]);
      final exif = latin1.decode(stripped).indexOf('Exif\x00\x00');
      expect(exif, isNot(-1));
      expect(readTiffOrientation(Uint8List.sublistView(stripped, exif + 6)), 6);
    });

    test('keeps the GIF looping', () {
      final stripped = stripMediaMetadata(fixture('animation.gif'));

      expect(contains(stripped, 'NETSCAPE2.0'), isTrue);
      expect(stripped.last, 0x3B);
    });

    test('keeps every byte offset of HEIF and video files', () {
      for (final name in [
        'photo.heic',
        'photo.avif',
        'video.mp4',
        'video.mkv',
        'video.webm',
      ]) {
        final original = fixture(name);
        expect(stripMediaMetadata(original).length, original.length);
      }
    });

    test('does not modify the caller bytes', () {
      final original = fixture('video.mp4');
      final copy = Uint8List.fromList(original);

      stripMediaMetadata(original);

      expect(original, copy);
    });

    test('returns other formats unchanged', () {
      final pdf = Uint8List.fromList(latin1.encode('%PDF-1.7 Author: me'));
      expect(identical(stripMediaMetadata(pdf), pdf), isTrue);
    });

    test('returns a truncated file unchanged', () {
      final truncated = Uint8List.sublistView(fixture('photo.jpg'), 0, 40);
      expect(identical(stripMediaMetadata(truncated), truncated), isTrue);
    });
  });
}
