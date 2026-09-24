import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart' as ast;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:nmail_core/utils/html_image_scan.dart';

const _maxHtmlLength = 2 * 1024 * 1024;
const _maxCssLength = 512 * 1024;
const _maxSelectors = 4000;

/// Properties `flutter_widget_from_html_core` actually implements. Anything
/// else is dropped so a framework stylesheet does not bloat every element.
const _supportedProperties = {
  'color',
  'direction',
  'display',
  'font-family',
  'font-size',
  'font-style',
  'font-weight',
  'height',
  'line-height',
  'max-height',
  'max-lines',
  'max-width',
  'min-height',
  'min-width',
  'text-align',
  'text-overflow',
  'text-shadow',
  'vertical-align',
  'white-space',
  'width',
};

const _supportedPrefixes = [
  'background',
  'border',
  'margin',
  'padding',
  'text-decoration',
  'text-emphasis',
];

const _backgroundProperties = {'background', 'background-color'};

const _bgcolorTags = {'table', 'thead', 'tbody', 'tfoot', 'tr', 'td', 'th'};

final _bgcolorValue = RegExp(
  r'^(#[0-9a-f]{3,8}|[a-z]+)$',
  caseSensitive: false,
);

final _bodyBgcolor = RegExp(
  '''<body[^>]*\\sbgcolor\\s*=\\s*["']?([^"'\\s>]+)''',
  caseSensitive: false,
);

final _colorDeclaration = RegExp(
  r'(^|;)\s*(background(-color)?|color)\s*:',
  caseSensitive: false,
);

final _widthDeclaration = RegExp(r'(^|;)\s*width\s*:', caseSensitive: false);

final _textAlignDeclaration = RegExp(
  r'(^|;)\s*text-align\s*:',
  caseSensitive: false,
);

final _horizontalMarginDeclaration = RegExp(
  r'(^|;)\s*margin(-left|-right)?\s*:',
  caseSensitive: false,
);

final _cdoPrefix = RegExp(r'^\s*<!--');
final _cdcSuffix = RegExp(r'-->\s*$');
final _importantSuffix = RegExp(r'!\s*important\s*$', caseSensitive: false);
final _onlyPrefix = RegExp(r'^only\s+');
final _urlFunction = RegExp(r'url\s*\([^)]*\)', caseSensitive: false);
final _extraSpace = RegExp(r'\s{2,}');

/// An email body ready for `HtmlWidget`.
class EmailHtml {
  final String html;

  /// Whether the email sets its own text or background colors, which means it
  /// expects to be read on a light surface.
  final bool declaresColors;

  /// Whether the source carried an image the app has to fetch over the
  /// network, read before blocked CSS backgrounds were dropped so the reader
  /// can still offer to load them.
  final bool hasRemoteImages;

  /// The Content-IDs the body references with `<img src="cid:...">`, which the
  /// message carries itself.
  final Set<String> inlineImageCids;

  /// Whether the email carries its own page background, which makes it
  /// readable on any theme and means it needs no surface of ours.
  final bool paintsOwnBackground;

  const EmailHtml({
    required this.html,
    required this.declaresColors,
    required this.hasRemoteImages,
    required this.inlineImageCids,
    this.paintsOwnBackground = false,
  });
}

/// Resolves `<style>` blocks into inline `style` attributes.
///
/// `HtmlWidget` only reads the `style` attribute and discards `<style>`
/// elements, so the cascade has to be applied before it sees the markup.
EmailHtml prepareEmailHtml(String html, {required bool allowRemoteImages}) {
  // Read on the source: blocked CSS backgrounds are gone from the output.
  final hasRemoteImages = htmlHasRemoteImages(html);
  final inlineImageCids = htmlInlineImageCids(html);

  if (html.length > _maxHtmlLength) {
    return EmailHtml(
      html: html,
      declaresColors: false,
      hasRemoteImages: hasRemoteImages,
      inlineImageCids: inlineImageCids,
    );
  }

  try {
    final fragment = html_parser.parseFragment(html);
    final styleElements = fragment.querySelectorAll('style');
    final cssText = _collectCss(styleElements);
    final sheet = cssText.isEmpty || cssText.length > _maxCssLength
        ? null
        : css.parse(cssText, errors: <css.Message>[]);

    final elements = fragment.querySelectorAll('*');
    if (sheet != null) {
      _applyRules(fragment, elements, sheet, allowRemoteImages);
    }
    final bgcolorApplied = _applyBgcolor(elements);
    final tableAlignApplied = _applyTableAlign(elements);
    final tableWidthApplied = _applyTableWidth(elements);
    final declaresColors = _declaresColors(elements);

    // Applied last so the wrapper stays invisible to the selectors above.
    final pageDeclarations = _pageDeclarations(sheet, html, allowRemoteImages);
    if (pageDeclarations.isNotEmpty) {
      _wrapInPageElement(fragment, pageDeclarations);
    }

    final rewritten =
        styleElements.isNotEmpty ||
        pageDeclarations.isNotEmpty ||
        bgcolorApplied ||
        tableAlignApplied ||
        tableWidthApplied;
    return EmailHtml(
      html: rewritten ? fragment.outerHtml : html,
      declaresColors: declaresColors,
      hasRemoteImages: hasRemoteImages,
      inlineImageCids: inlineImageCids,
      paintsOwnBackground: pageDeclarations.any(
        (d) => _backgroundProperties.contains(d.property),
      ),
    );
  } catch (_) {
    return EmailHtml(
      html: html,
      declaresColors: false,
      hasRemoteImages: hasRemoteImages,
      inlineImageCids: inlineImageCids,
    );
  }
}

