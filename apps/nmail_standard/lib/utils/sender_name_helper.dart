import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

/// Get the best sender name for outgoing emails.
/// Priority: displayName → name → NIP-05 local part → null
String? getSenderName(Metadata? metadata) {
  if (metadata == null) return null;

  if (metadata.displayName != null && metadata.displayName!.isNotEmpty) {
    return metadata.displayName;
  }

  if (metadata.name != null && metadata.name!.isNotEmpty) {
    return GetUtils.capitalize(metadata.name!);
  }

  final nip05 = metadata.nip05;
  if (nip05 != null && nip05.contains('@')) {
    return GetUtils.capitalize(nip05.split('@').first);
  }

  return null;
}
