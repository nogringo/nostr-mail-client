import 'package:mime/mime.dart';

/// Format blossom server URL for display by removing protocols and trailing slashes
String formatBlossomUrl(String url) {
  return url
      .replaceFirst('https://', '')
      .replaceFirst('http://', '')
      .replaceFirst(RegExp(r'/$'), '');
}

/// Normalize blossom server URL by prepending https:// if no protocol is present
String normalizeBlossomUrl(String url) {
  if (url.isEmpty) return url;
  if (url.startsWith('https://') || url.startsWith('http://')) return url;
  if (url.contains('://')) {
    return url; // Already has some protocol, don't prepend https://
  }
  return 'https://$url';
}

/// Validate if the URL is a valid Blossom server URL (http:// or https://)
bool isValidBlossomUrl(String url) {
  if (url.isEmpty || url.contains(' ')) return false;
  if (!url.startsWith('https://') && !url.startsWith('http://')) {
    return false;
  }

  // Basic check for multiple protocol separators
  if ('://'.allMatches(url).length > 1) return false;

  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return false;

  // Blossom servers must have a valid host
  if (!uri.host.contains('.') && uri.host != 'localhost') return false;

  return true;
}

/// URL of a blob on a Blossom server, as BUD-01 serves it (`/<sha256>.<ext>`)
String blossomBlobUrl(String server, String sha256, String mimeType) {
  final base = server.replaceFirst(RegExp(r'/$'), '');
  final extension = extensionFromMime(mimeType);
  return extension == null ? '$base/$sha256' : '$base/$sha256.$extension';
}
