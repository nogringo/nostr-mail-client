bool htmlHasImages(String html) {
  return RegExp(r'<img[\s>/]', caseSensitive: false).hasMatch(html);
}