String _collectCss(List<dom.Element> styleElements) {
  final buffer = StringBuffer();
  for (final element in styleElements) {
    if (_mediaApplies(element.attributes['media'])) {
      buffer.writeln(_stripCdo(element.text));
    }
    element.remove();
  }
  return buffer.toString().trim();
}

/// Keeps a stylesheet only when it applies unconditionally, which leaves a
/// media attribute carrying features skipped like an `@media` block is.
bool _mediaApplies(String? media) {
  if (media == null || media.trim().isEmpty) return true;
  return media.toLowerCase().split(',').any((query) {
    final type = query.trim().replaceFirst(_onlyPrefix, '');
    return type == 'all' || type == 'screen';
  });
}

/// csslib has no production for the `<!-- -->` wrapper email senders still ship.
String _stripCdo(String cssText) =>
    cssText.replaceFirst(_cdoPrefix, '').replaceFirst(_cdcSuffix, '');

void _applyRules(
  dom.DocumentFragment fragment,
  List<dom.Element> elements,
  ast.StyleSheet sheet,
  bool allowRemoteImages,
) {
  final ids = <String>{};
  final classes = <String>{};
  final tags = <String>{};
  for (final element in elements) {
    if (element.id.isNotEmpty) ids.add(element.id);
    classes.addAll(element.classes);
    final localName = element.localName;
    if (localName != null) tags.add(localName);
  }

  final candidates = <dom.Element, List<_Candidate>>{};
  final matchCache = <String, List<dom.Element>>{};
  var sequence = 0;
  var selectorCount = 0;

  rules:
  for (final topLevel in sheet.topLevels) {
    if (topLevel is! ast.RuleSet) continue;
    final group = topLevel.selectorGroup;
    if (group == null) continue;

    final declarations = _declarations(
      topLevel.declarationGroup,
      allowRemoteImages,
    );
    if (declarations.isEmpty) continue;

    for (final selector in group.selectors) {
      if (selectorCount++ >= _maxSelectors) break rules;

      final text = selector.span?.text.trim();
      if (text == null || text.isEmpty) continue;
      if (!_canMatch(selector, ids, classes, tags)) continue;

      final matched = matchCache.putIfAbsent(text, () {
        // querySelectorAll throws UnimplementedError, an Error rather than an
        // Exception, on pseudo-classes it does not implement.
        try {
          return fragment.querySelectorAll(text);
        } catch (_) {
          return const <dom.Element>[];
        }
      });
      if (matched.isEmpty) continue;

      final specificity = _specificity(selector);
      for (final element in matched) {
        final list = candidates.putIfAbsent(element, () => <_Candidate>[]);
        for (final declaration in declarations) {
          list.add(_Candidate(declaration, specificity, sequence++));
        }
      }
    }
  }

  candidates.forEach((element, list) {
    list.sort(_byCascade);

    final normal = <String, String>{};
    final important = <String, String>{};
    for (final candidate in list) {
      final property = candidate.declaration.property;
      final winner = candidate.declaration.important ? important : normal;
      normal.remove(property);
      important.remove(property);
      winner[property] = candidate.declaration.value;
    }

    // HtmlWidget keeps the last declaration and ignores !important, so the
    // cascade has to come out as an order: an authored style beats a normal
    // rule, an important rule beats the authored style.
    element.attributes['style'] = [
      _serialize(normal),
      element.attributes['style']?.trim() ?? '',
      _serialize(important),
    ].where((part) => part.isNotEmpty).join(';');
  });
}

