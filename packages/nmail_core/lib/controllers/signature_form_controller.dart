import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:mime/mime.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/utils/media_metadata/strip_media_metadata.dart';
import 'package:nmail_core/utils/signature_html.dart';
import 'signatures_controller.dart';

enum SignatureFormError { nameTaken, imageFailed, saveFailed }

typedef _PendingImage = ({Uint8List bytes, String mimeType, String? dim});

class SignatureFormController extends ChangeNotifier {
  final SignaturesController signatures;

  /// The signature being edited, null when creating one.
  final Signature? signature;

  /// The plain text signature being turned into the first signature.
  final String? legacyText;

  SignatureFormController({
    required this.signatures,
    this.signature,
    this.legacyText,
    required String legacyName,
  }) {
    nameController = TextEditingController(
      text: signature?.name ?? (legacyText != null ? legacyName : ''),
    );
    final delta = switch ((signature, legacyText)) {
      (final signature?, _) => signatureDeltaFromHtml(signature.html),
      (_, final text?) =>
        Delta()..insert(text.endsWith('\n') ? text : '$text\n'),
      _ => null,
    };
    quillController = delta == null
        ? QuillController.basic()
        : QuillController(
            document: Document.fromDelta(delta),
            selection: const TextSelection.collapsed(offset: 0),
          );
    nameController.addListener(_validate);
    quillController.addListener(_validate);
    _validate();
  }

  /// The spec's limit on a trimmed name.
  static const maxNameLength = 64;

  static const _pendingPrefix = 'pending-';

  late final TextEditingController nameController;
  late final QuillController quillController;
  final editorFocusNode = FocusNode();

  /// Images inserted since the form opened, uploaded on save under the `src`
  /// the editor shows them with.
  final _pending = <String, _PendingImage>{};
  final _loaded = <String, Future<Uint8List?>>{};
  final _resolved = <String, Uint8List>{};
  var _nextPending = 0;

  bool isSaving = false;
  bool canSave = false;
  SignatureFormError? error;
  bool _isDisposed = false;

  bool get isEditing => signature != null || legacyText != null;

  @override
  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    quillController.dispose();
    editorFocusNode.dispose();
    super.dispose();
  }

  bool _isKnownImage(String src) =>
      _pending.containsKey(src) || isSignatureImageKey(src);

  /// The bytes the editor shows for an image `src`.
  Future<Uint8List?> imageBytes(String src) {
    final pending = _pending[src];
    if (pending != null) return Future.value(pending.bytes);
    if (!isSignatureImageKey(src)) return Future.value(null);
    return _loaded.putIfAbsent(src, () async {
      final bytes = await signatures.imageBytes(src);
      if (bytes != null) _resolved[src] = bytes;
      return bytes;
    });
  }

  /// Bytes already at hand, so a rebuilt image does not blank for a frame.
  Uint8List? resolvedImage(String src) =>
      _pending[src]?.bytes ?? _resolved[src];

  void _validate() {
    final name = nameController.text.trim();
    final taken = signatures.isNameTaken(
      name,
      exceptId: signature?.id,
      isLegacy: legacyText != null,
    );
    final hasContent =
        quillController.document.toPlainText().trim().isNotEmpty ||
        _imageSources(quillController.document.toDelta()).isNotEmpty;
    final nextError = taken
        ? SignatureFormError.nameTaken
        : (error == SignatureFormError.nameTaken ? null : error);
    final nextCanSave = name.isNotEmpty && !taken && hasContent;
    if (nextError == error && nextCanSave == canSave) return;
    error = nextError;
    canSave = nextCanSave;
    notifyListeners();
  }

  static Iterable<String> _imageSources(Delta delta) sync* {
    for (final op in delta.toList()) {
      if (op.data case {'image': final String src}) yield src;
    }
  }

  Future<void> pickImage() async {
    try {
      final picked = await FilePicker.pickFile(type: FileType.image);
      if (picked == null) return;
      final bytes = stripMediaMetadata(await picked.readAsBytes());
      final image = await decodeImageFromList(bytes);
      final dim = '${image.width}x${image.height}';
      image.dispose();
      final src = '$_pendingPrefix${_nextPending++}';
      _pending[src] = (
        bytes: bytes,
        mimeType: lookupMimeType('', headerBytes: bytes) ?? 'image/png',
        dim: dim,
      );
      final selection = quillController.selection;
      quillController.replaceText(
        selection.start,
        selection.end - selection.start,
        BlockEmbed.image(src),
        TextSelection.collapsed(offset: selection.start + 1),
      );
    } catch (_) {
      error = SignatureFormError.imageFailed;
      notifyListeners();
    }
  }

  /// The saved signature, or null when saving failed and [error] says why.
  Future<Signature?> save() async {
    if (!canSave || isSaving) return null;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final html = signatureHtmlFromDelta(
        await _uploadPendingImages(quillController.document.toDelta()),
        keepImage: _isKnownImage,
      );
      final name = nameController.text.trim();
      return switch ((signature, legacyText)) {
        (final signature?, _) => await signatures.update(
          signature.id,
          name: name,
          html: html,
        ),
        (_, _?) => await signatures.convertLegacy(name, html: html),
        _ => await signatures.create(name, html: html),
      };
    } catch (_) {
      error = SignatureFormError.saveFailed;
      return null;
    } finally {
      if (!_isDisposed) {
        isSaving = false;
        notifyListeners();
      }
    }
  }

  Future<Delta> _uploadPendingImages(Delta delta) async {
    final keys = <String, String>{};
    for (final src in _imageSources(delta)) {
      final pending = _pending[src];
      if (pending == null || keys.containsKey(src)) continue;
      keys[src] = await signatures.addImage(
        pending.bytes,
        mimeType: pending.mimeType,
        dim: pending.dim,
      );
      _pending.remove(src);
      _pending[keys[src]!] = pending;
    }
    return Delta.fromOperations([
      for (final op in delta.toList())
        if (op.data case {'image': final String src} when keys[src] != null)
          Operation.insert({'image': keys[src]}, op.attributes)
        else
          op,
    ]);
  }
}
