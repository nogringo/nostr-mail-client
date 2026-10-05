import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:nmail_core/utils/text_links.dart';

class PlainTextBodyController extends ChangeNotifier {
  final String text;
  final void Function(String url) onOpenUrl;

  /// [position] is where the address was tapped, in the text's coordinates.
  final void Function(EmailPerson person, Offset position) onOpenAddress;

  PlainTextBodyController(
    this.text, {
    required this.onOpenUrl,
    required this.onOpenAddress,
  }) {
    segments = splitTextLinks(text);
    recognizers = [
      for (final segment in segments)
        switch (segment.kind) {
          TextSegmentKind.text => null,
          TextSegmentKind.url =>
            TapGestureRecognizer()..onTap = () => onOpenUrl(segment.text),
          TextSegmentKind.email =>
            TapGestureRecognizer()
              ..onTapUp = (details) =>
                  onOpenAddress(_person(segment.text), details.localPosition),
        },
    ];
  }

  late final List<TextLinkSegment> segments;

  /// Parallel to [segments]: the tap handler of each link, null for text.
  late final List<TapGestureRecognizer?> recognizers;

  final menuController = MenuController();

  /// The person the address menu shows, once an address was tapped.
  EmailPerson? menuPerson;

  static EmailPerson _person(String address) {
    final mailAddress = MailAddress(null, address);
    final pubkey = extractPubkeyFromAddress(address);
    return pubkey != null
        ? EmailPerson.nostr(pubkey, address: mailAddress)
        : EmailPerson.email(mailAddress);
  }

  void openMenu(EmailPerson person, Offset position) {
    menuPerson = person;
    notifyListeners();
    menuController.open(position: position);
  }

  @override
  void dispose() {
    for (final recognizer in recognizers) {
      recognizer?.dispose();
    }
    super.dispose();
  }
}
