final _imageMarkup = RegExp(
  '<img[\\s>/]|background(-image)?\\s*:[^;"\']*url\\(',
  caseSensitive: false,
);

bool htmlHasImages(String html) => _imageMarkup.hasMatch(html);
