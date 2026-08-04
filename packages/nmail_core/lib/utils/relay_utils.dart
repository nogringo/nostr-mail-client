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

/// Whether the relay is reachable without an internet connection: one running
/// on the device itself (Citrine, a Docker container) or elsewhere on the LAN.
///
/// The OS reporting "no network" says nothing about these. Loopback survives
/// airplane mode entirely, and a LAN relay survives the router losing its
/// uplink, so they must never be written off as unreachable.
bool isLocalRelayUrl(String url) {
  final host = Uri.tryParse(url)?.host.toLowerCase();
  if (host == null || host.isEmpty) return false;

  if (host == 'localhost' || host.endsWith('.localhost')) return true;
  if (host.endsWith('.local')) return true;

  // Uri.host strips the brackets off an IPv6 literal.
  if (host.contains(':')) {
    return host == '::1' ||
        host.startsWith('fe80:') ||
        host.startsWith('fc') ||
        host.startsWith('fd');
  }

  final octets = host.split('.').map(int.tryParse).toList();
  if (octets.length == 4 && octets.every((o) => o != null && o >= 0 && o <= 255)) {
    final first = octets[0]!;
    final second = octets[1]!;
    if (first == 127 || first == 10) return true;
    if (first == 192 && second == 168) return true;
    if (first == 172 && second >= 16 && second <= 31) return true;
    if (first == 169 && second == 254) return true;
    return false;
  }

  // A name with no dot is resolved by the LAN, never by public DNS.
  return !host.contains('.');
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
