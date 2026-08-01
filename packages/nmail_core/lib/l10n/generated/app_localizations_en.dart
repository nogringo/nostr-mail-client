// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionClose => 'Close';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionBack => 'Back';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionUpload => 'Upload';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateLoadingEllipsis => 'Loading...';

  @override
  String get stateResetting => 'Resetting...';

  @override
  String get stateValidating => 'Validating...';

  @override
  String get stateDownloading => 'Downloading...';

  @override
  String get stateUploading => 'Uploading...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsManageAppearance => 'Manage appearance';

  @override
  String get settingsManageAppearanceSubtitle => 'Theme, background, language';

  @override
  String get settingsBackground => 'Background';

  @override
  String get settingsDynamicTheme => 'Dynamic theme';

  @override
  String get settingsDynamicThemeSubtitle =>
      'Generate colors from background image';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageDialogTitle => 'Choose a language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsEnableNotifications => 'Enable notifications';

  @override
  String get settingsEnableNotificationsSubtitle =>
      'Get notified when a new email arrives.';

  @override
  String get settingsManageNotifications => 'Manage notifications';

  @override
  String get settingsManageNotificationsSubtitle => 'Alerts for new emails';

  @override
  String get settingsUnifiedPushDistributorMissingTitle =>
      'Push notifications unavailable';

  @override
  String get settingsUnifiedPushDistributorMissingSubtitle =>
      'Install a UnifiedPush distributor like Sunup to receive notifications in the background.';

  @override
  String get settingsUnifiedPushDistributorInstallSunup => 'Install Sunup';

  @override
  String get settingsAdvancedOptions => 'Advanced options';

  @override
  String get settingsAlwaysLoadImages => 'Always load images';

  @override
  String get settingsAlwaysLoadImagesSubtitle =>
      'Images are blocked by default for privacy';

  @override
  String get settingsIdentities => 'Identities';

  @override
  String get settingsManageIdentities => 'Manage identities';

  @override
  String get settingsManageIdentitiesSubtitle =>
      'Add, remove or reorder addresses';

  @override
  String get settingsCompose => 'Compose';

  @override
  String get settingsEmailSignature => 'Email signature';

  @override
  String get settingsEmailSignatureEmpty => 'No signature configured';

  @override
  String get settingsEmailSignatureHint => 'Enter your signature...';

  @override
  String get settingsSynchronization => 'Synchronization';

  @override
  String get settingsHosting => 'Hosting';

  @override
  String get settingsHostingSubtitle => 'Relays, blossom servers, connectivity';

  @override
  String get settingsDebugTools => 'Debug Tools';

  @override
  String get settingsDebugToolsSubtitle => 'Testing and development features';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsCopySyncCode => 'Copy sync code';

  @override
  String get settingsCopySyncCodeSubtitle =>
      'Use this code to sync your account on other devices';

  @override
  String get settingsSyncCodeCopied => 'Sync code copied';

  @override
  String get settingsLogOut => 'Log out';

  @override
  String get settingsResetApplication => 'Reset application';

  @override
  String get settingsResetApplicationSubtitle => 'Delete all local data';

  @override
  String get settingsResetConfirmMessage =>
      'This will delete all local data including settings, background images, and log you out.\n\nThis action cannot be undone.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutApp => 'App information';

  @override
  String get settingsAboutAppSubtitle => 'Version, source code';

  @override
  String get settingsDeveloper => 'Developer';

  @override
  String get settingsLicense => 'License';

  @override
  String get settingsSourceCode => 'Source code';

  @override
  String get settingsSourceCodeSubtitle => 'View on GitHub';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Apple App Store privacy details';

  @override
  String get settingsEarlyAccess => 'Early access';

  @override
  String get settingsEarlyAccessMessage =>
      'Nmail and the protocol behind it are very young. Everything is built to work as well as possible, but bugs can happen and some things may feel slow or missing. Thanks for being an early supporter.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsBackgroundDefaultLabel => 'Default theme color';

  @override
  String get settingsBackgroundSelectLabel => 'Select background image';

  @override
  String get settingsBackgroundDeleteLabel => 'Delete background image';

  @override
  String get settingsBackgroundRemoveLabel => 'Remove background image';

  @override
  String get settingsBackgroundAddLabel => 'Add background image';

  @override
  String get settingsBackgroundDeleteTitle => 'Delete background';

  @override
  String get settingsBackgroundDeleteMessage =>
      'Remove this image from your saved backgrounds?';

  @override
  String get settingsBackgroundImageDeleted => 'Image deleted';

  @override
  String get settingsBackgroundDeleteFailed => 'Failed to delete image';

  @override
  String get settingsBackgroundDialogTitle => 'Background';

  @override
  String get settingsBackgroundSelectFile => 'Select file';

  @override
  String get settingsBackgroundPasteUrl => 'Paste URL';

  @override
  String get settingsBackgroundUrlTitle => 'Background URL';

  @override
  String get settingsBackgroundUrlHint => 'https://example.com/image.jpg';

  @override
  String get settingsBackgroundSet => 'Background set';

  @override
  String get settingsBackgroundImageSet => 'Image set';

  @override
  String get settingsBackgroundCopyFailed => 'Failed to copy image';

  @override
  String get settingsBackgroundUrlError =>
      'Image not accessible (CORS or network error)';

  @override
  String get settingsBackgroundDownloaded => 'Image downloaded';

  @override
  String get settingsBackgroundDownloadFailed => 'Failed to download image';

  @override
  String get settingsBackgroundUploadTitle => 'Upload image';

  @override
  String get settingsBackgroundUploadWarning =>
      'This image will be uploaded to Blossom servers. Server operators and anyone with the link can view it.';

  @override
  String get hostingRecommended => 'Recommended:';

  @override
  String hostingWillBeAddedAs(String url) {
    return 'Will be added as: $url';
  }

  @override
  String get relayAddTitle => 'Add Relay';

  @override
  String get relayUrlLabel => 'Relay URL';

  @override
  String get relayUrlHint => 'wss://relay.example.com';

  @override
  String get relayInvalidUrl => 'Invalid relay URL';

  @override
  String get relayDirection => 'Direction';

  @override
  String get relayReadWrite => 'Read & Write';

  @override
  String get relayRead => 'Read';

  @override
  String get relayWrite => 'Write';

  @override
  String get relayMarkerReadWrite => 'read/write';

  @override
  String get relayMarkerRead => 'read';

  @override
  String get relayMarkerWrite => 'write';

  @override
  String get relayInboxOutboxTitle => 'Inbox Outbox Relays';

  @override
  String get relayAddTooltip => 'Add relay';

  @override
  String get relayRemoveTooltip => 'Remove relay';

  @override
  String get relayInboxOutboxEmpty => 'No Inbox/Outbox relays configured';

  @override
  String get relayEmptyHint => 'Tap + to add a relay';

  @override
  String get dmRelayAddTitle => 'Add DM Relay';

  @override
  String get dmRelaySectionTitle => 'DM Relays';

  @override
  String get dmRelayEmpty => 'No DM relays configured';

  @override
  String get bridgeAddTitle => 'Add bridge';

  @override
  String get bridgeDomainLabel => 'Bridge domain';

  @override
  String get bridgeDomainHint => 'bridge.example.com';

  @override
  String get bridgeInvalidDomain => 'Invalid domain';

  @override
  String get bridgeSectionTitle => 'Bridges';

  @override
  String get bridgeAddTooltip => 'Add bridge';

  @override
  String get bridgeEmpty => 'No bridges configured';

  @override
  String get bridgeEmptyHint => 'Tap + to add a bridge';

  @override
  String get bridgeDefault => 'Default bridge';

  @override
  String get blossomAddTitle => 'Add Blossom Server';

  @override
  String get blossomServerUrlLabel => 'Server URL';

  @override
  String get blossomServerUrlHint => 'https://blossom.example.com';

  @override
  String get blossomInvalidUrl => 'Invalid server URL';

  @override
  String get blossomSectionTitle => 'File Hosting';

  @override
  String get blossomAddTooltip => 'Add server';

  @override
  String get blossomRemoveTooltip => 'Remove server';

  @override
  String get blossomEmpty => 'No Blossom servers configured';

  @override
  String get blossomEmptyHint => 'Tap + to add a server';

  @override
  String get connectivitySectionTitle => 'Realtime Connection';

  @override
  String get connectivityRelayConnectivity => 'Relay Connectivity';

  @override
  String get syncStatusSectionTitle => 'Sync Status';

  @override
  String get syncStatusEmpty => 'No sync data available';

  @override
  String get syncStatusEmptyHint => 'Sync your emails to see relay status';

  @override
  String get syncStatusResync => 'Resync';

  @override
  String get syncStatusBeginningOfTime => 'Beginning of time';

  @override
  String get identitiesTitle => 'Identities';

  @override
  String get identitiesEmptyTitle => 'No identities yet';

  @override
  String get identitiesEmptyMessage =>
      'Create one to send emails from a custom address.';

  @override
  String get identitiesCreate => 'Create identity';

  @override
  String get identitiesDiscardTitle => 'Discard changes?';

  @override
  String get identitiesDiscardMessage =>
      'You have unsaved changes. Leaving now will discard them.';

  @override
  String get identitiesKeepEditing => 'Keep editing';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsManage => 'Manage accounts';

  @override
  String get accountsManageSubtitle =>
      'Switch, add or remove accounts on this device';

  @override
  String get accountsActive => 'Active';

  @override
  String get accountsRemove => 'Remove account';

  @override
  String get accountsRemoveTitle => 'Remove this account?';

  @override
  String accountsRemoveMessage(String name) {
    return '$name will be removed from this device and its local data will be erased: emails, contacts and settings. Nothing is deleted from the relays.';
  }

  @override
  String get accountsRemoveKeyWarning =>
      'Save this account\'s sync code first. Without it you will not be able to log in again.';

  @override
  String get accountsRemoveLastWarning =>
      'This is your last account, so you will be logged out.';

  @override
  String get accountsRemoveFailed => 'Could not remove this account';

  @override
  String get accountSignerPrivateKey => 'Sync code';

  @override
  String get accountSignerExtension => 'Browser extension';

  @override
  String get accountSignerApp => 'Signer app';

  @override
  String get accountSignerBunker => 'Remote signer';

  @override
  String get accountSignerExternal => 'External signer';

  @override
  String get debugToolsEmailTesting => 'Email Testing';

  @override
  String get debugToolsCreateOldTrashed => 'Create Old Trashed Email';

  @override
  String get debugToolsCreateOldTrashedDescription =>
      'Creates a test email in trash that is 31 days old. Use this to test the \"Delete old emails\" feature.';

  @override
  String get debugToolsTriggerNotification => 'Trigger Test Notification';

  @override
  String get debugToolsTriggerNotificationDescription =>
      'Shows a local notification as if a new email had arrived, to test notification display and tap handling.';

  @override
  String get debugNotificationPermissionDenied =>
      'Notification permission denied.';

  @override
  String get folderInbox => 'Inbox';

  @override
  String get folderSent => 'Sent';

  @override
  String get folderTrash => 'Trash';

  @override
  String get folderArchive => 'Archive';

  @override
  String get folderScheduled => 'Scheduled';

  @override
  String get inboxEmptyInbox => 'No emails yet';

  @override
  String get inboxEmptySent => 'No sent emails';

  @override
  String get inboxEmptyTrash => 'Trash is empty';

  @override
  String get inboxEmptyArchive => 'Archive is empty';

  @override
  String get inboxSyncFromRelays => 'Sync from relays';

  @override
  String get inboxSearch => 'Search';

  @override
  String get inboxSync => 'Sync';

  @override
  String get inboxMenu => 'Menu';

  @override
  String get inboxClearSelection => 'Clear selection';

  @override
  String inboxSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get inboxProfile => 'Profile';

  @override
  String get inboxCopyNpub => 'Copy npub';

  @override
  String get inboxAddAccount => 'Add account';

  @override
  String get inboxLogout => 'Logout';

  @override
  String get inboxAccount => 'Account';

  @override
  String get inboxCompose => 'Compose';

  @override
  String get inboxNpubCopied => 'npub copied';

  @override
  String get inboxUnknown => 'Unknown';

  @override
  String get inboxEditProfile => 'Edit profile';

  @override
  String get inboxSettings => 'Settings';

  @override
  String get inboxDeleteOldEmailsTitle => 'Delete old emails';

  @override
  String inboxDeleteOldEmailsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count emails',
      one: '$count email',
    );
    return 'This will permanently delete $_temp0 older than 30 days.\n\nThis action cannot be undone.';
  }

  @override
  String get inboxDeleteFailed => 'Delete failed';

  @override
  String inboxDeleteFailedDescription(String error) {
    return 'Failed to delete old emails: $error';
  }

  @override
  String inboxOldEmailsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count old emails to delete',
      one: '$count old email to delete',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeleteNow => 'Delete now';

  @override
  String get inboxDeleteOldEmailsTooltip => 'Delete old emails';

  @override
  String get inboxSearchHint => 'Search all emails...';

  @override
  String get inboxCloseSearch => 'Close search';

  @override
  String get inboxSelectAll => 'Select all';

  @override
  String get inboxMoreActions => 'More actions';

  @override
  String get emailReply => 'Reply';

  @override
  String get emailForward => 'Forward';

  @override
  String get emailArchive => 'Archive';

  @override
  String get emailUnarchive => 'Unarchive';

  @override
  String get emailMarkAsRead => 'Mark as read';

  @override
  String get emailMarkAsUnread => 'Mark as unread';

  @override
  String get emailMoveToTrash => 'Move to trash';

  @override
  String get emailRestore => 'Restore';

  @override
  String get emailDeletePermanently => 'Delete permanently';

  @override
  String get emailNoSubject => '(No subject)';

  @override
  String emailExtraRecipients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more recipients',
      one: '$count more recipient',
    );
    return '$_temp0';
  }

  @override
  String get emailNotFound => 'Email not found';

  @override
  String emailSenderNpub(String npub) {
    return 'Sender npub: $npub';
  }

  @override
  String get emailDeletePermanentlyTitle => 'Delete permanently?';

  @override
  String get emailDeletePermanentlyMessage => 'This action cannot be undone.';

  @override
  String get emailDefaultFilename => 'email';

  @override
  String emailSaved(String path) {
    return 'Email saved: $path';
  }

  @override
  String emailSaveFailed(String error) {
    return 'Failed to save email: $error';
  }

  @override
  String get emailRawContentUnavailable => 'Email content could not be loaded';

  @override
  String get emailRepostFailedEvent => 'Failed to get email event for repost';

  @override
  String get emailRepostSuccess => 'Email reposted successfully';

  @override
  String emailRepostFailed(String error) {
    return 'Failed to repost email: $error';
  }

  @override
  String get emailAttachmentLoadFailed => 'Failed to load attachment';

  @override
  String get emailFileSaved => 'Attachment saved to Downloads';

  @override
  String emailFileSaveFailed(String error) {
    return 'Failed to save file: $error';
  }

  @override
  String emailDownloadedAllSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Downloaded $count files successfully',
      one: 'Downloaded $count file successfully',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Failed to download $count files',
      one: 'Failed to download $count file',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedMixed(int success, int failed) {
    return 'Downloaded $success files, $failed failed';
  }

  @override
  String get emailDownload => 'Download';

  @override
  String get emailImageLoadFailed => 'Failed to load image';

  @override
  String get emailPdfLoadFailed => 'Failed to load PDF';

  @override
  String get emailActionReply => 'Reply';

  @override
  String get emailActionReplyAll => 'Reply all';

  @override
  String get emailActionForward => 'Forward';

  @override
  String get emailActionArchive => 'Archive';

  @override
  String get emailActionUnarchive => 'Unarchive';

  @override
  String get emailActionMarkRead => 'Mark read';

  @override
  String get emailActionMarkUnread => 'Mark unread';

  @override
  String get emailActionNip59 => 'NIP-59 Events';

  @override
  String get emailActionRepost => 'Repost';

  @override
  String get emailActionDownload => 'Download email';

  @override
  String get emailActionViewSource => 'View source';

  @override
  String get emailMoreActions => 'More actions';

  @override
  String get emailMoreOptions => 'More options';

  @override
  String get emailShowRecipients => 'Show recipients';

  @override
  String get emailImagesHidden => 'Images are hidden for privacy';

  @override
  String get emailLoadImages => 'Load images';

  @override
  String get emailRecipientTo => 'To';

  @override
  String get emailRecipientCc => 'Cc';

  @override
  String get emailRecipientBcc => 'Bcc';

  @override
  String get emailAttachmentsTitle => 'Attachments';

  @override
  String get emailDownloadAll => 'Download all';

  @override
  String get emailNip59Dismiss => 'Dismiss';

  @override
  String get emailNip59Title => 'NIP-59 Events';

  @override
  String get emailNip59GiftWrap => 'Gift Wrap';

  @override
  String get emailNip59Seal => 'Seal';

  @override
  String get emailNip59Rumor => 'Rumor';

  @override
  String get emailNip59CopyJson => 'Copy JSON';

  @override
  String emailNip59Kind(int kind) {
    return 'Kind $kind';
  }

  @override
  String get emailNip59NotAvailable => 'Not available';

  @override
  String get authHeaderTitle => 'Log in to Nmail';

  @override
  String get authSyncCodeLabel => 'Sync code';

  @override
  String get authInvalidSyncCode => 'Invalid sync code';

  @override
  String get authInvalidSyncCodeDescription =>
      'We\'re checking your code as you type. Once valid, you\'ll be signed in without having to click anything.';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authMoreOptions => 'More options';

  @override
  String get authRegisterPrompt => 'What should others see?';

  @override
  String get authDisplayNameLabel => 'Display Name';

  @override
  String get authDisplayNameHint => 'e.g. Alice';

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get authUnableRetrieveCode => 'Unable to retrieve sync code';

  @override
  String get authYourSyncCode => 'Your Sync Code';

  @override
  String get authSyncCodeIntro =>
      'This code is the key to your account. It gives you full control and lets you:';

  @override
  String get authSyncCodeFeatureRestore => 'Restore your account on any device';

  @override
  String get authSyncCodeFeatureBackup => 'Back up your identity securely';

  @override
  String get authSyncCodeFeatureLogin => 'Log in to other Nostr apps';

  @override
  String get authSyncCodeWarning =>
      'Never share this code with anyone. Store it in a safe place. You can always find it later in Settings.';

  @override
  String get authCopied => 'Copied!';

  @override
  String get authCopySyncCode => 'Copy Sync Code';

  @override
  String get authContinueToInbox => 'Continue to Inbox';

  @override
  String get composeTitle => 'Compose';

  @override
  String get composeTo => 'To';

  @override
  String get composeAddMore => 'Add more';

  @override
  String get composeHideExpanded => 'Hide CC/BCC/From';

  @override
  String get composeShowExpanded => 'Show CC/BCC/From';

  @override
  String get composeExpandedFieldsButtonLabel => 'Cc, From';

  @override
  String get composeCc => 'Cc';

  @override
  String get composeBcc => 'Bcc';

  @override
  String get composeSubject => 'Subject';

  @override
  String get composeAttachFile => 'Attach file';

  @override
  String get composePlaceholder => 'Compose email';

  @override
  String get composeFrom => 'From';

  @override
  String get composeSendAs => 'Send as';

  @override
  String get composeCreateNewIdentity => 'Create new identity';

  @override
  String get composeRemoveAttachment => 'Remove attachment';

  @override
  String get composeSend => 'Send';

  @override
  String get composeMoreSendOptions => 'More send options';

  @override
  String get composeChooseSendMode => 'Choose send mode';

  @override
  String get composeModePrivateDeniable => 'Private deniable';

  @override
  String get composeModePrivateSigned => 'Private signed';

  @override
  String get composeModePublic => 'Public';

  @override
  String get composeModePrivateDeniableDescription =>
      'Send as encrypted email. No signature - deniable if needed.';

  @override
  String get composeModePrivateSignedDescription =>
      'Send as encrypted email. Signed - proves you\'re the author.';

  @override
  String get composeModePublicDescription =>
      'Send as a public event. Anyone can read this. No encryption.';

  @override
  String get composeResolvingNip05 => 'Resolving NIP-05...';

  @override
  String get contactSourceAddressBook => 'Address book';

  @override
  String get contactSourceEmailHistory => 'Email history';

  @override
  String get contactSourceFollowing => 'Following';

  @override
  String get contactSourceCachedProfile => 'Cached profile';

  @override
  String get contactSourceNip05Verified => 'NIP-05 verified';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsAdd => 'Add contact';

  @override
  String get contactsAddToContacts => 'Add to contacts';

  @override
  String get contactsSync => 'Sync contacts';

  @override
  String get contactsRetry => 'Retry pending contact updates';

  @override
  String get contactsSearchHint => 'Search contacts';

  @override
  String get contactsEmpty => 'No contacts yet';

  @override
  String get contactsSearchEmpty => 'No matching contacts';

  @override
  String get contactsSelectPrompt => 'Select a contact';

  @override
  String get contactsCreateTitle => 'New contact';

  @override
  String get contactsEditTitle => 'Edit contact';

  @override
  String get contactsNameLabel => 'Name';

  @override
  String get contactsEmailsLabel => 'Email addresses';

  @override
  String get contactsMultilineHint => 'One per line';

  @override
  String get contactsAddEmailHint => 'Add email address';

  @override
  String get contactsPhonesLabel => 'Phone numbers';

  @override
  String get contactsAddPhoneHint => 'Add phone number';

  @override
  String get contactsBirthdayLabel => 'Birthday';

  @override
  String get contactsBirthdayAdd => 'Add birthday';

  @override
  String get contactsBirthdayDayLabel => 'Day';

  @override
  String get contactsBirthdayMonthLabel => 'Month';

  @override
  String get contactsBirthdayYearLabel => 'Year';

  @override
  String get contactsBirthdayHint => 'YYYY-MM-DD';

  @override
  String get contactsNostrLabel => 'Nostr identities';

  @override
  String get contactsNostrHint => 'npub, nprofile, hex pubkey, or NIP-05';

  @override
  String get contactsAddNostrHint =>
      'Add npub, nprofile, hex pubkey, or NIP-05';

  @override
  String get contactsCancel => 'Cancel';

  @override
  String get contactsSave => 'Save';

  @override
  String get contactsEdit => 'Edit contact';

  @override
  String get contactsCopyVCard => 'Copy vCard';

  @override
  String get contactsVCardCopied => 'vCard copied';

  @override
  String get contactsDelete => 'Delete';

  @override
  String get contactsDeleteTitle => 'Delete contact?';

  @override
  String get contactsDeleteBody =>
      'This removes the contact from your private address book.';

  @override
  String get contactsEmailsTitle => 'Email';

  @override
  String get contactsPhonesTitle => 'Phone';

  @override
  String get contactsBirthdayTitle => 'Birthday';

  @override
  String get contactsNostrTitle => 'Nostr';

  @override
  String get contactsCall => 'Call';

  @override
  String get contactsSendSms => 'Send SMS';

  @override
  String get contactsImport => 'Import contacts';

  @override
  String get contactsExport => 'Export contacts';

  @override
  String get contactsExportEmpty => 'No contacts to export';

  @override
  String contactsExportSaved(String path) {
    return 'Contacts exported: $path';
  }

  @override
  String contactsExportFailed(String error) {
    return 'Failed to export contacts: $error';
  }

  @override
  String get contactsImportEmpty => 'No contacts found in the file';

  @override
  String contactsImportFailed(String error) {
    return 'Failed to import contacts: $error';
  }

  @override
  String contactsImportSummary(int imported, int skipped) {
    return '$imported imported, $skipped skipped';
  }

  @override
  String get contactsImportConflictTitle => 'Contacts already present';

  @override
  String contactsImportConflictBody(int count) {
    return '$count of the imported contacts already exist. How should they be handled?';
  }

  @override
  String get contactsImportMergeAll => 'Merge all';

  @override
  String get contactsImportReplaceAll => 'Replace all';

  @override
  String get contactsImportSkip => 'Skip duplicates';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileDisplayNameLabel => 'Display Name';

  @override
  String get profileDisplayNameHint => 'Your full name or alias';

  @override
  String get profileUsernameLabel => 'Username';

  @override
  String get profileUsernameHint => 'handle';

  @override
  String get profileAboutLabel => 'About';

  @override
  String get profileAboutHint => 'A short bio about yourself';

  @override
  String get profileAdvanced => 'Advanced';

  @override
  String get profilePictureUrlLabel => 'Picture URL';

  @override
  String get profilePictureUrlHint => 'https://example.com/avatar.png';

  @override
  String get profileChangePicture => 'Change profile picture';

  @override
  String get onboardingPage1Title => 'Welcome to Nmail';

  @override
  String get onboardingPage1Body =>
      'Discover a decentralized email experience that puts you in control. A new way to communicate, centered around you.';

  @override
  String get onboardingPage2Title => 'A Network Without Masters';

  @override
  String get onboardingPage2Body =>
      'Your messages flow through a global network of independent servers. No single company owns your inbox.';

  @override
  String get onboardingPage3Title => 'Freedom of Choice';

  @override
  String get onboardingPage3Body =>
      'You are never locked into a single provider. Switch bridges or relays at any time without ever losing your identity or contacts.';

  @override
  String get onboardingPage4Title => 'One Identity for Everything';

  @override
  String get onboardingPage4Body =>
      'Use your account to send emails, follow profiles, or use other apps. It\'s one permanent identity that works across many different applications.';

  @override
  String get onboardingPage5Title => 'Built for the Future';

  @override
  String get onboardingPage5Body =>
      'Benefit from a modern architecture designed for privacy. Nmail helps you transition smoothly to a more secure and resilient way of communicating.';

  @override
  String get onboardingPage6Title => 'Early Access';

  @override
  String get onboardingPage6Body =>
      'Nmail and the protocol behind it are very young. Everything is built to work as well as possible, but bugs can happen and some things may feel slow or missing. Thanks for being an early supporter. Your patience helps shape what comes next.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Done';

  @override
  String get createIdentityTitle => 'Create Identity';

  @override
  String get createIdentityAddress => 'Address';

  @override
  String get createIdentityCustomUsername => 'Custom username';

  @override
  String get createIdentityBridge => 'Bridge';

  @override
  String get createIdentityNoBridges => 'No bridges available';

  @override
  String get createIdentityBridgeHint => 'bridge.com';

  @override
  String get createIdentityPreview => 'Preview';

  @override
  String get createIdentityPreviewEmpty =>
      'Enter an address and select a bridge to see preview';

  @override
  String get createIdentityAlreadyExists => 'This identity already exists';

  @override
  String get leftRailSettings => 'Settings';

  @override
  String get linkOpenTitle => 'Open link?';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get debugNotAuthenticated => 'Not authenticated';

  @override
  String get debugTestEmailCreated =>
      'Created and trashed test email (31 days old)';

  @override
  String get debugTestEmailPartial =>
      'Email created and trashed, but could not update timestamp';

  @override
  String debugError(String error) {
    return 'Error: $error';
  }

  @override
  String get composeSelectAttachments => 'Select Attachments';

  @override
  String composePickFilesFailed(String error) {
    return 'Failed to pick files: $error';
  }

  @override
  String get composeInvalidRecipient => 'Invalid recipient format';

  @override
  String get composeAddRecipient => 'Add at least one recipient';

  @override
  String get composeSendFailed => 'Failed to send email';

  @override
  String get composeScheduleSend => 'Schedule send';

  @override
  String get composeScheduleClear => 'Remove schedule';

  @override
  String get composeScheduleTimePast => 'Pick a time in the future';

  @override
  String get composeScheduleFailed => 'Failed to schedule email';

  @override
  String get scheduledEmpty => 'No scheduled emails';

  @override
  String scheduledSendsAt(String time) {
    return 'Sends $time';
  }

  @override
  String get scheduledCancel => 'Cancel send';

  @override
  String get scheduledCancelFailed => 'Failed to cancel scheduled email';

  @override
  String get scheduledStatusSent => 'Sent';

  @override
  String get scheduledStatusFailed => 'Failed';

  @override
  String get scheduledStatusError => 'Rejected';

  @override
  String get profileLoadFailed => 'Failed to load profile data';

  @override
  String get profileSelectPicture => 'Select profile picture';

  @override
  String get profileUploadNoServers => 'No servers responded';

  @override
  String get profileUploadFailed => 'Upload failed';

  @override
  String get profileUploadError => 'An error occurred during upload';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get authEnterUsername => 'Please enter a username';

  @override
  String createIdentityFailed(String error) {
    return 'Failed to create identity: $error';
  }

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBackToInbox => 'Back to inbox';
}
