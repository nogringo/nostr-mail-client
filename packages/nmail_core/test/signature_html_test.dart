import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/signature_html.dart';

const _key = '3f1a9c0e7b2d4f6a8c5e1b9d7f3a2c4e6b8d0f1a3c5e7b9d2f4a6c8e0b1d3f5a';

void main() {
  group('signature HTML', () {
    test('keeps the key of a signature image through the editor', () {
      const html = '<p>Alice</p><p><img src="$_key" alt="Logo"></p>';
      final delta = signatureDeltaFromHtml(html);

      expect(
        delta.toList().map((op) => op.data),
        contains(equals({'image': _key})),
      );
      final back = signatureHtmlFromDelta(delta);
      expect(signatureImageSources(back), {_key});
      expect(back, isNot(contains('unsafe:')));
    });

    test('a delta from HTML ends with a newline', () {
      final delta = signatureDeltaFromHtml('<b>Alice</b>');
      expect((delta.last.data as String).endsWith('\n'), isTrue);
      expect(() => Document.fromDelta(delta), returnsNormally);
    });

    test('plain text keeps one paragraph per line', () {
      final html = signatureHtmlFromText('Alice\nAcme\nhttps://example.com');
      expect(signaturePreview(html), 'Alice\nAcme\nhttps://example.com');
    });

    test('images can be left out', () {
      final html = signatureHtmlWithoutImages(
        '<p>Alice</p><img src="$_key"><img src=\'$_key\' alt="x">',
      );
      expect(html, '<p>Alice</p>');
    });
  });

  group('signature block', () {
    Delta signature(String text) => Delta()..insert('$text\n');

    test('goes after a blank line below an empty body', () {
      final replaced = replaceSignature(
        Document().toDelta(),
        signature: signature('Alice'),
      );
      expect(replaced.document.toPlainText(), '\n\nAlice\n');
      expect(
        endsWithSignature(replaced.document.toDelta(), replaced.block!),
        isTrue,
      );
    });

    test('stays intact while the user writes above it', () {
      final replaced = replaceSignature(
        Document().toDelta(),
        signature: signature('Alice'),
      );
      final document = replaced.document..insert(0, 'Hello');
      expect(endsWithSignature(document.toDelta(), replaced.block!), isTrue);
    });

    test('is no longer intact once edited', () {
      final replaced = replaceSignature(
        Document().toDelta(),
        signature: signature('Alice'),
      );
      final document = replaced.document;
      document.insert(document.length - 2, 'x');
      expect(endsWithSignature(document.toDelta(), replaced.block!), isFalse);
    });

    test('is no longer at the end once text follows it', () {
      final replaced = replaceSignature(
        Document().toDelta(),
        signature: signature('Alice'),
      );
      final document = replaced.document;
      document.insert(document.length - 1, '\nP.S.');
      expect(endsWithSignature(document.toDelta(), replaced.block!), isFalse);
    });

    test('is swapped without touching the body', () {
      final first = replaceSignature(
        Document().toDelta(),
        signature: signature('Alice'),
      );
      final document = first.document..insert(0, 'Hello');
      final second = replaceSignature(
        document.toDelta(),
        block: first.block,
        signature: Delta()
          ..insert('Bob', {'bold': true})
          ..insert('\n'),
      );
      expect(second.document.toPlainText(), 'Hello\n\nBob\n');
      expect(
        endsWithSignature(second.document.toDelta(), second.block!),
        isTrue,
      );
    });

    test('is removed with its blank line', () {
      final first = replaceSignature(
        Document().toDelta(),
        signature: signature('Alice'),
      );
      final document = first.document..insert(0, 'Hello');
      final removed = replaceSignature(document.toDelta(), block: first.block);
      expect(removed.document.toPlainText(), 'Hello\n');
      expect(removed.block, isNull);
    });

    test('follows a body ending in a list', () {
      final body = Delta()
        ..insert('item')
        ..insert('\n', {'list': 'bullet'});
      final replaced = replaceSignature(body, signature: signature('Alice'));
      expect(replaced.document.toPlainText(), 'item\n\nAlice\n');
      expect(
        endsWithSignature(replaced.document.toDelta(), replaced.block!),
        isTrue,
      );
    });
  });
}
