/// The email address a NIP-05 identifier would be if its domain received
/// mail, or null when it cannot be one (`_@domain`, bare domain, npub).
String? nip05MailAddress(String? nip05) {
  if (nip05 == null) return null;
  final parts = nip05.trim().toLowerCase().split('@');
  if (parts.length != 2) return null;
  final [local, domain] = parts;
  if (local.isEmpty || local == '_' || local.startsWith('npub1')) return null;
  if (!domain.contains('.')) return null;
  return '$local@$domain';
}
