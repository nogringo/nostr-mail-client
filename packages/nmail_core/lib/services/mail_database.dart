import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:path_provider/path_provider.dart';

/// Opens the nostr_mail drift store: a `.sqlite` file next to the sembast
/// database on native, OPFS or IndexedDB through `drift_worker.js` on web.
///
/// The name must differ from the sembast database's (`nostr_mail`): on web both
/// are IndexedDB databases and the name is the whole key, so sharing one makes
/// drift open sembast's and fail on its version.
NostrMailDatabase openMailDatabase() {
  return NostrMailDatabase(
    driftDatabase(
      name: kDebugMode ? 'nostr_mail_store_dev' : 'nostr_mail_store',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
}
