import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:nmail_core/utils/prepare_email_html.dart';

String inlined(String html, {bool allowRemoteImages = true}) =>
    prepareEmailHtml(html, allowRemoteImages: allowRemoteImages).html;

String styleOf(String html, String selector) =>
    html_parser
        .parseFragment(html)
        .querySelector(selector)!
        .attributes['style'] ??
    '';

void main() {
  group('prepareEmailHtml cascade', () {
    test('returns the input untouched when there is no style block', () {
      const html = '<p class="a">hello</p>';
      expect(inlined(html), html);
    });

    test('applies a class rule to the matching element', () {
      const html = '<style>.a{color:red}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red');
    });

    test('drops the style element from the output', () {
      const html = '<style>.a{color:red}</style><p class="a">x</p>';
      expect(inlined(html), isNot(contains('<style')));
    });

    test('keeps the authored inline style last so it wins', () {
      const html =
          '<style>.a{color:red}</style><p class="a" style="color:blue">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red;color:blue');
    });

    test('lets a class rule beat a tag rule', () {
      const html =
          '<style>p{color:red}.a{color:blue}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:blue');
    });

    test('lets a tag rule lose even when it comes last', () {
      const html =
          '<style>.a{color:blue}p{color:red}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:blue');
    });

    test('lets an id rule beat a class rule', () {
      const html =
          '<style>.a{color:blue}#x{color:green}</style>'
          '<p id="x" class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:green');
    });

    test('breaks a specificity tie with source order', () {
      const html =
          '<style>.a{color:red}.a{color:blue}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:blue');
    });

    test('lets important beat a higher specificity', () {
      const html =
          '<style>#x{color:red}.a{color:blue!important}</style>'
          '<p id="x" class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:blue');
    });

    test('lets an important rule beat the authored inline style', () {
      const html =
          '<style>.hide{display:none!important}</style>'
          '<div class="hide" style="display:block">x</div>';
      expect(styleOf(inlined(html), 'div'), 'display:block;display:none');
    });

    test('keeps a normal rule behind the authored inline style', () {
      const html =
          '<style>.a{color:red}.a{margin:0!important}</style>'
          '<p class="a" style="color:blue">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red;color:blue;margin:0');
    });

    test('moves a property that turns important out of the normal group', () {
      const html =
          '<style>.a{color:red}.b{color:green!important}</style>'
          '<p class="a b" style="color:blue">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:blue;color:green');
    });

    test('never writes important into the output', () {
      const html = '<style>.a{color:blue!important}</style><p class="a">x</p>';
      expect(inlined(html), isNot(contains('important')));
    });

    test('supports descendant selectors', () {
      const html =
          '<style>.wrap td{padding:4px}</style>'
          '<div class="wrap"><table><tr><td>x</td></tr></table></div>';
      expect(styleOf(inlined(html), 'td'), 'padding:4px');
    });

    test('supports child selectors', () {
      const html =
          '<style>div > p{color:red}</style><div><p>x</p></div><p>y</p>';
      final out = inlined(html);
      expect(styleOf(out, 'div p'), 'color:red');
      expect(styleOf(out, 'div + p'), '');
    });

    test('supports comma separated selector groups', () {
      const html =
          '<style>.a, .b{color:red}</style>'
          '<p class="a">x</p><span class="b">y</span>';
      final out = inlined(html);
      expect(styleOf(out, 'p'), 'color:red');
      expect(styleOf(out, 'span'), 'color:red');
    });

    test('raises specificity through a negation argument', () {
      const html =
          '<style>.a{color:red}.a:not(.skip){color:blue}</style>'
          '<p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:blue');
    });

    test('concatenates several style blocks in order', () {
      const html =
          '<style>.a{color:red}</style><style>.a{color:blue}</style>'
          '<p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:blue');
    });

    test('preserves shorthand before longhand order', () {
      const html =
          '<style>.a{margin:0}.a{margin-top:8px}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'margin:0;margin-top:8px');
    });
  });

  group('prepareEmailHtml robustness', () {
    test('skips media blocks without losing neighbouring rules', () {
      const html =
          '<style>@media (max-width:600px){.a{color:red}}.b{color:blue}</style>'
          '<p class="a">x</p><span class="b">y</span>';
      final out = inlined(html);
      expect(styleOf(out, 'p'), '');
      expect(styleOf(out, 'span'), 'color:blue');
    });

    test('skips font-face and import without throwing', () {
      const html =
          '<style>@import url(x.css);'
          '@font-face{font-family:Foo;src:url(foo.woff)}'
          '.a{color:red}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red');
    });

    test('ignores a print-only style block', () {
      const html =
          '<style media="print">.a{color:red}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), '');
    });

    test('ignores a style block narrowed by a media feature', () {
      const html =
          '<style media="screen and (max-width:600px)">'
          '.desktop-only{display:none}</style>'
          '<div class="desktop-only">visible</div>';
      expect(styleOf(inlined(html), 'div'), '');
    });

    test('ignores a style block negated by not all', () {
      const html =
          '<style media="not all">.a{color:red}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), '');
    });

    test('applies an unconditional screen style block', () {
      const html =
          '<style media="screen">.a{color:red}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red');
    });

    test('applies an only screen style block', () {
      const html =
          '<style media="only screen">.a{color:red}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red');
    });

    test('applies a style block listing screen among other types', () {
      const html =
          '<style media="screen, print">.a{color:red}</style>'
          '<p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red');
    });

    test('applies a stylesheet wrapped in an HTML comment', () {
      const html = '<style><!--\n.a{color:red}\n--></style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'color:red');
    });

    test('skips an unsupported pseudo-class without losing other rules', () {
      const html =
          '<style>.a:hover{color:red}.b{color:blue}</style>'
          '<p class="a">x</p><span class="b">y</span>';
      final out = inlined(html);
      expect(styleOf(out, 'p'), '');
      expect(styleOf(out, 'span'), 'color:blue');
    });

    test('skips nth-of-type without losing other rules', () {
      const html =
          '<style>li:nth-of-type(2){color:red}.b{color:blue}</style>'
          '<ul><li>x</li><li>y</li></ul><span class="b">z</span>';
      expect(styleOf(inlined(html), 'span'), 'color:blue');
    });

    test('keeps valid rules when the stylesheet is malformed', () {
      const html =
          '<style>.a{color:}.b{color:blue}</style>'
          '<p class="a">x</p><span class="b">y</span>';
      expect(styleOf(inlined(html), 'span'), 'color:blue');
    });

    test('returns an empty body unchanged', () {
      expect(inlined(''), '');
      expect(inlined('   '), '   ');
    });

    test('is idempotent', () {
      const html =
          '<style>.a{color:red}</style><p class="a" style="margin:0">x</p>';
      final once = inlined(html);
      expect(inlined(once), once);
    });

    test('preserves text content and entities', () {
      const html = '<style>.a{color:red}</style><p class="a">a &amp; b</p>';
      expect(inlined(html), contains('a &amp; b'));
    });

    test('leaves img tags untouched', () {
      const html =
          '<style>.a{color:red}</style><img src="https://e.test/p.gif">';
      expect(inlined(html), contains('src="https://e.test/p.gif"'));
    });
  });

  group('prepareEmailHtml filtering', () {
    test('drops properties HtmlWidget cannot render', () {
      const html =
          '<style>.a{letter-spacing:2px;box-shadow:0 0 2px red;'
          'padding-top:4px}</style><p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), 'padding-top:4px');
    });

    test('drops remote background images when images are blocked', () {
      const html =
          '<style>.a{background-image:url(https://e.test/p.gif)}</style>'
          '<p class="a">x</p>';
      expect(styleOf(inlined(html, allowRemoteImages: false), 'p'), '');
    });

    test('keeps the solid color of a shorthand while dropping its url', () {
      const html =
          '<style>.a{background:#fff url(https://e.test/p.gif) no-repeat}'
          '</style><p class="a">x</p>';
      final style = styleOf(inlined(html, allowRemoteImages: false), 'p');
      expect(style, isNot(contains('e.test')));
      expect(style, contains('#fff'));
    });

    test('drops a shorthand that carries nothing but a url', () {
      const html =
          '<style>.a{background:url(https://e.test/p.gif)}</style>'
          '<p class="a">x</p>';
      expect(styleOf(inlined(html, allowRemoteImages: false), 'p'), '');
    });

    test('keeps background-color when images are blocked', () {
      const html = '<style>.a{background-color:#fff}</style><p class="a">x</p>';
      expect(
        styleOf(inlined(html, allowRemoteImages: false), 'p'),
        'background-color:#fff',
      );
    });

    test('keeps remote background images when images are allowed', () {
      const html =
          '<style>.a{background-image:url(https://e.test/p.gif)}</style>'
          '<p class="a">x</p>';
      expect(styleOf(inlined(html), 'p'), contains('https://e.test/p.gif'));
    });
  });

  group('prepareEmailHtml hasImages', () {
    bool hasImages(String html, {bool allowRemoteImages = true}) =>
        prepareEmailHtml(html, allowRemoteImages: allowRemoteImages).hasImages;

    test('is false for plain markup', () {
      expect(hasImages('<p>bonjour</p>'), isFalse);
    });

    test('is true for an img tag', () {
      expect(hasImages('<img src="https://e.test/p.gif">'), isTrue);
    });

    test('stays true for a blocked background coming from a style block', () {
      const html =
          '<style>.hero{background-image:url(https://e.test/p.gif)}</style>'
          '<div class="hero">x</div>';
      expect(hasImages(html, allowRemoteImages: false), isTrue);
    });

    test('stays true for a blocked background on an inline attribute', () {
      const html = '<div style="background:#fff url(p.gif) no-repeat">x</div>';
      expect(hasImages(html, allowRemoteImages: false), isTrue);
    });
  });

  group('prepareEmailHtml page background', () {
    EmailHtml prepared(String html) =>
        prepareEmailHtml(html, allowRemoteImages: true);

    test('hoists a body background onto a wrapper the renderer can paint', () {
      const html = '<style>body{background-color:#12121a}</style><p>x</p>';
      final out = prepared(html);
      expect(out.paintsOwnBackground, isTrue);
      expect(out.html, startsWith('<div style="background-color:#12121a">'));
    });

    test('hoists an html selector the same way', () {
      const html = '<style>html{background-color:#101010}</style><p>x</p>';
      expect(prepared(html).paintsOwnBackground, isTrue);
    });

    test('hoists an inherited body text color alongside a background', () {
      const html =
          '<style>body{background-color:#12121a;color:#f0f0f5}</style>'
          '<p>x</p>';
      expect(prepared(html).html, contains('color:#f0f0f5'));
    });

    test('drops a body text color that comes without a background', () {
      const html = '<style>body{color:#eeeeee}</style><p>texte</p>';
      final out = prepared(html);
      expect(out.html, isNot(contains('#eeeeee')));
      expect(out.paintsOwnBackground, isFalse);
    });

    test('falls back to the body bgcolor attribute', () {
      const html =
          '<style>body{color:#fff}</style><body bgcolor="#222233"><p>x</p>';
      final out = prepared(html);
      expect(out.paintsOwnBackground, isTrue);
      expect(out.html, contains('background-color:#222233'));
    });

    test('reads the bgcolor attribute when there is no style block', () {
      const html = '<body bgcolor="#111111"><p>x</p>';
      final out = prepared(html);
      expect(out.paintsOwnBackground, isTrue);
      expect(out.html, contains('background-color:#111111'));
    });

    test('keeps a blocked background solid color as the page background', () {
      const html =
          '<style>body{background:#0a0a0a url(https://e.test/p.gif)}</style>'
          '<p>x</p>';
      final out = prepareEmailHtml(html, allowRemoteImages: false);
      expect(out.paintsOwnBackground, isTrue);
      expect(out.html, contains('#0a0a0a'));
      expect(out.html, isNot(contains('e.test')));
    });

    test('prefers a declared background over the bgcolor attribute', () {
      const html =
          '<style>body{background-color:#12121a}</style>'
          '<body bgcolor="#ffffff"><p>x</p>';
      expect(prepared(html).html, isNot(contains('#ffffff')));
    });

    test('is false when only inner elements carry a background', () {
      const html =
          '<style>.card{background-color:#eee}</style>'
          '<div class="card">x</div>';
      expect(prepared(html).paintsOwnBackground, isFalse);
    });

    test('adds no wrapper when there is no page rule', () {
      const html = '<style>.a{color:red}</style><p class="a">x</p>';
      expect(prepared(html).html, '<p class="a" style="color:red">x</p>');
    });

    test('keeps the wrapper out of reach of the other selectors', () {
      const html =
          '<style>body{background-color:#111}div{border:1px solid red}</style>'
          '<p>x</p>';
      expect(prepared(html).html, isNot(contains('border')));
    });
  });

  group('prepareEmailHtml declaresColors', () {
    bool declares(String html) =>
        prepareEmailHtml(html, allowRemoteImages: true).declaresColors;

    test('is false for plain markup', () {
      expect(declares('<p>bonjour</p>'), isFalse);
    });

    test('is true for a bgcolor attribute', () {
      expect(
        declares('<table bgcolor="#ffffff"><tr><td>x</td></tr></table>'),
        isTrue,
      );
    });

    test('is true for an authored inline color', () {
      expect(declares('<p style="color:#333">x</p>'), isTrue);
    });

    test('is true for a color coming from a style block', () {
      expect(
        declares('<style>.a{background-color:#fff}</style><p class="a">x</p>'),
        isTrue,
      );
    });

    test('is false when the only declaration is not a color', () {
      expect(
        declares('<style>.a{padding:4px}</style><p class="a">x</p>'),
        isFalse,
      );
    });
  });
}
