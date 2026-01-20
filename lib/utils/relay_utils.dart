/// Format relay URL for display by removing the wss:// prefix
String formatRelayUrl(String url) {
  return url.replaceFirst('wss://', '');
}