/// `HtmlWidget` ignores `bgcolor`. Written as the first declaration, it loses
/// to any authored style, as a presentational hint does in a browser.
bool _applyBgcolor(List<dom.Element> elements) {
  var applied = false;
  for (final element in elements) {
    if (!_bgcolorTags.contains(element.localName)) continue;
    final color = element.attributes['bgcolor']?.trim();
    if (color == null || !_bgcolorValue.hasMatch(color)) continue;

    element.attributes.remove('bgcolor');
    _prependStyle(element, 'background-color:$color');
    applied = true;
  }
  return applied;
}

/// `HtmlWidget` does not position a table by its `align`, so it becomes the
/// auto margins that center or right-align the table.
bool _applyTableAlign(List<dom.Element> elements) {
  var applied = false;
  for (final element in elements) {
    if (element.localName != 'table') continue;
    final margins = switch (element.attributes['align']?.trim().toLowerCase()) {
      'center' => 'margin-left:auto;margin-right:auto',
      'right' => 'margin-left:auto',
      _ => null,
    };
    if (margins == null || _declares(element, _horizontalMarginDeclaration)) {
      continue;
    }

    _prependStyle(element, margins);
    applied = true;
  }
  return applied;
}

/// A browser fits a table with no width to its content. `HtmlWidget` measures
/// each cell as a 100% wide block and treats `align="center"` like `<center>`:
/// a 100% width, and a `Center` that fills the width it is measured against.
bool _applyTableWidth(List<dom.Element> elements) {
  var applied = false;
  for (final table in elements) {
    if (table.localName != 'table' || _hasWidth(table)) continue;

    _prependStyle(table, 'width:auto');
    for (final cell in table.querySelectorAll('td, th')) {
      if (_closestTable(cell) != table) continue;
      if (cell.attributes['align']?.trim().toLowerCase() == 'center' &&
          !_declares(cell, _textAlignDeclaration)) {
        _prependStyle(cell, 'text-align:center');
      }
      if (!_hasWidth(cell)) _prependStyle(cell, 'width:auto');
    }
    applied = true;
  }
  return applied;
}

dom.Element? _closestTable(dom.Element element) {
  var parent = element.parent;
  while (parent != null && parent.localName != 'table') {
    parent = parent.parent;
  }
  return parent;
}

bool _hasWidth(dom.Element element) =>
    element.attributes.containsKey('width') ||
    _declares(element, _widthDeclaration);

bool _declares(dom.Element element, RegExp declaration) =>
    declaration.hasMatch(element.attributes['style'] ?? '');

void _prependStyle(dom.Element element, String declarations) {
  final style = element.attributes['style']?.trim() ?? '';
  element.attributes['style'] = style.isEmpty
      ? declarations
      : '$declarations;$style';
}

/// Collects the `body` and `html` rules, which a fragment parse drops along
/// with the element they target, in `HtmlWidget` just as much as here.
List<_Declaration> _pageDeclarations(
  ast.StyleSheet? sheet,
  String sourceHtml,
  bool allowRemoteImages,
) {
  final result = <_Declaration>[];
  for (final topLevel in sheet?.topLevels ?? const <ast.TreeNode>[]) {
    if (topLevel is! ast.RuleSet) continue;
    final group = topLevel.selectorGroup;
    if (group == null) continue;
    final targetsPage = group.selectors.any((selector) {
      final text = selector.span?.text.trim().toLowerCase();
      return text == 'body' || text == 'html';
    });
    if (!targetsPage) continue;
    result.addAll(_declarations(topLevel.declarationGroup, allowRemoteImages));
  }

  var hasBackground = result.any(
    (d) => _backgroundProperties.contains(d.property),
  );

  final bgcolor = _bodyBgcolor.firstMatch(sourceHtml)?.group(1);
  if (bgcolor != null && !hasBackground) {
    result.add(_Declaration('background-color', bgcolor, false));
    hasBackground = true;
  }

  // A page text color only lands safely on a page background: without one it
  // would meet whichever surface the app happens to be showing.
  if (!hasBackground) {
    result.removeWhere((d) => d.property == 'color');
  }
  return result;
}

