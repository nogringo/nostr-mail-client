import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/android_file_saver.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class BackupController extends ChangeNotifier {
  final _client = GetIt.I<NostrMailService>().client;

  bool isExporting = false;
  bool isRestoring = false;
  bool isExportingMail = false;
  bool _isDisposed = false;

  bool get isBusy => isExporting || isRestoring || isExportingMail;

  Future<void> exportBackup(BuildContext context) async {
    final l = AppLocalizations.of(context);
    _update(() => isExporting = true);
    try {
      final backup = await _client.exportBackup();
      if (!context.mounted) return;
      await _saveZip(
        context,
        name: 'backup',
        bytes: backup.bytes,
        saved: l.backupExportSaved,
        missing: backup.missingBlobs > 0
            ? l.backupExportMissingBlobs(backup.missingBlobs)
            : null,
      );
    } catch (error) {
      if (!context.mounted) return;
      ToastHelper.error(context, l.backupExportFailed(error.toString()));
    } finally {
      _update(() => isExporting = false);
    }
  }

  Future<void> restoreBackup(BuildContext context) async {
    final l = AppLocalizations.of(context);
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: l.backupRestore,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (file == null) return;

      _update(() => isRestoring = true);
      final result = await _client.restoreBackup(await file.readAsBytes());
      await GetIt.I<AddressBookService>().reconcile();

      if (!context.mounted) return;
      final rejected = result.rejectedEvents + result.rejectedBlobs;
      ToastHelper.success(
        context,
        l.backupRestored,
        description: rejected > 0 ? l.backupRestoreRejected(rejected) : null,
      );
    } on BackupAccountMismatchException {
      if (!context.mounted) return;
      ToastHelper.error(context, l.backupRestoreWrongAccount);
    } on InvalidBackupException {
      if (!context.mounted) return;
      ToastHelper.error(context, l.backupRestoreInvalidFile);
    } catch (error) {
      if (!context.mounted) return;
      ToastHelper.error(context, l.backupRestoreFailed(error.toString()));
    } finally {
      _update(() => isRestoring = false);
    }
  }

  Future<void> exportMail(BuildContext context) async {
    final l = AppLocalizations.of(context);
    _update(() => isExportingMail = true);
    try {
      final export = await _client.exportMail();
      if (!context.mounted) return;
      await _saveZip(
        context,
        name: 'emails',
        bytes: export.bytes,
        saved: l.backupExportMailSaved,
        missing: export.missingEmails > 0
            ? l.backupExportMailMissing(export.missingEmails)
            : null,
      );
    } catch (error) {
      if (!context.mounted) return;
      ToastHelper.error(context, l.backupExportMailFailed(error.toString()));
    } finally {
      _update(() => isExportingMail = false);
    }
  }

  /// Saves [bytes] as `nmail-<name>-<date>.zip`: to Downloads on Android,
  /// through the save dialog elsewhere. [missing] says what the file lacks.
  Future<void> _saveZip(
    BuildContext context, {
    required String name,
    required Uint8List bytes,
    required String Function(String path) saved,
    String? missing,
  }) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'nmail-$name-$date.zip';

    if (PlatformHelper.isAndroid) {
      final path = await AndroidFileSaver.saveToDownloads(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/zip',
      );
      if (!context.mounted) return;
      ToastHelper.success(context, saved(path), description: missing);
    } else {
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/zip',
      );
      if (missing != null && context.mounted) {
        ToastHelper.info(context, missing);
      }
    }
  }

  void _update(VoidCallback change) {
    change();
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
