import 'package:nmail_core/utils/inline_image_source.dart';

/// Quoted values are consumed whole, so a `>` written inside one does not end
/// the tag early and hide the src that follows it.
final _imgTag = RegExp(
  r'''<img\b(?:"[^"]*"|'[^']*'|[^"'>])*>''',
  caseSensitive: false,
);

final _srcAttribute = RegExp(
  r'''\ssrc\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))''',
  caseSensitive: false,
);

final _backgroundUrl = RegExp(
  r'''background(?:-image)?\s*:[^;"']*url\(\s*['"]?([^)'"]*)''',
  caseSensitive: false,
);

String? _srcOf(String imgTag) {
  final match = _srcAttribute.firstMatch(imgTag);
  if (match == null) return null;
  return match.group(1) ?? match.group(2) ?? match.group(3);
}

/// Whether the source carries an image the app would have to fetch over the
/// network.
///
/// Images the message brings along, `cid:` parts and data URIs, do not count:
/// reading them sends no request, so there is nothing to withhold.
bool htmlHasRemoteImages(String html) {
  for (final tag in _imgTag.allMatches(html)) {
    final src = _srcOf(tag.group(0)!)?.trim();
    if (src != null && src.isNotEmpty && !isEmbeddedImageUrl(src)) return true;
  }
  for (final background in _backgroundUrl.allMatches(html)) {
    if (!isEmbeddedImageUrl(background.group(1))) return true;
  }
  return false;
}

/// The Content-IDs the source references with `<img src="cid:...">`.
Set<String> htmlInlineImageCids(String html) {
  final cids = <String>{};
  for (final tag in _imgTag.allMatches(html)) {
    final cid = contentIdFromUrl(_srcOf(tag.group(0)!));
    if (cid != null) cids.add(cid);
  }
  return cids;
}