/// Moves the body into a container carrying the page declarations, so the
/// renderer paints a background it would otherwise never see.
void _wrapInPageElement(
  dom.DocumentFragment fragment,
  List<_Declaration> declarations,
) {
  final page = dom.Element.tag('div');
  for (final node in fragment.nodes.toList()) {
    node.remove();
    page.append(node);
  }
  fragment.append(page);

  final merged = <String, String>{};
  for (final declaration in declarations) {
    if (!declaration.important) {
      merged[declaration.property] = declaration.value;
    }
  }
  for (final declaration in declarations) {
    if (declaration.important) merged[declaration.property] = declaration.value;
  }
  page.attributes['style'] = _serialize(merged);
}

String _serialize(Map<String, String> declarations) =>
    declarations.entries.map((e) => '${e.key}:${e.value}').join(';');

List<_Declaration> _declarations(
  ast.DeclarationGroup group,
  bool allowRemoteImages,
) {
  final result = <_Declaration>[];
  for (final node in group.declarations) {
    if (node is! ast.Declaration) continue;

    // A mixin declaration carries no property, so guard before reading one.
    if (node.expression == null) continue;

    final property = node.property.toLowerCase();
    if (!_isSupported(property)) continue;

    // An expression span covers only its first term, so read the value back
    // off the whole declaration instead.
    final source = node.span.text;
    final colon = source.indexOf(':');
    if (colon < 0) continue;
    final value = source
        .substring(colon + 1)
        .replaceFirst(_importantSuffix, '')
        .trim();
    if (value.isEmpty || value.contains('}')) continue;

    final kept = allowRemoteImages || !property.startsWith('background')
        ? value
        : _withoutUrls(value);
    if (kept.isEmpty) continue;

    result.add(_Declaration(property, kept, node.important));
  }
  return result;
}

/// Strips the image out of a background while keeping its solid color, which
/// an email designed for dark relies on to stay readable.
String _withoutUrls(String value) =>
    value.replaceAll(_urlFunction, ' ').replaceAll(_extraSpace, ' ').trim();

bool _isSupported(String property) =>
    _supportedProperties.contains(property) ||
    _supportedPrefixes.any(property.startsWith);

int _specificity(ast.Selector selector) {
  var ids = 0;
  var classes = 0;
  var types = 0;

  void count(ast.SimpleSelector simple) {
    if (simple is ast.IdSelector) {
      ids++;
    } else if (simple is ast.ClassSelector || simple is ast.AttributeSelector) {
      classes++;
    } else if (simple is ast.NegationSelector) {
      final argument = simple.negationArg;
      if (argument != null) count(argument);
    } else if (simple is ast.PseudoElementSelector) {
      types++;
    } else if (simple is ast.PseudoClassSelector) {
      classes++;
    } else if (simple is ast.ElementSelector && !simple.isWildcard) {
      types++;
    }
  }

  for (final sequence in selector.simpleSelectorSequences) {
    count(sequence.simpleSelector);
  }

  return ids.clamp(0, 99) * 10000 +
      classes.clamp(0, 99) * 100 +
      types.clamp(0, 99);
}

/// Rejects selectors that name an id, class or tag absent from the document,
/// which is most of a bundled stylesheet, without walking the tree.
bool _canMatch(
  ast.Selector selector,
  Set<String> ids,
  Set<String> classes,
  Set<String> tags,
) {
  for (final sequence in selector.simpleSelectorSequences) {
    final simple = sequence.simpleSelector;
    if (simple is ast.IdSelector) {
      if (!ids.contains(simple.name)) return false;
    } else if (simple is ast.ClassSelector) {
      if (!classes.contains(simple.name)) return false;
    } else if (simple is ast.ElementSelector && !simple.isWildcard) {
      if (!tags.contains(simple.name.toLowerCase())) return false;
    }
  }
  return true;
}

bool _declaresColors(List<dom.Element> elements) => elements.any(
  (element) =>
      element.attributes.containsKey('bgcolor') ||
      _colorDeclaration.hasMatch(element.attributes['style'] ?? ''),
);

int _byCascade(_Candidate a, _Candidate b) {
  if (a.declaration.important != b.declaration.important) {
    return a.declaration.important ? 1 : -1;
  }
  if (a.specificity != b.specificity) return a.specificity - b.specificity;
  return a.sequence - b.sequence;
}

class _Declaration {
  final String property;
  final String value;
  final bool important;

  const _Declaration(this.property, this.value, this.important);
}

class _Candidate {
  final _Declaration declaration;
  final int specificity;
  final int sequence;

  const _Candidate(this.declaration, this.specificity, this.sequence);
}
