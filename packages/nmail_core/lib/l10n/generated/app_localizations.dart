import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Generic Cancel button label, used in dialogs and forms
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Generic Save button label, used to commit edits
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Generic Delete button label, used in destructive dialogs
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Generic Add button label, used in dialogs to confirm adding an item
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Generic clear action label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Generic Close button/tooltip label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Continue button label used to advance a flow (e.g. registration)
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Generic Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// Generic Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// Generic OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Generic Copy button label, e.g. copy a link or value to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// Generic Open button label, used to confirm opening an external link
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// Generic Upload button label used to confirm an upload action
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get actionUpload;

  /// Reset button label used in destructive reset dialogs
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// Undo button/tooltip used to revert a pending deletion
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// Generic Remove tooltip/label for removing list items
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// Discard button label used when leaving a form with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// Loading state label without trailing punctuation
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get stateLoading;

  /// Loading state label with ellipsis, used in list tiles and progress dialogs
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get stateLoadingEllipsis;

  /// Progress label shown while resetting the application
  ///
  /// In en, this message translates to:
  /// **'Resetting...'**
  String get stateResetting;

  /// Progress label shown while validating an image URL
  ///
  /// In en, this message translates to:
  /// **'Validating...'**
  String get stateValidating;

  /// Progress label shown while downloading an image
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get stateDownloading;

  /// Progress label shown while uploading an image
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get stateUploading;

  /// Title of the Settings screen and drawer entry
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header for theme and background options
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Settings switch title: derive theme colors from the background image
  ///
  /// In en, this message translates to:
  /// **'Dynamic theme'**
  String get settingsDynamicTheme;

  /// Subtitle explaining the dynamic theme switch
  ///
  /// In en, this message translates to:
  /// **'Generate colors from background image'**
  String get settingsDynamicThemeSubtitle;

  /// Settings tile title for the app language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language picker option that follows the device language
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// Title of the dialog that lets the user pick the app language
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get settingsLanguageDialogTitle;

  /// Settings section header for notification options
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Toggle label to enable OS notifications for new emails
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get settingsEnableNotifications;

  /// Helper text under the enable-notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new email arrives.'**
  String get settingsEnableNotificationsSubtitle;

  /// Settings tile title that opens the notifications settings screen
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get settingsManageNotifications;

  /// Subtitle for the manage notifications tile
  ///
  /// In en, this message translates to:
  /// **'Alerts for new emails'**
  String get settingsManageNotificationsSubtitle;

  /// Settings tile title shown on Android FOSS builds when no UnifiedPush distributor is installed
  ///
  /// In en, this message translates to:
  /// **'Push notifications unavailable'**
  String get settingsUnifiedPushDistributorMissingTitle;

  /// Settings tile subtitle explaining that a UnifiedPush distributor is required for push notifications
  ///
  /// In en, this message translates to:
  /// **'Install a UnifiedPush distributor like Sunup to receive notifications in the background.'**
  String get settingsUnifiedPushDistributorMissingSubtitle;

  /// Button label opening the Sunup UnifiedPush distributor install page
  ///
  /// In en, this message translates to:
  /// **'Install Sunup'**
  String get settingsUnifiedPushDistributorInstallSunup;

  /// Settings section header for advanced/developer toggles
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get settingsAdvancedOptions;

  /// Settings switch title: expose raw email source view
  ///
  /// In en, this message translates to:
  /// **'Show email source code'**
  String get settingsShowEmailSource;

  /// Subtitle for the email source code switch
  ///
  /// In en, this message translates to:
  /// **'Adds a button to view raw email'**
  String get settingsShowEmailSourceSubtitle;

  /// Settings switch title controlling automatic image loading in emails
  ///
  /// In en, this message translates to:
  /// **'Always load images'**
  String get settingsAlwaysLoadImages;

  /// Subtitle explaining why images are blocked by default
  ///
  /// In en, this message translates to:
  /// **'Images are blocked by default for privacy'**
  String get settingsAlwaysLoadImagesSubtitle;

  /// Settings section header and identities screen title
  ///
  /// In en, this message translates to:
  /// **'Identities'**
  String get settingsIdentities;

  /// Settings tile title that opens the identities management screen
  ///
  /// In en, this message translates to:
  /// **'Manage identities'**
  String get settingsManageIdentities;

  /// Subtitle for the manage identities tile
  ///
  /// In en, this message translates to:
  /// **'Add, remove or reorder addresses'**
  String get settingsManageIdentitiesSubtitle;

  /// Settings section header for compose-related options (signature, etc.)
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get settingsCompose;

  /// Settings tile title and dialog title for editing the email signature
  ///
  /// In en, this message translates to:
  /// **'Email signature'**
  String get settingsEmailSignature;

  /// Subtitle shown when no email signature is configured
  ///
  /// In en, this message translates to:
  /// **'No signature configured'**
  String get settingsEmailSignatureEmpty;

  /// Placeholder text in the email signature input
  ///
  /// In en, this message translates to:
  /// **'Enter your signature...'**
  String get settingsEmailSignatureHint;

  /// Settings section header for sync/hosting options
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get settingsSynchronization;

  /// Settings tile and screen title for relays/blossom/bridges
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get settingsHosting;

  /// Subtitle for the hosting settings tile
  ///
  /// In en, this message translates to:
  /// **'Relays, blossom servers, connectivity'**
  String get settingsHostingSubtitle;

  /// Debug tools tile/screen title (debug builds only)
  ///
  /// In en, this message translates to:
  /// **'Debug Tools'**
  String get settingsDebugTools;

  /// Subtitle for the debug tools tile
  ///
  /// In en, this message translates to:
  /// **'Testing and development features'**
  String get settingsDebugToolsSubtitle;

  /// Settings section header for account actions
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Settings tile title to copy the user's sync code (nsec) to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy sync code'**
  String get settingsCopySyncCode;

  /// Subtitle explaining what the sync code is for
  ///
  /// In en, this message translates to:
  /// **'Use this code to sync your account on other devices'**
  String get settingsCopySyncCodeSubtitle;

  /// Toast confirmation after the sync code is copied
  ///
  /// In en, this message translates to:
  /// **'Sync code copied'**
  String get settingsSyncCodeCopied;

  /// Log out tile label in settings
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogOut;

  /// Destructive tile title and confirmation dialog title for resetting the app
  ///
  /// In en, this message translates to:
  /// **'Reset application'**
  String get settingsResetApplication;

  /// Subtitle for the reset application tile
  ///
  /// In en, this message translates to:
  /// **'Delete all local data'**
  String get settingsResetApplicationSubtitle;

  /// Confirmation message shown before resetting the application
  ///
  /// In en, this message translates to:
  /// **'This will delete all local data including settings, background images, and log you out.\n\nThis action cannot be undone.'**
  String get settingsResetConfirmMessage;

  /// Settings section header for app info (version, source code)
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Tile title for the app version in the About section
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// Tile title for the link to the project's GitHub repository
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get settingsSourceCode;

  /// Subtitle for the source code tile, hinting that tapping opens GitHub
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get settingsSourceCodeSubtitle;

  /// Tile title for the Apple App Store privacy policy link in the About section
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// Subtitle for the Apple App Store privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Apple App Store privacy details'**
  String get settingsPrivacyPolicySubtitle;

  /// Tile title in the About section warning that the app is in early development
  ///
  /// In en, this message translates to:
  /// **'Early access'**
  String get settingsEarlyAccess;

  /// Subtitle/body for the early-access tile in About, setting expectations about bugs and missing features
  ///
  /// In en, this message translates to:
  /// **'Nmail and the protocol behind it are very young. Everything is built to work as well as possible, but bugs can happen and some things may feel slow or missing. Thanks for being an early supporter.'**
  String get settingsEarlyAccessMessage;

  /// Tile title for the theme mode selector (Auto/Light/Dark)
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme mode option: follow system
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsThemeAuto;

  /// Theme mode option: light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme mode option: dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Accessibility label for the default-color background swatch in the gallery
  ///
  /// In en, this message translates to:
  /// **'Default theme color'**
  String get settingsBackgroundDefaultLabel;

  /// Accessibility label for tapping a saved background image to select it
  ///
  /// In en, this message translates to:
  /// **'Select background image'**
  String get settingsBackgroundSelectLabel;

  /// Accessibility label for the small delete button on a saved background thumbnail
  ///
  /// In en, this message translates to:
  /// **'Delete background image'**
  String get settingsBackgroundDeleteLabel;

  /// Accessibility label for the currently selected web background image (clears it)
  ///
  /// In en, this message translates to:
  /// **'Remove background image'**
  String get settingsBackgroundRemoveLabel;

  /// Accessibility label for the + button that adds a new background image
  ///
  /// In en, this message translates to:
  /// **'Add background image'**
  String get settingsBackgroundAddLabel;

  /// Dialog title when confirming deletion of a saved background image
  ///
  /// In en, this message translates to:
  /// **'Delete background'**
  String get settingsBackgroundDeleteTitle;

  /// Confirmation message for deleting a saved background image
  ///
  /// In en, this message translates to:
  /// **'Remove this image from your saved backgrounds?'**
  String get settingsBackgroundDeleteMessage;

  /// Toast shown after a saved background image is deleted
  ///
  /// In en, this message translates to:
  /// **'Image deleted'**
  String get settingsBackgroundImageDeleted;

  /// Error toast shown when deleting a saved background image fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete image'**
  String get settingsBackgroundDeleteFailed;

  /// Dialog title for choosing how to add a background (file vs URL)
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get settingsBackgroundDialogTitle;

  /// Option in the background dialog to pick a local file
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get settingsBackgroundSelectFile;

  /// Option in the background dialog to paste an image URL
  ///
  /// In en, this message translates to:
  /// **'Paste URL'**
  String get settingsBackgroundPasteUrl;

  /// Dialog title for entering a background image URL
  ///
  /// In en, this message translates to:
  /// **'Background URL'**
  String get settingsBackgroundUrlTitle;

  /// Placeholder example URL in the background URL input
  ///
  /// In en, this message translates to:
  /// **'https://example.com/image.jpg'**
  String get settingsBackgroundUrlHint;

  /// Toast shown after a web image URL has been validated and applied as background
  ///
  /// In en, this message translates to:
  /// **'Background set'**
  String get settingsBackgroundSet;

  /// Toast shown after a local image file has been copied and applied as background
  ///
  /// In en, this message translates to:
  /// **'Image set'**
  String get settingsBackgroundImageSet;

  /// Error toast when copying a picked image into local storage fails
  ///
  /// In en, this message translates to:
  /// **'Failed to copy image'**
  String get settingsBackgroundCopyFailed;

  /// Error toast when a background image URL cannot be loaded due to network/CORS issues
  ///
  /// In en, this message translates to:
  /// **'Image not accessible (CORS or network error)'**
  String get settingsBackgroundUrlError;

  /// Toast shown after a background image has been downloaded and applied
  ///
  /// In en, this message translates to:
  /// **'Image downloaded'**
  String get settingsBackgroundDownloaded;

  /// Error toast when downloading a background image fails
  ///
  /// In en, this message translates to:
  /// **'Failed to download image'**
  String get settingsBackgroundDownloadFailed;

  /// Dialog title warning before uploading a background image to Blossom servers
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get settingsBackgroundUploadTitle;

  /// Warning text shown before uploading a background image to public Blossom servers
  ///
  /// In en, this message translates to:
  /// **'This image will be uploaded to Blossom servers. Server operators and anyone with the link can view it.'**
  String get settingsBackgroundUploadWarning;

  /// Title above recommendation chips in relay/bridge/blossom sections
  ///
  /// In en, this message translates to:
  /// **'Recommended:'**
  String get hostingRecommended;

  /// Preview shown below the URL input when the entered value will be normalized (e.g. wss:// prepended)
  ///
  /// In en, this message translates to:
  /// **'Will be added as: {url}'**
  String hostingWillBeAddedAs(String url);

  /// Dialog title for adding a NIP-65 inbox/outbox relay
  ///
  /// In en, this message translates to:
  /// **'Add Relay'**
  String get relayAddTitle;

  /// Input label for a relay URL
  ///
  /// In en, this message translates to:
  /// **'Relay URL'**
  String get relayUrlLabel;

  /// Placeholder example for a relay URL input
  ///
  /// In en, this message translates to:
  /// **'wss://relay.example.com'**
  String get relayUrlHint;

  /// Error message shown when a relay URL fails validation
  ///
  /// In en, this message translates to:
  /// **'Invalid relay URL'**
  String get relayInvalidUrl;

  /// Label above the read/write direction selector for a relay
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get relayDirection;

  /// Direction option: relay used for both reading and writing
  ///
  /// In en, this message translates to:
  /// **'Read & Write'**
  String get relayReadWrite;

  /// Direction option: read-only relay
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get relayRead;

  /// Direction option: write-only relay
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get relayWrite;

  /// Inline marker below a relay row showing it is read/write
  ///
  /// In en, this message translates to:
  /// **'read/write'**
  String get relayMarkerReadWrite;

  /// Inline marker below a relay row showing it is read-only
  ///
  /// In en, this message translates to:
  /// **'read'**
  String get relayMarkerRead;

  /// Inline marker below a relay row showing it is write-only
  ///
  /// In en, this message translates to:
  /// **'write'**
  String get relayMarkerWrite;

  /// Section header for NIP-65 inbox/outbox relays
  ///
  /// In en, this message translates to:
  /// **'Inbox Outbox Relays'**
  String get relayInboxOutboxTitle;

  /// Tooltip on the + icon used to add a relay
  ///
  /// In en, this message translates to:
  /// **'Add relay'**
  String get relayAddTooltip;

  /// Tooltip on the X icon used to mark a relay for deletion
  ///
  /// In en, this message translates to:
  /// **'Remove relay'**
  String get relayRemoveTooltip;

  /// Empty-state message shown when no NIP-65 relays are configured
  ///
  /// In en, this message translates to:
  /// **'No Inbox/Outbox relays configured'**
  String get relayInboxOutboxEmpty;

  /// Helper text below empty-state messages instructing the user to add a relay
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a relay'**
  String get relayEmptyHint;

  /// Dialog title for adding a NIP-17 DM relay
  ///
  /// In en, this message translates to:
  /// **'Add DM Relay'**
  String get dmRelayAddTitle;

  /// Section header for DM (direct message) relays
  ///
  /// In en, this message translates to:
  /// **'DM Relays'**
  String get dmRelaySectionTitle;

  /// Empty-state message shown when no DM relays are configured
  ///
  /// In en, this message translates to:
  /// **'No DM relays configured'**
  String get dmRelayEmpty;

  /// Dialog title and IconButton tooltip for adding a bridge domain
  ///
  /// In en, this message translates to:
  /// **'Add bridge'**
  String get bridgeAddTitle;

  /// Input label for a bridge domain (e.g. uid.ovh)
  ///
  /// In en, this message translates to:
  /// **'Bridge domain'**
  String get bridgeDomainLabel;

  /// Placeholder example for the bridge domain input
  ///
  /// In en, this message translates to:
  /// **'bridge.example.com'**
  String get bridgeDomainHint;

  /// Error message shown when the bridge domain fails validation
  ///
  /// In en, this message translates to:
  /// **'Invalid domain'**
  String get bridgeInvalidDomain;

  /// Section header for bridges in the hosting settings
  ///
  /// In en, this message translates to:
  /// **'Bridges'**
  String get bridgeSectionTitle;

  /// Tooltip on the + icon used to add a bridge
  ///
  /// In en, this message translates to:
  /// **'Add bridge'**
  String get bridgeAddTooltip;

  /// Empty-state message shown when no bridges are configured
  ///
  /// In en, this message translates to:
  /// **'No bridges configured'**
  String get bridgeEmpty;

  /// Helper text below the empty bridges state
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a bridge'**
  String get bridgeEmptyHint;

  /// Subtitle shown next to the bundled default bridge (uid.ovh)
  ///
  /// In en, this message translates to:
  /// **'Default bridge'**
  String get bridgeDefault;

  /// Dialog title for adding a Blossom file-hosting server
  ///
  /// In en, this message translates to:
  /// **'Add Blossom Server'**
  String get blossomAddTitle;

  /// Input label for a Blossom server URL
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get blossomServerUrlLabel;

  /// Placeholder example for a Blossom server URL
  ///
  /// In en, this message translates to:
  /// **'https://blossom.example.com'**
  String get blossomServerUrlHint;

  /// Error message shown when a Blossom server URL fails validation
  ///
  /// In en, this message translates to:
  /// **'Invalid server URL'**
  String get blossomInvalidUrl;

  /// Section header for Blossom file-hosting servers
  ///
  /// In en, this message translates to:
  /// **'File Hosting'**
  String get blossomSectionTitle;

  /// Tooltip on the + icon used to add a Blossom server
  ///
  /// In en, this message translates to:
  /// **'Add server'**
  String get blossomAddTooltip;

  /// Tooltip on the X icon used to mark a Blossom server for deletion
  ///
  /// In en, this message translates to:
  /// **'Remove server'**
  String get blossomRemoveTooltip;

  /// Empty-state message shown when no Blossom servers are configured
  ///
  /// In en, this message translates to:
  /// **'No Blossom servers configured'**
  String get blossomEmpty;

  /// Helper text below the empty Blossom servers state
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a server'**
  String get blossomEmptyHint;

  /// Section header for the live relay connectivity status block
  ///
  /// In en, this message translates to:
  /// **'Realtime Connection'**
  String get connectivitySectionTitle;

  /// Title inside the relay connectivity ExpansionTile
  ///
  /// In en, this message translates to:
  /// **'Relay Connectivity'**
  String get connectivityRelayConnectivity;

  /// Section header for per-relay email sync status
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatusSectionTitle;

  /// Empty-state message when no sync data exists yet
  ///
  /// In en, this message translates to:
  /// **'No sync data available'**
  String get syncStatusEmpty;

  /// Helper text below the empty sync state
  ///
  /// In en, this message translates to:
  /// **'Sync your emails to see relay status'**
  String get syncStatusEmptyHint;

  /// Button label that forces a fresh sync of all relays
  ///
  /// In en, this message translates to:
  /// **'Resync'**
  String get syncStatusResync;

  /// Sentinel label for a zero timestamp (i.e. sync started from the dawn of time)
  ///
  /// In en, this message translates to:
  /// **'Beginning of time'**
  String get syncStatusBeginningOfTime;

  /// AppBar title of the identities management screen
  ///
  /// In en, this message translates to:
  /// **'Identities'**
  String get identitiesTitle;

  /// Empty-state heading on the identities screen
  ///
  /// In en, this message translates to:
  /// **'No identities yet'**
  String get identitiesEmptyTitle;

  /// Empty-state body on the identities screen
  ///
  /// In en, this message translates to:
  /// **'Create one to send emails from a custom address.'**
  String get identitiesEmptyMessage;

  /// FAB tooltip and primary button label to create a new identity
  ///
  /// In en, this message translates to:
  /// **'Create identity'**
  String get identitiesCreate;

  /// Dialog title shown when leaving the identities screen with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get identitiesDiscardTitle;

  /// Message in the discard-changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leaving now will discard them.'**
  String get identitiesDiscardMessage;

  /// Button label to stay on the screen and continue editing
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get identitiesKeepEditing;

  /// AppBar title of the accounts management screen
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// Menu entry and settings tile that opens the accounts management screen
  ///
  /// In en, this message translates to:
  /// **'Manage accounts'**
  String get accountsManage;

  /// Subtitle of the settings tile that opens the accounts management screen
  ///
  /// In en, this message translates to:
  /// **'Switch, add or remove accounts on this device'**
  String get accountsManageSubtitle;

  /// Accessibility label on the checkmark marking the account in use
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get accountsActive;

  /// Tooltip of the button that removes an account from the device
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get accountsRemove;

  /// Title of the dialog confirming removal of an account
  ///
  /// In en, this message translates to:
  /// **'Remove this account?'**
  String get accountsRemoveTitle;

  /// Body of the dialog confirming removal of an account
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this device and its local data will be erased: emails, contacts and settings. Nothing is deleted from the relays.'**
  String accountsRemoveMessage(String name);

  /// Extra warning in the removal dialog when the account is backed by a private key
  ///
  /// In en, this message translates to:
  /// **'Save this account\'s sync code first. Without it you will not be able to log in again.'**
  String get accountsRemoveKeyWarning;

  /// Extra warning in the removal dialog when removing the only remaining account
  ///
  /// In en, this message translates to:
  /// **'This is your last account, so you will be logged out.'**
  String get accountsRemoveLastWarning;

  /// Error toast shown when removing an account fails
  ///
  /// In en, this message translates to:
  /// **'Could not remove this account'**
  String get accountsRemoveFailed;

  /// Badge on an account whose key is stored on this device
  ///
  /// In en, this message translates to:
  /// **'Sync code'**
  String get accountSignerPrivateKey;

  /// Badge on an account signing through a NIP-07 browser extension
  ///
  /// In en, this message translates to:
  /// **'Browser extension'**
  String get accountSignerExtension;

  /// Badge on an account signing through a NIP-55 signer app such as Amber
  ///
  /// In en, this message translates to:
  /// **'Signer app'**
  String get accountSignerApp;

  /// Badge on an account signing through a NIP-46 remote signer (bunker)
  ///
  /// In en, this message translates to:
  /// **'Remote signer'**
  String get accountSignerBunker;

  /// Badge on an account signing through an unrecognized external signer
  ///
  /// In en, this message translates to:
  /// **'External signer'**
  String get accountSignerExternal;

  /// Section heading in the debug tools screen for email-related test actions
  ///
  /// In en, this message translates to:
  /// **'Email Testing'**
  String get debugToolsEmailTesting;

  /// Button label to seed a test email that is 31 days old and trashed
  ///
  /// In en, this message translates to:
  /// **'Create Old Trashed Email'**
  String get debugToolsCreateOldTrashed;

  /// Helper text explaining the seed-old-email debug action
  ///
  /// In en, this message translates to:
  /// **'Creates a test email in trash that is 31 days old. Use this to test the \"Delete old emails\" feature.'**
  String get debugToolsCreateOldTrashedDescription;

  /// Button label to show a local notification simulating a newly arrived email
  ///
  /// In en, this message translates to:
  /// **'Trigger Test Notification'**
  String get debugToolsTriggerNotification;

  /// Helper text explaining the test-notification debug action
  ///
  /// In en, this message translates to:
  /// **'Shows a local notification as if a new email had arrived, to test notification display and tap handling.'**
  String get debugToolsTriggerNotificationDescription;

  /// Error shown when the OS or browser denied notification permission
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied.'**
  String get debugNotificationPermissionDenied;

  /// Folder name: Inbox (used in toolbar titles and drawer)
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get folderInbox;

  /// Folder name: Sent
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get folderSent;

  /// Folder name: Trash
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get folderTrash;

  /// Folder name: Archive
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get folderArchive;

  /// Folder name: Scheduled (emails queued for future delivery)
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get folderScheduled;

  /// Empty-state message when the inbox folder is empty
  ///
  /// In en, this message translates to:
  /// **'No emails yet'**
  String get inboxEmptyInbox;

  /// Empty-state message when the sent folder is empty
  ///
  /// In en, this message translates to:
  /// **'No sent emails'**
  String get inboxEmptySent;

  /// Empty-state message when the trash folder is empty
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get inboxEmptyTrash;

  /// Empty-state message when the archive folder is empty
  ///
  /// In en, this message translates to:
  /// **'Archive is empty'**
  String get inboxEmptyArchive;

  /// Button shown below empty-state to trigger a sync
  ///
  /// In en, this message translates to:
  /// **'Sync from relays'**
  String get inboxSyncFromRelays;

  /// Tooltip on the search icon in the inbox toolbar
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get inboxSearch;

  /// Tooltip on the sync icon in the inbox toolbar
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get inboxSync;

  /// Tooltip on the hamburger menu in the inbox (mobile)
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get inboxMenu;

  /// Tooltip on the X button that exits multi-select mode
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get inboxClearSelection;

  /// Label in the inbox toolbar showing how many emails are currently selected
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String inboxSelectedCount(int count);

  /// Account menu entry that opens the profile editor
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get inboxProfile;

  /// Account menu entry/Semantics label to copy the user's npub to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy npub'**
  String get inboxCopyNpub;

  /// Account menu entry that opens the login flow to add another account
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get inboxAddAccount;

  /// Account menu entry to log the user out
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get inboxLogout;

  /// Tooltip/Semantics label on the account avatar button
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get inboxAccount;

  /// FAB tooltip and drawer button to open the compose screen
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get inboxCompose;

  /// Toast confirmation shown after the user's npub is copied
  ///
  /// In en, this message translates to:
  /// **'npub copied'**
  String get inboxNpubCopied;

  /// Fallback display when the user's npub is unavailable
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get inboxUnknown;

  /// Semantics label on the avatar in the drawer that opens the profile editor
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get inboxEditProfile;

  /// Tooltip/drawer entry that opens the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get inboxSettings;

  /// Confirmation dialog title for permanently deleting old trashed emails
  ///
  /// In en, this message translates to:
  /// **'Delete old emails'**
  String get inboxDeleteOldEmailsTitle;

  /// Confirmation message for deleting old trashed emails. Plural-aware on `count`.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {count, plural, one{{count} email} other{{count} emails}} older than 30 days.\n\nThis action cannot be undone.'**
  String inboxDeleteOldEmailsMessage(int count);

  /// Toast title shown when bulk deletion of old emails fails
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get inboxDeleteFailed;

  /// Toast description appended to the delete-failed toast, includes the error message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete old emails: {error}'**
  String inboxDeleteFailedDescription(String error);

  /// Banner text shown in trash folder when old emails are eligible for cleanup. Plural-aware.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} old email to delete} other{{count} old emails to delete}}'**
  String inboxOldEmailsCount(int count);

  /// Button label on the old-emails banner (desktop layout)
  ///
  /// In en, this message translates to:
  /// **'Delete now'**
  String get inboxDeleteNow;

  /// Tooltip on the trash icon in the old-emails banner (compact layout)
  ///
  /// In en, this message translates to:
  /// **'Delete old emails'**
  String get inboxDeleteOldEmailsTooltip;

  /// Placeholder text in the inbox search field
  ///
  /// In en, this message translates to:
  /// **'Search all emails...'**
  String get inboxSearchHint;

  /// Tooltip on the X button that exits the search field
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get inboxCloseSearch;

  /// Action label in the selection toolbar to select every visible email
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get inboxSelectAll;

  /// Tooltip on the overflow (kebab) menu in the selection toolbar
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get inboxMoreActions;

  /// Email context-menu entry to reply
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get emailReply;

  /// Email context-menu entry to forward
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get emailForward;

  /// Email context-menu entry to archive
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get emailArchive;

  /// Email context-menu entry to move out of archive
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get emailUnarchive;

  /// Email context-menu entry to mark as read
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get emailMarkAsRead;

  /// Email context-menu entry to mark as unread
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get emailMarkAsUnread;

  /// Email context-menu entry to move to trash
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get emailMoveToTrash;

  /// Email context-menu entry to restore from trash/archive
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get emailRestore;

  /// Destructive context-menu entry that permanently deletes an email from trash
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get emailDeletePermanently;

  /// Placeholder shown when an email has no subject
  ///
  /// In en, this message translates to:
  /// **'(No subject)'**
  String get emailNoSubject;

  /// Semantics label on the +N badge over a sent-email avatar, announced by screen readers to indicate the count of additional recipients beyond the one whose avatar is shown
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} more recipient} other{{count} more recipients}}'**
  String emailExtraRecipients(int count);

  /// Error shown on the email screen when the email id does not resolve
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// Tooltip on the toggle that switches from raw view back to formatted view
  ///
  /// In en, this message translates to:
  /// **'Show formatted'**
  String get emailShowFormatted;

  /// Tooltip on the toggle that switches to raw email source view
  ///
  /// In en, this message translates to:
  /// **'Show raw'**
  String get emailShowRaw;

  /// Header above the raw email source, showing the sender's npub-encoded pubkey
  ///
  /// In en, this message translates to:
  /// **'Sender npub: {npub}'**
  String emailSenderNpub(String npub);

  /// Confirmation dialog title when permanently deleting an email from trash
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get emailDeletePermanentlyTitle;

  /// Confirmation message body when permanently deleting an email
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get emailDeletePermanentlyMessage;

  /// Fallback filename used when downloading an email without a subject
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get emailDefaultFilename;

  /// Toast shown after downloading an email to disk, includes the saved path
  ///
  /// In en, this message translates to:
  /// **'Email saved: {path}'**
  String emailSaved(String path);

  /// Error toast shown when downloading an email fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save email: {error}'**
  String emailSaveFailed(String error);

  /// Error toast when the raw MIME content can't be reconstructed for .eml download
  ///
  /// In en, this message translates to:
  /// **'Email content could not be loaded'**
  String get emailRawContentUnavailable;

  /// Error toast when the underlying rumor event can't be fetched for repost
  ///
  /// In en, this message translates to:
  /// **'Failed to get email event for repost'**
  String get emailRepostFailedEvent;

  /// Success toast after rebroadcasting an email
  ///
  /// In en, this message translates to:
  /// **'Email reposted successfully'**
  String get emailRepostSuccess;

  /// Error toast when reposting an email fails
  ///
  /// In en, this message translates to:
  /// **'Failed to repost email: {error}'**
  String emailRepostFailed(String error);

  /// Error toast when an attachment's bytes can't be decoded
  ///
  /// In en, this message translates to:
  /// **'Failed to load attachment'**
  String get emailAttachmentLoadFailed;

  /// Toast shown after saving an attachment to the default downloads folder
  ///
  /// In en, this message translates to:
  /// **'Attachment saved to Downloads'**
  String get emailFileSaved;

  /// Error toast when saving an attachment fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save file: {error}'**
  String emailFileSaveFailed(String error);

  /// Success toast after downloading all attachments. Plural-aware.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Downloaded {count} file successfully} other{Downloaded {count} files successfully}}'**
  String emailDownloadedAllSuccess(int count);

  /// Error toast when no attachments were saved. Plural-aware.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Failed to download {count} file} other{Failed to download {count} files}}'**
  String emailDownloadedAllFailed(int count);

  /// Info toast when downloading attachments partially succeeded
  ///
  /// In en, this message translates to:
  /// **'Downloaded {success} files, {failed} failed'**
  String emailDownloadedMixed(int success, int failed);

  /// Tooltip on the download icon in the image/PDF viewer
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get emailDownload;

  /// Error toast when an image attachment can't be displayed
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get emailImageLoadFailed;

  /// Error toast when a PDF attachment can't be displayed
  ///
  /// In en, this message translates to:
  /// **'Failed to load PDF'**
  String get emailPdfLoadFailed;

  /// Button label in the email actions bar for replying
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get emailActionReply;

  /// Button label in the email actions bar for reply-all
  ///
  /// In en, this message translates to:
  /// **'Reply all'**
  String get emailActionReplyAll;

  /// Button label in the email actions bar for forwarding
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get emailActionForward;

  /// Button label in the email actions bar for archiving
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get emailActionArchive;

  /// Button label in the email actions bar for unarchiving
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get emailActionUnarchive;

  /// Short button label to mark email as read (actions bar)
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get emailActionMarkRead;

  /// Short button label to mark email as unread (actions bar)
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get emailActionMarkUnread;

  /// Button label that opens the NIP-59 event-inspection dialog
  ///
  /// In en, this message translates to:
  /// **'NIP-59 Events'**
  String get emailActionNip59;

  /// Button label to rebroadcast an email's underlying event
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get emailActionRepost;

  /// Button label to download the email as a .eml file
  ///
  /// In en, this message translates to:
  /// **'Download email'**
  String get emailActionDownload;

  /// Tooltip on the overflow menu in the desktop email actions bar
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get emailMoreActions;

  /// Tooltip on the overflow menu in the mobile email actions bar
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get emailMoreOptions;

  /// Tooltip on the chevron that expands the recipients list in the email header
  ///
  /// In en, this message translates to:
  /// **'Show recipients'**
  String get emailShowRecipients;

  /// Banner shown above HTML email body when image loading is blocked
  ///
  /// In en, this message translates to:
  /// **'Images are hidden for privacy'**
  String get emailImagesHidden;

  /// Button label on the privacy banner to allow images for this email
  ///
  /// In en, this message translates to:
  /// **'Load images'**
  String get emailLoadImages;

  /// Recipients list header: To (primary recipients)
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get emailRecipientTo;

  /// Recipients list header: Cc (carbon copy)
  ///
  /// In en, this message translates to:
  /// **'Cc'**
  String get emailRecipientCc;

  /// Recipients list header: Bcc (blind carbon copy)
  ///
  /// In en, this message translates to:
  /// **'Bcc'**
  String get emailRecipientBcc;

  /// Section header above the attachment cards in the email body
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get emailAttachmentsTitle;

  /// Button label to download every attachment of the current email
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get emailDownloadAll;

  /// Barrier label for the NIP-59 events dialog (accessibility)
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get emailNip59Dismiss;

  /// Dialog title for the NIP-59 event inspector
  ///
  /// In en, this message translates to:
  /// **'NIP-59 Events'**
  String get emailNip59Title;

  /// Card label for the outermost NIP-59 layer (kind 1059). Technical Nostr term.
  ///
  /// In en, this message translates to:
  /// **'Gift Wrap'**
  String get emailNip59GiftWrap;

  /// Card label for the middle NIP-59 layer (kind 13). Technical Nostr term.
  ///
  /// In en, this message translates to:
  /// **'Seal'**
  String get emailNip59Seal;

  /// Card label for the innermost NIP-59 layer (the actual unsigned event). Technical Nostr term.
  ///
  /// In en, this message translates to:
  /// **'Rumor'**
  String get emailNip59Rumor;

  /// Button label to copy a NIP-59 event JSON to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get emailNip59CopyJson;

  /// Chip label showing the Nostr event kind number (e.g. "Kind 1059")
  ///
  /// In en, this message translates to:
  /// **'Kind {kind}'**
  String emailNip59Kind(int kind);

  /// Shown on a NIP-59 card when that layer wasn't captured/stored
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get emailNip59NotAvailable;

  /// Headline on the login screen
  ///
  /// In en, this message translates to:
  /// **'Log in to Nmail'**
  String get authHeaderTitle;

  /// Label for the nsec/sync-code input field
  ///
  /// In en, this message translates to:
  /// **'Sync code'**
  String get authSyncCodeLabel;

  /// Toast title when the user submits the login form before the code is validated
  ///
  /// In en, this message translates to:
  /// **'Invalid sync code'**
  String get authInvalidSyncCode;

  /// Toast description explaining that login is automatic once the code is valid
  ///
  /// In en, this message translates to:
  /// **'We\'re checking your code as you type. Once valid, you\'ll be signed in without having to click anything.'**
  String get authInvalidSyncCodeDescription;

  /// Primary log-in button label
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// Secondary button label that switches to the registration form
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAccount;

  /// Expandable button label that reveals additional login methods (NostrConnect)
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get authMoreOptions;

  /// Heading on the registration form asking for a display name
  ///
  /// In en, this message translates to:
  /// **'What should others see?'**
  String get authRegisterPrompt;

  /// Input label for the display name during registration
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get authDisplayNameLabel;

  /// Placeholder example for the display name input
  ///
  /// In en, this message translates to:
  /// **'e.g. Alice'**
  String get authDisplayNameHint;

  /// Link that returns from the registration form to the login form
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authBackToLogin;

  /// Error toast when the user's nsec can't be read after registration
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve sync code'**
  String get authUnableRetrieveCode;

  /// Title of the post-registration screen explaining the sync code
  ///
  /// In en, this message translates to:
  /// **'Your Sync Code'**
  String get authYourSyncCode;

  /// Intro paragraph above the bullet list of sync-code features
  ///
  /// In en, this message translates to:
  /// **'This code is the key to your account. It gives you full control and lets you:'**
  String get authSyncCodeIntro;

  /// Sync-code feature bullet: account restoration
  ///
  /// In en, this message translates to:
  /// **'Restore your account on any device'**
  String get authSyncCodeFeatureRestore;

  /// Sync-code feature bullet: secure backup
  ///
  /// In en, this message translates to:
  /// **'Back up your identity securely'**
  String get authSyncCodeFeatureBackup;

  /// Sync-code feature bullet: cross-app login
  ///
  /// In en, this message translates to:
  /// **'Log in to other Nostr apps'**
  String get authSyncCodeFeatureLogin;

  /// Warning callout below the sync-code feature list
  ///
  /// In en, this message translates to:
  /// **'Never share this code with anyone. Store it in a safe place. You can always find it later in Settings.'**
  String get authSyncCodeWarning;

  /// Transient label on the copy button after a successful copy
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get authCopied;

  /// Primary button on the sync-code screen that copies the nsec to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy Sync Code'**
  String get authCopySyncCode;

  /// Secondary button on the sync-code screen that proceeds to the inbox
  ///
  /// In en, this message translates to:
  /// **'Continue to Inbox'**
  String get authContinueToInbox;

  /// AppBar title of the compose screen
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get composeTitle;

  /// Placeholder for the To recipients field when empty
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get composeTo;

  /// Placeholder for the To recipients field when at least one recipient is already added
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get composeAddMore;

  /// Tooltip on the chevron that hides the expanded Cc/Bcc/From fields
  ///
  /// In en, this message translates to:
  /// **'Hide CC/BCC/From'**
  String get composeHideExpanded;

  /// Tooltip on the chevron that shows the expanded Cc/Bcc/From fields
  ///
  /// In en, this message translates to:
  /// **'Show CC/BCC/From'**
  String get composeShowExpanded;

  /// Short desktop button label next to the compose chevron that reveals Cc/Bcc/From fields
  ///
  /// In en, this message translates to:
  /// **'Cc, From'**
  String get composeExpandedFieldsButtonLabel;

  /// Placeholder for the Cc recipients field
  ///
  /// In en, this message translates to:
  /// **'Cc'**
  String get composeCc;

  /// Placeholder for the Bcc recipients field
  ///
  /// In en, this message translates to:
  /// **'Bcc'**
  String get composeBcc;

  /// Placeholder for the subject field
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get composeSubject;

  /// Tooltip on the paperclip icon used to attach files
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get composeAttachFile;

  /// Placeholder text inside the Quill rich-text editor
  ///
  /// In en, this message translates to:
  /// **'Compose email'**
  String get composePlaceholder;

  /// Label of the From-address selector row
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get composeFrom;

  /// Title of the From-address picker bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Send as'**
  String get composeSendAs;

  /// Entry in the From-address picker that opens the create-identity flow
  ///
  /// In en, this message translates to:
  /// **'Create new identity'**
  String get composeCreateNewIdentity;

  /// Accessibility label on the X button of an attachment chip
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get composeRemoveAttachment;

  /// Primary Send button label
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get composeSend;

  /// Tooltip on the arrow-down menu next to the Send button (desktop)
  ///
  /// In en, this message translates to:
  /// **'More send options'**
  String get composeMoreSendOptions;

  /// Title of the bottom sheet that lets the user pick a send mode
  ///
  /// In en, this message translates to:
  /// **'Choose send mode'**
  String get composeChooseSendMode;

  /// Send mode label: encrypted, unsigned (deniable)
  ///
  /// In en, this message translates to:
  /// **'Private deniable'**
  String get composeModePrivateDeniable;

  /// Send mode label: encrypted and signed
  ///
  /// In en, this message translates to:
  /// **'Private signed'**
  String get composeModePrivateSigned;

  /// Send mode label: public broadcast (no encryption)
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get composeModePublic;

  /// Description for the deniable send mode
  ///
  /// In en, this message translates to:
  /// **'Send as encrypted email. No signature - deniable if needed.'**
  String get composeModePrivateDeniableDescription;

  /// Description for the signed send mode
  ///
  /// In en, this message translates to:
  /// **'Send as encrypted email. Signed - proves you\'re the author.'**
  String get composeModePrivateSignedDescription;

  /// Description for the public send mode
  ///
  /// In en, this message translates to:
  /// **'Send as a public event. Anyone can read this. No encryption.'**
  String get composeModePublicDescription;

  /// Loading text shown in the recipient autocomplete while resolving a NIP-05 identifier
  ///
  /// In en, this message translates to:
  /// **'Resolving NIP-05...'**
  String get composeResolvingNip05;

  /// Tooltip on a suggestion sourced from the private address book
  ///
  /// In en, this message translates to:
  /// **'Address book'**
  String get contactSourceAddressBook;

  /// Tooltip on a suggestion sourced from previous email history
  ///
  /// In en, this message translates to:
  /// **'Email history'**
  String get contactSourceEmailHistory;

  /// Tooltip on a suggestion sourced from the user's Nostr follow list
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get contactSourceFollowing;

  /// Tooltip on a suggestion sourced from the local profile cache
  ///
  /// In en, this message translates to:
  /// **'Cached profile'**
  String get contactSourceCachedProfile;

  /// Tooltip on a suggestion verified via NIP-05 lookup
  ///
  /// In en, this message translates to:
  /// **'NIP-05 verified'**
  String get contactSourceNip05Verified;

  /// Title for the contacts section
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// Button label to add a new contact
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get contactsAdd;

  /// Tooltip or action label to save a sender/recipient to contacts
  ///
  /// In en, this message translates to:
  /// **'Add to contacts'**
  String get contactsAddToContacts;

  /// Tooltip for syncing private contacts from relays
  ///
  /// In en, this message translates to:
  /// **'Sync contacts'**
  String get contactsSync;

  /// Tooltip for retrying queued contact broadcasts
  ///
  /// In en, this message translates to:
  /// **'Retry pending contact updates'**
  String get contactsRetry;

  /// Placeholder for the contacts search field
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get contactsSearchHint;

  /// Empty state text for the contacts list
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get contactsEmpty;

  /// Empty state text for a contacts search with no results
  ///
  /// In en, this message translates to:
  /// **'No matching contacts'**
  String get contactsSearchEmpty;

  /// Placeholder shown when no contact is selected
  ///
  /// In en, this message translates to:
  /// **'Select a contact'**
  String get contactsSelectPrompt;

  /// Title of the create contact form
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get contactsCreateTitle;

  /// Title of the edit contact form
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get contactsEditTitle;

  /// Label for the contact display name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactsNameLabel;

  /// Label for the contact emails field
  ///
  /// In en, this message translates to:
  /// **'Email addresses'**
  String get contactsEmailsLabel;

  /// Hint for multi-value contact fields
  ///
  /// In en, this message translates to:
  /// **'One per line'**
  String get contactsMultilineHint;

  /// Hint for the add-email input in the contact form
  ///
  /// In en, this message translates to:
  /// **'Add email address'**
  String get contactsAddEmailHint;

  /// Label for the contact phone numbers field
  ///
  /// In en, this message translates to:
  /// **'Phone numbers'**
  String get contactsPhonesLabel;

  /// Hint for the add-phone input in the contact form
  ///
  /// In en, this message translates to:
  /// **'Add phone number'**
  String get contactsAddPhoneHint;

  /// Label for the contact birthday field
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get contactsBirthdayLabel;

  /// Button to reveal the birthday selector
  ///
  /// In en, this message translates to:
  /// **'Add birthday'**
  String get contactsBirthdayAdd;

  /// Label for the birthday day selector
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get contactsBirthdayDayLabel;

  /// Label for the birthday month selector
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get contactsBirthdayMonthLabel;

  /// Label for the optional birthday year field
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get contactsBirthdayYearLabel;

  /// Hint for the contact birthday field
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get contactsBirthdayHint;

  /// Label for Nostr identifiers in the contact form
  ///
  /// In en, this message translates to:
  /// **'Nostr identities'**
  String get contactsNostrLabel;

  /// Hint for Nostr identifier input
  ///
  /// In en, this message translates to:
  /// **'npub, nprofile, hex pubkey, or NIP-05'**
  String get contactsNostrHint;

  /// Hint for the add-Nostr-identity input in the contact form
  ///
  /// In en, this message translates to:
  /// **'Add npub, nprofile, hex pubkey, or NIP-05'**
  String get contactsAddNostrHint;

  /// Cancel button in contact dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get contactsCancel;

  /// Save button in contact dialogs
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get contactsSave;

  /// Tooltip for editing a contact
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get contactsEdit;

  /// Tooltip for copying a contact's raw vCard
  ///
  /// In en, this message translates to:
  /// **'Copy vCard'**
  String get contactsCopyVCard;

  /// Toast shown after copying a contact vCard
  ///
  /// In en, this message translates to:
  /// **'vCard copied'**
  String get contactsVCardCopied;

  /// Delete action for a contact
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get contactsDelete;

  /// Title for deleting a contact confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete contact?'**
  String get contactsDeleteTitle;

  /// Body text for deleting a contact confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This removes the contact from your private address book.'**
  String get contactsDeleteBody;

  /// Section title for contact email addresses
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactsEmailsTitle;

  /// Section title for contact phone numbers
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactsPhonesTitle;

  /// Section title for a contact birthday
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get contactsBirthdayTitle;

  /// Section title for contact Nostr identities
  ///
  /// In en, this message translates to:
  /// **'Nostr'**
  String get contactsNostrTitle;

  /// Tooltip for the button that calls a contact's phone number
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get contactsCall;

  /// Tooltip for the button that texts a contact's phone number
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get contactsSendSms;

  /// Menu entry to import contacts from a vCard file
  ///
  /// In en, this message translates to:
  /// **'Import contacts'**
  String get contactsImport;

  /// Menu entry to export all contacts to a vCard file
  ///
  /// In en, this message translates to:
  /// **'Export contacts'**
  String get contactsExport;

  /// Toast shown when trying to export with an empty address book
  ///
  /// In en, this message translates to:
  /// **'No contacts to export'**
  String get contactsExportEmpty;

  /// Toast shown after exporting contacts to a file, includes the saved path
  ///
  /// In en, this message translates to:
  /// **'Contacts exported: {path}'**
  String contactsExportSaved(String path);

  /// Error toast shown when exporting contacts fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export contacts: {error}'**
  String contactsExportFailed(String error);

  /// Toast shown when an imported vCard file contains no contacts
  ///
  /// In en, this message translates to:
  /// **'No contacts found in the file'**
  String get contactsImportEmpty;

  /// Error toast shown when importing contacts fails
  ///
  /// In en, this message translates to:
  /// **'Failed to import contacts: {error}'**
  String contactsImportFailed(String error);

  /// Toast summarizing how many contacts were imported and skipped
  ///
  /// In en, this message translates to:
  /// **'{imported} imported, {skipped} skipped'**
  String contactsImportSummary(int imported, int skipped);

  /// Title of the dialog shown when imported contacts already exist
  ///
  /// In en, this message translates to:
  /// **'Contacts already present'**
  String get contactsImportConflictTitle;

  /// Body of the import conflict dialog, includes how many contacts already exist
  ///
  /// In en, this message translates to:
  /// **'{count} of the imported contacts already exist. How should they be handled?'**
  String contactsImportConflictBody(int count);

  /// Conflict dialog action that merges imported contacts into existing ones
  ///
  /// In en, this message translates to:
  /// **'Merge all'**
  String get contactsImportMergeAll;

  /// Conflict dialog action that overwrites existing contacts with imported ones
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get contactsImportReplaceAll;

  /// Conflict dialog action that skips contacts already present
  ///
  /// In en, this message translates to:
  /// **'Skip duplicates'**
  String get contactsImportSkip;

  /// AppBar title of the profile editor
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// Input label for the display name on the profile editor
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayNameLabel;

  /// Placeholder for the display name input
  ///
  /// In en, this message translates to:
  /// **'Your full name or alias'**
  String get profileDisplayNameHint;

  /// Input label for the lowercase handle on the profile editor
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileUsernameLabel;

  /// Placeholder for the username input
  ///
  /// In en, this message translates to:
  /// **'handle'**
  String get profileUsernameHint;

  /// Input label for the About/bio field
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAboutLabel;

  /// Placeholder for the About/bio field
  ///
  /// In en, this message translates to:
  /// **'A short bio about yourself'**
  String get profileAboutHint;

  /// Expand-toggle label that reveals the picture URL field
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get profileAdvanced;

  /// Input label for the profile picture URL
  ///
  /// In en, this message translates to:
  /// **'Picture URL'**
  String get profilePictureUrlLabel;

  /// Placeholder example for the profile picture URL input
  ///
  /// In en, this message translates to:
  /// **'https://example.com/avatar.png'**
  String get profilePictureUrlHint;

  /// Accessibility label on the avatar preview that opens a file picker
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get profileChangePicture;

  /// Onboarding page 1 title (welcome)
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nmail'**
  String get onboardingPage1Title;

  /// Onboarding page 1 body
  ///
  /// In en, this message translates to:
  /// **'Discover a decentralized email experience that puts you in control. A new way to communicate, centered around you.'**
  String get onboardingPage1Body;

  /// Onboarding page 2 title (decentralization pitch)
  ///
  /// In en, this message translates to:
  /// **'A Network Without Masters'**
  String get onboardingPage2Title;

  /// Onboarding page 2 body
  ///
  /// In en, this message translates to:
  /// **'Your messages flow through a global network of independent servers. No single company owns your inbox.'**
  String get onboardingPage2Body;

  /// Onboarding page 3 title (provider freedom)
  ///
  /// In en, this message translates to:
  /// **'Freedom of Choice'**
  String get onboardingPage3Title;

  /// Onboarding page 3 body
  ///
  /// In en, this message translates to:
  /// **'You are never locked into a single provider. Switch bridges or relays at any time without ever losing your identity or contacts.'**
  String get onboardingPage3Body;

  /// Onboarding page 4 title (cross-app identity)
  ///
  /// In en, this message translates to:
  /// **'One Identity for Everything'**
  String get onboardingPage4Title;

  /// Onboarding page 4 body
  ///
  /// In en, this message translates to:
  /// **'Use your account to send emails, follow profiles, or use other apps. It\'s one permanent identity that works across many different applications.'**
  String get onboardingPage4Body;

  /// Onboarding page 5 title (future-proof pitch)
  ///
  /// In en, this message translates to:
  /// **'Built for the Future'**
  String get onboardingPage5Title;

  /// Onboarding page 5 body
  ///
  /// In en, this message translates to:
  /// **'Benefit from a modern architecture designed for privacy. Nmail helps you transition smoothly to a more secure and resilient way of communicating.'**
  String get onboardingPage5Body;

  /// Onboarding page 6 title (early-access disclaimer)
  ///
  /// In en, this message translates to:
  /// **'Early Access'**
  String get onboardingPage6Title;

  /// Onboarding page 6 body (early-access disclaimer)
  ///
  /// In en, this message translates to:
  /// **'Nmail and the protocol behind it are very young. Everything is built to work as well as possible, but bugs can happen and some things may feel slow or missing. Thanks for being an early supporter. Your patience helps shape what comes next.'**
  String get onboardingPage6Body;

  /// Skip button label on the onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Semantic label for the Next arrow on the onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Done button label on the final onboarding page
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboardingDone;

  /// AppBar title of the create-identity screen
  ///
  /// In en, this message translates to:
  /// **'Create Identity'**
  String get createIdentityTitle;

  /// Section heading for the address (local part) selector
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get createIdentityAddress;

  /// Placeholder in the custom local-part input field
  ///
  /// In en, this message translates to:
  /// **'Custom username'**
  String get createIdentityCustomUsername;

  /// Section heading for the bridge domain selector
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get createIdentityBridge;

  /// Empty-state message when no bridge options are available
  ///
  /// In en, this message translates to:
  /// **'No bridges available'**
  String get createIdentityNoBridges;

  /// Placeholder example for the bridge domain input
  ///
  /// In en, this message translates to:
  /// **'bridge.com'**
  String get createIdentityBridgeHint;

  /// Section heading for the address preview block
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get createIdentityPreview;

  /// Helper text shown in the preview block when the form is incomplete
  ///
  /// In en, this message translates to:
  /// **'Enter an address and select a bridge to see preview'**
  String get createIdentityPreviewEmpty;

  /// Inline error shown when creating an exact duplicate identity
  ///
  /// In en, this message translates to:
  /// **'This identity already exists'**
  String get createIdentityAlreadyExists;

  /// Tooltip on the settings icon in the desktop left rail
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get leftRailSettings;

  /// Title of the dialog confirming whether to open an external link
  ///
  /// In en, this message translates to:
  /// **'Open link?'**
  String get linkOpenTitle;

  /// Toast confirmation shown after copying a link to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// SnackBar message shown by debug tools when no user is logged in
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get debugNotAuthenticated;

  /// Debug SnackBar after the seed-old-email action succeeds
  ///
  /// In en, this message translates to:
  /// **'Created and trashed test email (31 days old)'**
  String get debugTestEmailCreated;

  /// Debug SnackBar when seeding succeeds but the timestamp override fails
  ///
  /// In en, this message translates to:
  /// **'Email created and trashed, but could not update timestamp'**
  String get debugTestEmailPartial;

  /// Generic debug error SnackBar prefix
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String debugError(String error);

  /// Native file picker dialog title for attaching files to a compose draft
  ///
  /// In en, this message translates to:
  /// **'Select Attachments'**
  String get composeSelectAttachments;

  /// Error toast when the file picker fails
  ///
  /// In en, this message translates to:
  /// **'Failed to pick files: {error}'**
  String composePickFilesFailed(String error);

  /// Error toast when a submitted recipient string can't be parsed
  ///
  /// In en, this message translates to:
  /// **'Invalid recipient format'**
  String get composeInvalidRecipient;

  /// Error toast when trying to send with no recipients
  ///
  /// In en, this message translates to:
  /// **'Add at least one recipient'**
  String get composeAddRecipient;

  /// Error toast when sending an email fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send email'**
  String get composeSendFailed;

  /// Tooltip for the button that schedules an email for later delivery
  ///
  /// In en, this message translates to:
  /// **'Schedule send'**
  String get composeScheduleSend;

  /// Tooltip on the button that clears the pending send time so the email sends immediately
  ///
  /// In en, this message translates to:
  /// **'Remove schedule'**
  String get composeScheduleClear;

  /// Error toast when the chosen schedule time is not in the future
  ///
  /// In en, this message translates to:
  /// **'Pick a time in the future'**
  String get composeScheduleTimePast;

  /// Error toast when scheduling an email fails
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule email'**
  String get composeScheduleFailed;

  /// Empty-state message when there are no emails queued for future delivery
  ///
  /// In en, this message translates to:
  /// **'No scheduled emails'**
  String get scheduledEmpty;

  /// Label showing when a scheduled email will be delivered, e.g. 'Sends Jul 3, 2:30 PM'
  ///
  /// In en, this message translates to:
  /// **'Sends {time}'**
  String scheduledSendsAt(String time);

  /// Tooltip/label on the action that cancels a scheduled email
  ///
  /// In en, this message translates to:
  /// **'Cancel send'**
  String get scheduledCancel;

  /// Error toast when cancelling a scheduled email fails
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel scheduled email'**
  String get scheduledCancelFailed;

  /// Status chip on a scheduled email that the DVM has already published
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get scheduledStatusSent;

  /// Status chip on a scheduled email whose delivery failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get scheduledStatusFailed;

  /// Status chip on a scheduled email the DVM rejected as invalid
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get scheduledStatusError;

  /// Error toast when the user's profile metadata can't be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile data'**
  String get profileLoadFailed;

  /// Native file picker dialog title for selecting a new profile picture
  ///
  /// In en, this message translates to:
  /// **'Select profile picture'**
  String get profileSelectPicture;

  /// Error toast when the Blossom upload returns no results
  ///
  /// In en, this message translates to:
  /// **'No servers responded'**
  String get profileUploadNoServers;

  /// Generic upload-failure toast used as a fallback when no error message is available
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get profileUploadFailed;

  /// Error toast when an exception is thrown during profile picture upload
  ///
  /// In en, this message translates to:
  /// **'An error occurred during upload'**
  String get profileUploadError;

  /// Error toast when saving the profile metadata event fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// Error toast when submitting the registration form with an empty display name
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get authEnterUsername;

  /// Error toast when saving a new identity to private settings fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create identity: {error}'**
  String createIdentityFailed(String error);

  /// Relative date label shown in the email list for emails received the day before today
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Heading shown on the 404 page when go_router cannot resolve the requested URL
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// Button label on the 404 page that returns the user to the inbox
  ///
  /// In en, this message translates to:
  /// **'Back to inbox'**
  String get notFoundBackToInbox;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fi',
    'fr',
    'it',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
