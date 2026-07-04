import 'package:blossom_cache/blossom_cache.dart';
import 'package:idb_shim/idb_browser.dart';

Future<BlossomCache> createBlossomCache() async {
  return IdbBlossomCache.open(factory: idbFactoryBrowser);
}
