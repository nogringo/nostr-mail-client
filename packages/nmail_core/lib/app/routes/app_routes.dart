import '../../controllers/inbox_controller.dart';

/// Path constants for all app routes.
///
/// Folder routes (`/inbox`, `/sent`, `/archive`, `/trash`) drive the
/// inbox view's current folder via the URL itself - the sidebar uses
/// `context.go` to switch folders, and the route builder syncs
/// `InboxController.currentFolder` from the URL.
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

  // Folders (drive InboxController.currentFolder from URL)
  static const inbox = '/inbox';
  static const sent = '/sent';
  static const archive = '/archive';
  static const trash = '/trash';
  static const scheduled = '/scheduled';
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

  // Backward compat: legacy in-app links keep working.
  // `/email/:id` redirects to `/:hex` which the nostr dispatcher resolves.
  static const emailLegacy = '/email/:id';

  // Root-level NIP-19 dispatcher (handles nevent, note, npub, nprofile)
  static const nostrIdParam = 'nostrId';

  static String folderPath(MailFolder folder) => switch (folder) {
    MailFolder.inbox => inbox,
    MailFolder.sent => sent,
    MailFolder.archive => archive,
    MailFolder.trash => trash,
  };

  /// In-app deep-linkable email URL: `/<folder>/email/<hex>`.
  static String emailPath(MailFolder folder, String id) =>
      '${folderPath(folder)}/email/$id';

  /// The request id travels in the URL rather than in `extra` so a reload on
  /// web keeps the report on screen.
  static String accountDeletedPath(String requestId) =>
      '$accountDeleted?$accountDeletedRequestParam=$requestId';
}
