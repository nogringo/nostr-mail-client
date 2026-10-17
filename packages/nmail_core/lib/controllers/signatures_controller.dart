import 'package:collection/collection.dart';
import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/signature_html.dart';

enum SignatureUse { newEmail, reply }

/// The signatures of the private settings
/// ([Nostr Mail Settings](https://github.com/nogringo/protocols/blob/main/nostr-mail-settings.md#signatures)).
class SignaturesController extends ChangeNotifier {
  SignaturesController() {
    _read();
  }

  final _nostrMailService = GetIt.I<NostrMailService>();

  NostrMailClient get _client => _nostrMailService.client;

  PrivateSettings? _settings;

  List<Signature> get signatures => _settings?.signatures ?? const [];

  /// The plain text signature, while it still applies. Saving the first
  /// signature converts it.
  String? get legacyText {
    final settings = _settings;
    if (settings == null || settings.signatures != null) return null;
    final text = settings.signature;
    return text == null || text.trim().isEmpty ? null : text;
  }

  SignatureChoice? get defaultChoice => _settings?.defaultSignature;

  /// Entries of `identities`: the generated addresses take the default choice.
  List<MailAddress> get identities => _settings?.identities ?? const [];

  SignatureChoice? choiceOf(MailAddress identity) {
    final settings = _settings;
    return settings?.identitySignatures?[settings.identityKey(identity)];
  }

  Signature? byId(String? id) =>
      signatures.firstWhereOrNull((signature) => signature.id == id);

  /// Case-insensitive, as the spec compares names. The plain text signature
  /// takes its name once converted, unless [isLegacy] is the one being named.
  bool isNameTaken(String name, {String? exceptId, bool isLegacy = false}) {
    final wanted = name.trim().toLowerCase();
    if (!isLegacy &&
        legacyText != null &&
        wanted == _legacyName.toLowerCase()) {
      return true;
    }
    return signatures.any(
      (signature) =>
          signature.id != exceptId &&
          signature.name.trim().toLowerCase() == wanted,
    );
  }

  String get _legacyName =>
      AppLocalizations.of(AppRouter.rootContext!).signaturesLegacyName;

  void _read() {
    _settings = _nostrMailService.hasAccount
        ? _client.cachedPrivateSettings()
        : null;
    notifyListeners();
  }

  /// The first signature becomes the default, or nothing would sign emails.
  Future<Signature> create(String name, {required String html}) async {
    final legacy = legacyText;
    if (legacy != null) {
      await _createDefault(_legacyName, signatureHtmlFromText(legacy));
    }
    if (signatures.isEmpty && defaultChoice == null) {
      return _createDefault(name, html);
    }
    final signature = await _client.createSignature(name, html: html);
    _read();
    return signature;
  }

  /// Saves the edited plain text signature as the default one.
  Future<Signature> convertLegacy(String name, {required String html}) =>
      _createDefault(name, html);

  Future<Signature> _createDefault(String name, String html) async {
    final signature = await _client.createSignature(name, html: html);
    await _client.setDefaultSignature(
      SignatureChoice(newEmail: signature.id, reply: signature.id),
    );
    _read();
    return signature;
  }

  Future<Signature> update(
    String id, {
    required String name,
    required String html,
  }) async {
    final before = byId(id);
    final signature = await _client.updateSignature(id, name: name, html: html);
    _read();
    if (before != null) await _releaseImages(before.html);
    return signature;
  }

  Future<void> delete(String id) async {
    final signature = byId(id);
    await _client.deleteSignature(id);
    _read();
    if (signature != null) await _releaseImages(signature.html);
  }

  /// Drops the images of [html] that no signature shows anymore.
  Future<void> _releaseImages(String html) async {
    final shown = {
      for (final signature in signatures)
        ...signatureImageSources(signature.html),
    };
    final known = _settings?.signatureImages ?? const {};
    for (final key in signatureImageSources(html)) {
      if (!shown.contains(key) && known.containsKey(key)) {
        await _client.removeSignatureImage(key);
      }
    }
    _read();
  }

  /// [id] is a signature id, or an empty string for no signature.
  Future<void> setDefault(SignatureUse use, String id) async {
    await _client.setDefaultSignature(
      _withUse(defaultChoice ?? const SignatureChoice(), use, id),
    );
    _read();
  }

  /// A null [id] gives the identity the default choice for [use].
  Future<void> setForIdentity(
    MailAddress identity,
    SignatureUse use,
    String? id,
  ) async {
    final choice = _withUse(
      choiceOf(identity) ?? const SignatureChoice(),
      use,
      id,
    );
    final isEmpty = choice.newEmail == null && choice.reply == null;
    await _client.setIdentitySignature(identity, isEmpty ? null : choice);
    _read();
  }

  static SignatureChoice _withUse(
    SignatureChoice choice,
    SignatureUse use,
    String? id,
  ) => switch (use) {
    SignatureUse.newEmail => choice.copyWith(
      newEmail: id,
      clearNewEmail: id == null,
    ),
    SignatureUse.reply => choice.copyWith(reply: id, clearReply: id == null),
  };

  Future<Uint8List?> imageBytes(String key) => _client.getSignatureImage(key);

  /// Returns the key an `<img src>` of a signature names.
  Future<String> addImage(
    Uint8List bytes, {
    required String mimeType,
    String? dim,
  }) => _client.addSignatureImage(bytes, mimeType: mimeType, dim: dim);
}
