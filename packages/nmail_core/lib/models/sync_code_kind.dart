/// What the user pasted in the sync code field, told apart by its prefix.
enum SyncCodeKind {
  nsec,

  /// NIP-49 encrypted private key, which needs a password.
  ncryptsec,

  /// NIP-46 remote signer.
  bunker;

  static SyncCodeKind? of(String code) {
    final value = code.trim();
    if (value.startsWith('ncryptsec1')) return ncryptsec;
    if (value.startsWith('nsec1')) return nsec;
    if (value.startsWith('bunker://')) return bunker;
    return null;
  }
}
