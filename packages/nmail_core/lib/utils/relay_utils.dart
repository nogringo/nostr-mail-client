/// Format relay URL for display by removing the wss:// prefix
String formatRelayUrl(String url) {
  return url.replaceFirst('wss://', '').replaceFirst('ws://', '');
}

/// Normalize relay URL by prepending wss:// if no protocol is present
String normalizeRelayUrl(String url) {
  if (url.isEmpty) return url;
  if (url.startsWith('wss://') || url.startsWith('ws://')) return url;
  if (url.contains('://')) {
    return url; // Already has some protocol, don't prepend wss://
  }
  return 'wss://$url';
}

/// Validate if the URL is a valid Nostr relay URL (ws:// or wss://)
bool isValidRelayUrl(String url) {
  if (url.isEmpty || url.contains(' ')) return false;
  if (!url.startsWith('wss://') && !url.startsWith('ws://')) {
    return false;
  }

  // Basic check for multiple protocol separators
  if ('://'.allMatches(url).length > 1) return false;

  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return false;

  // A relay URL should usually just be protocol + host [+ port]
  // We allow paths if they are needed (though rare for nostr relays)
  // but we should ensure the host looks like a real domain or IP
  if (!uri.host.contains('.')) {
    // Check if it's localhost (common for local development)
    if (uri.host != 'localhost') return false;
  }

  return true;
}
