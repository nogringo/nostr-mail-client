/// How an account signs events, for display in the accounts list.
///
/// Finer grained than ndk's `AccountType`, which lumps browser extensions,
/// signer apps and remote bunkers together as `externalSigner`.
enum AccountSignerKind {
  privateKey,
  browserExtension,
  signerApp,
  bunker,
  external,
}
