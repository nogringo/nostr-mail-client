import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Every tab shares one mail store, and a tab opening it with another schema
/// drops and rebuilds the tables the others still read. Announces this tab's
/// [schemaVersion] and reloads it when another tab announces a newer one.
void reloadOnNewerSchema(int schemaVersion) {
  final channel = web.BroadcastChannel('nmail-mail-schema');
  web.EventStreamProviders.messageEvent.forTarget(channel).listen((event) {
    final announced = (event.data as JSNumber).toDartInt;
    if (announced > schemaVersion) web.window.location.reload();
  });
  channel.postMessage(schemaVersion.toJS);
}
