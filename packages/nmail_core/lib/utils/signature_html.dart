import 'package:flutter_quill/flutter_quill.dart' show Document;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:nostr_mail/nostr_mail.dart' show htmlToText;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

final _imgSrc = RegExp(
  r'''<img\b[^>]*?\bsrc\s*=\s*(["'])([^"']*)\1''',
  caseSensitive: false,
);
final _imgTag = RegExp(r'<img\b[^>]*>', caseSensitive: false);
final _blankLines = RegExp(r'\n\s*\n+');
final _imageKey = RegExp(r'^[0-9a-f]{64}$');

/// Whether [src] names an image of `signature_images`, the SHA-256 hex of its
/// encrypted blob.
bool isSignatureImageKey(String src) => _imageKey.hasMatch(src);

Set<String> signatureImageSources(String html) => {
  for (final match in _imgSrc.allMatches(html)) match[2]!,
};

String signatureHtmlWithoutImages(String html) => html.replaceAll(_imgTag, '');

/// The text of [html] on one line per paragraph, for a list preview.
String signaturePreview(String html) =>
    htmlToText(html).trim().replaceAll(_blankLines, '\n');

/// Always ends with a newline, as a Quill document does.
Delta signatureDeltaFromHtml(String html) {
  final delta = HtmlToDelta().convert(html);
  final last = delta.isEmpty ? null : delta.last.data;
  if (last is! String || !last.endsWith('\n')) delta.insert('\n');
  return delta;
}

/// [keepImage] lets through image sources the converter would otherwise mark
/// unsafe, as it does with anything that is not a URL.
String signatureHtmlFromDelta(
  Delta delta, {
  bool Function(String src) keepImage = isSignatureImageKey,
}) {
  final options = ConverterOptions.forEmail();
  options.sanitizerOptions.urlSanitizer = (url) => keepImage(url) ? url : null;
  return QuillDeltaToHtmlConverter(
    delta.toJson().cast<Map<String, dynamic>>(),
    options,
  ).convert();
}

String signatureHtmlFromText(String text) => signatureHtmlFromDelta(
  Delta()..insert(text.endsWith('\n') ? text : '$text\n'),
);

int deltaTextLength(Delta delta) =>
    delta.toList().fold(0, (length, op) => length + op.length!);

/// Whether [document] still ends with the signature [block] as inserted.
bool endsWithSignature(Delta document, Delta block) {
  final length = deltaTextLength(document);
  final blockLength = deltaTextLength(block);
  return length >= blockLength && document.slice(length - blockLength) == block;
}

/// [document] with its trailing signature [block] swapped for [signature],
/// which goes after a blank line. [block] of the result is that blank line
/// and [signature], as the document holds them.
({Document document, Delta? block}) replaceSignature(
  Delta document, {
  Delta? block,
  Delta? signature,
}) {
  final body = block == null
      ? document
      : document.slice(0, deltaTextLength(document) - deltaTextLength(block));
  if (signature == null) {
    return (document: Document.fromDelta(body), block: null);
  }
  final added = (Delta()..insert('\n')).concat(signature);
  final result = Document.fromDelta(body.concat(added));
  final delta = result.toDelta();
  return (
    document: result,
    block: delta.slice(deltaTextLength(delta) - deltaTextLength(added)),
  );
}
