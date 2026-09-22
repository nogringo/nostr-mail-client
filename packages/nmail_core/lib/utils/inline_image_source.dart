import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:enough_mail_plus/enough_mail.dart';
import 'package:nostr_mail/nostr_mail.dart';

const _cidScheme = 'cid:';

/// Whether [url] carries its image with the message rather than pointing at
/// something the app would have to fetch.
bool isEmbeddedImageUrl(String? url) {
  final trimmed = url?.trimLeft().toLowerCase();
  if (trimmed == null) return false;
  return trimmed.startsWith(_cidScheme) || trimmed.startsWith('data:');
}

/// The Content-ID a `cid:` URL names, or null when [url] is anything else.
String? contentIdFromUrl(String? url) {
  final trimmed = url?.trim();
  if (trimmed == null) return null;
  if (!trimmed.toLowerCase().startsWith(_cidScheme)) return null;
  return normalizeContentId(trimmed.substring(_cidScheme.length));
}

/// Brings a Content-ID to the form every comparison here uses: no angle
/// brackets, no percent escapes, lower case.
String? normalizeContentId(String? value) {
  if (value == null) return null;

  var result = value.trim();
  try {
    result = Uri.decodeComponent(result).trim();
  } catch (_) {
    // A lone percent sign is not an escape sequence; keep the value as written.
  }

  if (result.length > 1 && result.startsWith('<') && result.endsWith('>')) {
    result = result.substring(1, result.length - 1).trim();
  }
  return result.isEmpty ? null : result.toLowerCase();
}

/// Bytes of the part [mime] carries under [contentId].
///
/// Null when no part matches, and also when the part is there but its payload
/// was extracted out to Blossom, which leaves an empty body behind.
Uint8List? inlineImageFromMime(MimeMessage mime, String contentId) {
  for (final part in mime.allPartsFlat) {
    if (normalizeContentId(part.getHeaderValue('content-id')) != contentId) {
      continue;
    }
    final bytes = part.decodeContentBinary();
    return bytes == null || bytes.isEmpty ? null : bytes;
  }
  return null;
}

/// The extracted attachment holding the part named by [contentId].
AttachmentRef? inlineImageRef(List<AttachmentRef> refs, String contentId) =>
    refs.firstWhereOrNull(
      (ref) => normalizeContentId(ref.contentId) == contentId,
    );
