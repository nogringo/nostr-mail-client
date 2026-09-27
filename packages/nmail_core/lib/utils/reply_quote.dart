import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:nmail_core/utils/prepare_email_html.dart';
import 'package:nostr_mail/nostr_mail.dart' show Email;

const _escape = HtmlEscape(HtmlEscapeMode.element);
const _quoteClass = 'nmail_quote';

/// MIME text parts use CRLF. A `\r` left in a Quill document renders as an
/// extra line break, and on web the browser input rewrites it, which corrupts
/// the document.
String normalizeLineBreaks(String text) =>
    text.replaceAll(RegExp(r'\r\n?'), '\n');

/// [email] quoted below a reply or forward: the [header] lines, then its body,
/// which a reply sets off with a border.
String quoteHtml(
  Email email, {
  required List<String> header,
  bool asReply = false,
}) {
  final html = email.htmlBody;
  final body = html != null && html.isNotEmpty
      ? prepareQuotedHtml(html)
      : _escape
            .convert(normalizeLineBreaks(email.body))
            .replaceAll('\n', '<br>');
  final quoted = asReply
      ? '<blockquote style="margin:0 0 0 6px;border-left:1px solid #ccc;'
            'padding-left:8px">$body</blockquote>'
      : '<br><div>$body</div>';
  return '<div class="$_quoteClass">'
      '<div>${header.map(_escape.convert).join('<br>')}</div>'
      '$quoted'
      '</div>';
}

/// [body] followed by [quote], in the form [splitQuote] takes apart.
String appendQuote(String body, String? quote) =>
    quote == null ? body : '$body<br>$quote';

/// The HTML [appendQuote] made, taken apart into what the author wrote and
/// the email it quotes.
({String body, String? quote, bool quoteIsReply}) splitQuote(String html) {
  final fragment = html_parser.parseFragment(html);
  final quote = fragment.querySelector('div.$_quoteClass');
  if (quote == null) return (body: html, quote: null, quoteIsReply: false);

  final separator = quote.previousElementSibling;
  if (separator?.localName == 'br') separator!.remove();
  quote.remove();
  return (
    body: fragment.outerHtml,
    quote: quote.outerHtml,
    // quoteHtml sets the body of a reply off in a blockquote.
    quoteIsReply: quote.children.any(
      (child) => child.localName == 'blockquote',
    ),
  );
}
