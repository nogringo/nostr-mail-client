import '../../models/mailbox.dart';

/// Path constants for all app routes.
///
/// Mailbox routes (`/inbox`, `/sent`, `/archive`, `/trash`, `/folder/<id>`,
/// `/label/<id>`) drive the inbox view's current mailbox via the URL itself -
/// the sidebar uses `context.go` to switch, and the route builder syncs
/// `InboxController.currentMailbox` from the URL.
///
/// Email detail is nested under each folder (`/<folder>/email/:id`) so
/// in-app navigation via `context.go` updates the URL and preserves a
/// real back-stack to the originating folder.
///
/// `/:nostrId` is a root-level dispatcher for share links (NIP-19
/// bech32 entities: nevent, note, npub, nprofile). The view inspects
/// the prefix and renders the appropriate sub-view.
class AppRoutes {
  // Public (no auth required)
  static const login = '/login';
  static const onboarding = '/onboarding';

  /// Report of a NIP-62 request to vanish, reached right after the account it
  /// deleted left the device. Public because that account is already gone.
  static const accountDeleted = '/account-deleted';
  static const accountDeletedRequestParam = 'request';

  /// Post-login step for an account with no NIP-65 relay list. Authenticated,
  /// but outside the shell: nothing else can be loaded until it resolves.
  static const relaySetup = '/relay-setup';

  // Folders (drive InboxController.currentMailbox from URL)
  static const inbox = '/inbox';
  static const sent = '/sent';
  static const archive = '/archive';
  static const trash = '/trash';
  static const scheduled = '/scheduled';

  // User folders and tags, by the id their private-settings entry carries.
  // The UI calls tags labels, and so does the URL.
  static const userFolder = '/folder/:folderId';
  static const label = '/label/:labelId';

  static const contacts = '/contacts';

  // Path segment for the nested email detail route under each folder.
  static const emailSegment = 'email/:id';

  // Actions
  static const compose = '/compose';
  static const contactForm = '/contacts/form';
  static const profile = '/profile';
  static const accounts = '/accounts';
  static const addAccount = '/accounts/add';

  // Settings (nested)
  static const settings = '/settings';
  static const settingsAppearance = '/settings/appearance';
  static const settingsIdentities = '/settings/identities';
  static const settingsIdentitiesNew = '/settings/identities/new';
  static const settingsMessages = '/settings/messages';
  static const settingsNotifications = '/settings/notifications';
  static const settingsHosting = '/settings/hosting';
  static const settingsDebugTools = '/settings/debug-tools';
  static const settingsAbout = '/settings/about';
  static const settingsFolders = '/settings/folders';

  // Backward compat: legacy in-app links keep working.
  // `/email/:id` redirects to `/:hex` which the nostr dispatcher resolves.
  static const emailLegacy = '/email/:id';

  // Root-level NIP-19 dispatcher (handles nevent, note, npub, nprofile)
  static const nostrIdParam = 'nostrId';

  static String mailboxPath(Mailbox mailbox) => switch (mailbox) {
    SystemMailbox(folder: MailFolder.inbox) => inbox,
    SystemMailbox(folder: MailFolder.sent) => sent,
    SystemMailbox(folder: MailFolder.archive) => archive,
    SystemMailbox(folder: MailFolder.trash) => trash,
    FolderMailbox(:final id) => '/folder/$id',
    TagMailbox(:final id) => '/label/$id',
  };

  /// In-app deep-linkable email URL: `/<mailbox>/email/<hex>`.
  static String emailPath(Mailbox mailbox, String id) =>
      '${mailboxPath(mailbox)}/email/$id';

  /// The request id travels in the URL rather than in `extra` so a reload on
  /// web keeps the report on screen.
  static String accountDeletedPath(String requestId) =>
      '$accountDeleted?$accountDeletedRequestParam=$requestId';
}
