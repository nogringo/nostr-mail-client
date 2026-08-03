// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionClear => 'Löschen';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get actionOpen => 'Öffnen';

  @override
  String get actionUpload => 'Hochladen';

  @override
  String get actionReset => 'Zurücksetzen';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get actionDiscard => 'Verwerfen';

  @override
  String get actionKeepEditing => 'Weiter bearbeiten';

  @override
  String get actionFinish => 'Fertig';

  @override
  String get discardChangesTitle => 'Änderungen verwerfen?';

  @override
  String get discardChangesMessage =>
      'Du hast nicht gespeicherte Änderungen. Wenn du jetzt gehst, gehen sie verloren.';

  @override
  String get stateLoadingEllipsis => 'Lädt...';

  @override
  String get stateResetting => 'Wird zurückgesetzt...';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get settingsBackground => 'Hintergrund';

  @override
  String get settingsDynamicTheme => 'Dynamisches Design';

  @override
  String get settingsDynamicThemeSubtitle =>
      'Farben aus dem Hintergrundbild erzeugen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemsprache';

  @override
  String get settingsLanguageDialogTitle => 'Sprache wählen';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsMessages => 'Nachrichten';

  @override
  String get settingsEnableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get settingsEnableNotificationsSubtitle =>
      'Werde benachrichtigt, wenn eine neue E-Mail eintrifft.';

  @override
  String get settingsUnifiedPushDistributorMissingTitle =>
      'Push-Benachrichtigungen nicht verfügbar';

  @override
  String get settingsUnifiedPushDistributorMissingSubtitle =>
      'Installiere einen UnifiedPush-Distributor wie Sunup, um Benachrichtigungen im Hintergrund zu empfangen.';

  @override
  String get settingsUnifiedPushDistributorInstallSunup => 'Sunup installieren';

  @override
  String get settingsAlwaysLoadImages => 'Bilder immer laden';

  @override
  String get settingsAlwaysLoadImagesSubtitle =>
      'Bilder werden standardmäßig aus Datenschutzgründen blockiert';

  @override
  String get settingsIdentities => 'Identitäten';

  @override
  String get settingsEmailSignature => 'E-Mail-Signatur';

  @override
  String get settingsEmailSignatureEmpty => 'Keine Signatur konfiguriert';

  @override
  String get settingsEmailSignatureHint => 'Signatur eingeben...';

  @override
  String get settingsHosting => 'Hosting';

  @override
  String get settingsDebugTools => 'Debug-Werkzeuge';

  @override
  String get settingsCopySyncCode => 'Sync-Code kopieren';

  @override
  String get settingsSyncCodeCopied => 'Sync-Code kopiert';

  @override
  String get settingsLogOut => 'Abmelden';

  @override
  String get settingsResetApplication => 'App zurücksetzen';

  @override
  String get settingsResetConfirmMessage =>
      'Dies löscht alle lokalen Daten einschließlich Einstellungen und Hintergrundbilder und meldet dich ab.\n\nDiese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get settingsDeleteAccount => 'Konto löschen';

  @override
  String get settingsDeleteAccountTitle => 'Dieses Konto löschen?';

  @override
  String get settingsDeleteAccountMessage =>
      'Deine Relays werden gebeten, deine Nachrichten und dein Profil zu löschen, und das Konto wird von diesem Gerät entfernt.';

  @override
  String get settingsDeleteAccountWarning =>
      'Das lässt sich nicht rückgängig machen. Was gelöscht ist, kann nicht wiederhergestellt werden.';

  @override
  String get settingsDeleteAccountConfirmWord => 'LÖSCHEN';

  @override
  String settingsDeleteAccountConfirmLabel(String word) {
    return 'Gib $word ein, um zu bestätigen';
  }

  @override
  String get settingsDeleteAccountSignFailed =>
      'Die Anfrage wurde nicht signiert. Es wurde nichts gelöscht.';

  @override
  String get accountDeletedTitle => 'Konto von diesem Gerät gelöscht';

  @override
  String accountDeletedRelayCount(int erased, int total) {
    return '$erased von $total Relays haben deine Daten gelöscht';
  }

  @override
  String get accountDeletedRelayErased => 'Gelöscht';

  @override
  String get accountDeletedRelayNotErased => 'Nicht gelöscht';

  @override
  String get accountDeletedRelayPending => 'Wird gesendet';

  @override
  String get accountDeletedPendingNote =>
      'Die übrigen Relays werden beim nächsten Öffnen der App erneut kontaktiert.';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsDeveloper => 'Entwickler';

  @override
  String get settingsLicense => 'Lizenz';

  @override
  String get settingsSourceCode => 'Quellcode';

  @override
  String get settingsSourceCodeSubtitle => 'Auf GitHub ansehen';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Datenschutzdetails für den Apple App Store';

  @override
  String get settingsEarlyAccess => 'Frühzugriff';

  @override
  String get settingsEarlyAccessMessage =>
      'Nmail und das zugrundeliegende Protokoll sind noch sehr jung. Alles ist darauf ausgelegt, so gut wie möglich zu funktionieren, doch Fehler können auftreten und manches kann sich langsam oder unvollständig anfühlen. Danke, dass du zu den frühen Nutzern gehörst.';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsBackgroundDefaultLabel => 'Systemfarbe';

  @override
  String get settingsBackgroundSelectLabel => 'Hintergrundbild auswählen';

  @override
  String get settingsBackgroundDeleteLabel => 'Hintergrundbild löschen';

  @override
  String get settingsBackgroundRemoveLabel => 'Hintergrundbild entfernen';

  @override
  String get settingsBackgroundAddLabel => 'Hintergrundbild hinzufügen';

  @override
  String get settingsBackgroundDeleteTitle => 'Hintergrund löschen';

  @override
  String get settingsBackgroundDeleteMessage =>
      'Dieses Bild aus deinen gespeicherten Hintergründen entfernen?';

  @override
  String get settingsBackgroundDeleteFailed =>
      'Bild konnte nicht gelöscht werden';

  @override
  String get settingsBackgroundDialogTitle => 'Hintergrund';

  @override
  String get settingsBackgroundSelectFile => 'Datei auswählen';

  @override
  String get settingsBackgroundPasteUrl => 'URL einfügen';

  @override
  String get settingsBackgroundUrlTitle => 'Hintergrund-URL';

  @override
  String get settingsBackgroundUrlHint => 'https://beispiel.de/bild.jpg';

  @override
  String get settingsBackgroundCopyFailed => 'Bild konnte nicht kopiert werden';

  @override
  String get settingsBackgroundUrlError =>
      'Bild nicht erreichbar (CORS- oder Netzwerkfehler)';

  @override
  String get settingsBackgroundDownloadFailed =>
      'Bild konnte nicht heruntergeladen werden';

  @override
  String get settingsBackgroundUploadTitle => 'Bild hochladen';

  @override
  String get settingsBackgroundUploadWarning =>
      'Dieses Bild wird auf Blossom-Server hochgeladen. Serverbetreiber und jeder mit dem Link können es sehen.';

  @override
  String get hostingRecommended => 'Empfohlen:';

  @override
  String hostingWillBeAddedAs(String url) {
    return 'Wird hinzugefügt als: $url';
  }

  @override
  String get relayAddTitle => 'Relay hinzufügen';

  @override
  String get relayUrlLabel => 'Relay-URL';

  @override
  String get relayUrlHint => 'wss://relay.beispiel.de';

  @override
  String get relayInvalidUrl => 'Ungültige Relay-URL';

  @override
  String get relayDirection => 'Richtung';

  @override
  String get relayReadWrite => 'Lesen & Schreiben';

  @override
  String get relayRead => 'Lesen';

  @override
  String get relayWrite => 'Schreiben';

  @override
  String get relayMarkerReadWrite => 'lesen/schreiben';

  @override
  String get relayMarkerRead => 'lesen';

  @override
  String get relayMarkerWrite => 'schreiben';

  @override
  String get relayInboxOutboxTitle => 'Inbox/Outbox-Relays';

  @override
  String get relayInboxOutboxDescription =>
      'Relays, auf denen dein Konto veröffentlicht und liest.';

  @override
  String get relayAdd => 'Relay hinzufügen';

  @override
  String get relayRemoveTooltip => 'Relay entfernen';

  @override
  String get relayInboxOutboxEmpty => 'Keine Inbox/Outbox-Relays konfiguriert';

  @override
  String get dmRelayAddTitle => 'DM-Relay hinzufügen';

  @override
  String get dmRelaySectionTitle => 'DM-Relays';

  @override
  String get dmRelayDescription =>
      'Relays, die deine verschlüsselten Nachrichten empfangen.';

  @override
  String get dmRelayAdd => 'DM-Relay hinzufügen';

  @override
  String get dmRelayEmpty => 'Keine DM-Relays konfiguriert';

  @override
  String get bridgeAddTitle => 'Bridge hinzufügen';

  @override
  String get bridgeDomainLabel => 'Bridge-Domain';

  @override
  String get bridgeDomainHint => 'bridge.beispiel.de';

  @override
  String get bridgeInvalidDomain => 'Ungültige Domain';

  @override
  String get bridgeSectionTitle => 'Bridges';

  @override
  String get bridgeDescription =>
      'Domains, die dir eine normale E-Mail-Adresse geben.';

  @override
  String get bridgeAdd => 'Bridge hinzufügen';

  @override
  String get bridgeEmpty => 'Keine Bridges konfiguriert';

  @override
  String get bridgeDefault => 'Standard-Bridge';

  @override
  String get blossomAddTitle => 'Blossom-Server hinzufügen';

  @override
  String get blossomServerUrlLabel => 'Server-URL';

  @override
  String get blossomServerUrlHint => 'https://blossom.beispiel.de';

  @override
  String get blossomInvalidUrl => 'Ungültige Server-URL';

  @override
  String get blossomSectionTitle => 'Datei-Hosting';

  @override
  String get blossomDescription =>
      'Server, die deine Anhänge und Bilder speichern.';

  @override
  String get blossomAdd => 'Server hinzufügen';

  @override
  String get blossomRemoveTooltip => 'Server entfernen';

  @override
  String get blossomEmpty => 'Keine Blossom-Server konfiguriert';

  @override
  String get connectivitySectionTitle => 'Echtzeit-Verbindung';

  @override
  String connectivityConnectedCount(int connected, int total) {
    return '$connected von $total Relays verbunden';
  }

  @override
  String get connectivityConnected => 'Verbunden';

  @override
  String get connectivityDisconnected => 'Nicht verbunden';

  @override
  String get syncStatusSectionTitle => 'Sync-Status';

  @override
  String get syncStatusEmpty => 'Keine Sync-Daten verfügbar';

  @override
  String get syncStatusResync => 'Erneut synchronisieren';

  @override
  String get syncStatusResyncSubtitle =>
      'Alle Nachrichten erneut von deinen Relays lesen.';

  @override
  String get syncStatusBeginningOfTime => 'Anfang der Zeit';

  @override
  String get identitiesTitle => 'Identitäten';

  @override
  String get identitiesEmptyTitle => 'Noch keine Identitäten';

  @override
  String get identitiesEmptyMessage =>
      'Erstelle eine, um E-Mails von einer benutzerdefinierten Adresse zu senden.';

  @override
  String get identitiesCreate => 'Identität erstellen';

  @override
  String get accountsTitle => 'Konten';

  @override
  String get accountsManage => 'Konten verwalten';

  @override
  String get accountsRemove => 'Konto entfernen';

  @override
  String get accountsRemoveTitle => 'Dieses Konto entfernen?';

  @override
  String accountsRemoveMessage(String name) {
    return '$name wird von diesem Gerät entfernt und die lokalen Daten werden gelöscht: E-Mails, Kontakte und Einstellungen. Auf den Relays wird nichts gelöscht.';
  }

  @override
  String get accountsRemoveKeyWarning =>
      'Sichere zuerst den Sync-Code dieses Kontos. Ohne ihn kannst du dich nicht mehr anmelden.';

  @override
  String get accountsRemoveLastWarning =>
      'Das ist dein letztes Konto, du wirst also abgemeldet.';

  @override
  String get accountsRemoveFailed => 'Konto konnte nicht entfernt werden';

  @override
  String get accountSignerPrivateKey => 'Sync-Code';

  @override
  String get accountSignerExtension => 'Browser-Erweiterung';

  @override
  String get accountSignerApp => 'Signier-App';

  @override
  String get accountSignerBunker => 'Remote-Signierer';

  @override
  String get accountSignerExternal => 'Externer Signierer';

  @override
  String get debugToolsEmailTesting => 'E-Mail-Tests';

  @override
  String get debugToolsCreateOldTrashed => 'Alte gelöschte E-Mail erstellen';

  @override
  String get debugToolsCreateOldTrashedDescription =>
      'Erstellt eine Test-E-Mail im Papierkorb, die 31 Tage alt ist. Zum Testen der Funktion \"Alte E-Mails löschen\".';

  @override
  String get debugToolsTriggerNotification => 'Testbenachrichtigung auslösen';

  @override
  String get debugToolsTriggerNotificationDescription =>
      'Zeigt eine lokale Benachrichtigung an, als wäre eine neue E-Mail eingegangen, um die Anzeige und die Tipp-Verarbeitung zu testen.';

  @override
  String get debugNotificationPermissionDenied =>
      'Benachrichtigungsberechtigung verweigert.';

  @override
  String get folderInbox => 'Posteingang';

  @override
  String get folderSent => 'Gesendet';

  @override
  String get folderTrash => 'Papierkorb';

  @override
  String get folderArchive => 'Archiv';

  @override
  String get folderScheduled => 'Geplant';

  @override
  String get inboxEmptyInbox => 'Noch keine E-Mails';

  @override
  String get inboxEmptySent => 'Keine gesendeten E-Mails';

  @override
  String get inboxEmptyTrash => 'Papierkorb ist leer';

  @override
  String get inboxEmptyArchive => 'Archiv ist leer';

  @override
  String get inboxSyncFromRelays => 'Von Relays synchronisieren';

  @override
  String get inboxSearch => 'Suchen';

  @override
  String get inboxSync => 'Synchronisieren';

  @override
  String get inboxMenu => 'Menü';

  @override
  String get inboxClearSelection => 'Auswahl aufheben';

  @override
  String inboxSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get inboxProfile => 'Profil';

  @override
  String get inboxCopyNpub => 'npub kopieren';

  @override
  String get inboxAddAccount => 'Konto hinzufügen';

  @override
  String get inboxLogout => 'Abmelden';

  @override
  String get inboxAccount => 'Konto';

  @override
  String get inboxCompose => 'Verfassen';

  @override
  String get inboxNpubCopied => 'npub kopiert';

  @override
  String get inboxUnknown => 'Unbekannt';

  @override
  String get inboxEditProfile => 'Profil bearbeiten';

  @override
  String get inboxSettings => 'Einstellungen';

  @override
  String get inboxDeleteOldEmailsTitle => 'Alte E-Mails löschen';

  @override
  String inboxDeleteOldEmailsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count E-Mails',
      one: '$count E-Mail',
    );
    return 'Dies löscht dauerhaft $_temp0, die älter als 30 Tage sind.\n\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get inboxDeleteFailed => 'Löschen fehlgeschlagen';

  @override
  String inboxDeleteFailedDescription(String error) {
    return 'Alte E-Mails konnten nicht gelöscht werden: $error';
  }

  @override
  String inboxOldEmailsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alte E-Mails zu löschen',
      one: '$count alte E-Mail zu löschen',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeleteNow => 'Jetzt löschen';

  @override
  String get inboxDeleteOldEmailsTooltip => 'Alte E-Mails löschen';

  @override
  String get inboxSearchHint => 'Alle E-Mails durchsuchen...';

  @override
  String get inboxCloseSearch => 'Suche schließen';

  @override
  String get inboxSelectAll => 'Alle auswählen';

  @override
  String get inboxMoreActions => 'Weitere Aktionen';

  @override
  String get emailReply => 'Antworten';

  @override
  String get emailForward => 'Weiterleiten';

  @override
  String get emailArchive => 'Archivieren';

  @override
  String get emailUnarchive => 'Aus Archiv holen';

  @override
  String get emailMarkAsRead => 'Als gelesen markieren';

  @override
  String get emailMarkAsUnread => 'Als ungelesen markieren';

  @override
  String get emailMoveToTrash => 'In den Papierkorb';

  @override
  String get emailRestore => 'Wiederherstellen';

  @override
  String get emailDeletePermanently => 'Endgültig löschen';

  @override
  String get emailNoSubject => '(Kein Betreff)';

  @override
  String emailExtraRecipients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere Empfänger',
      one: '$count weiterer Empfänger',
    );
    return '$_temp0';
  }

  @override
  String get emailNotFound => 'E-Mail nicht gefunden';

  @override
  String emailSenderNpub(String npub) {
    return 'Absender-npub: $npub';
  }

  @override
  String get emailDeletePermanentlyTitle => 'Endgültig löschen?';

  @override
  String get emailDeletePermanentlyMessage =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get emailDefaultFilename => 'email';

  @override
  String emailSaved(String path) {
    return 'E-Mail gespeichert: $path';
  }

  @override
  String emailSaveFailed(String error) {
    return 'E-Mail konnte nicht gespeichert werden: $error';
  }

  @override
  String get emailRawContentUnavailable =>
      'E-Mail-Inhalt konnte nicht geladen werden';

  @override
  String get emailRepostFailedEvent =>
      'E-Mail-Ereignis zum Reposten nicht gefunden';

  @override
  String get emailRepostSuccess => 'E-Mail erfolgreich erneut veröffentlicht';

  @override
  String emailRepostFailed(String error) {
    return 'Reposten der E-Mail fehlgeschlagen: $error';
  }

  @override
  String get emailAttachmentLoadFailed => 'Anhang konnte nicht geladen werden';

  @override
  String get emailFileSaved => 'Anhang in Downloads gespeichert';

  @override
  String emailFileSaveFailed(String error) {
    return 'Datei konnte nicht gespeichert werden: $error';
  }

  @override
  String emailDownloadedAllSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien erfolgreich heruntergeladen',
      one: '$count Datei erfolgreich heruntergeladen',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien konnten nicht heruntergeladen werden',
      one: '$count Datei konnte nicht heruntergeladen werden',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedMixed(int success, int failed) {
    return '$success Dateien heruntergeladen, $failed fehlgeschlagen';
  }

  @override
  String get emailDownload => 'Herunterladen';

  @override
  String get emailImageLoadFailed => 'Bild konnte nicht geladen werden';

  @override
  String get emailPdfLoadFailed => 'PDF konnte nicht geladen werden';

  @override
  String get emailActionReply => 'Antworten';

  @override
  String get emailActionReplyAll => 'Allen antworten';

  @override
  String get emailActionForward => 'Weiterleiten';

  @override
  String get emailActionArchive => 'Archivieren';

  @override
  String get emailActionUnarchive => 'Aus Archiv holen';

  @override
  String get emailActionMarkRead => 'Gelesen';

  @override
  String get emailActionMarkUnread => 'Ungelesen';

  @override
  String get emailActionNip59 => 'NIP-59-Ereignisse';

  @override
  String get emailActionRepost => 'Reposten';

  @override
  String get emailActionDownload => 'E-Mail herunterladen';

  @override
  String get emailActionViewSource => 'Quelle anzeigen';

  @override
  String get emailMoreActions => 'Weitere Aktionen';

  @override
  String get emailMoreOptions => 'Weitere Optionen';

  @override
  String get emailShowRecipients => 'Empfänger anzeigen';

  @override
  String get emailImagesHidden =>
      'Bilder zum Schutz der Privatsphäre ausgeblendet';

  @override
  String get emailLoadImages => 'Bilder laden';

  @override
  String get emailRecipientTo => 'An';

  @override
  String get emailRecipientCc => 'Cc';

  @override
  String get emailRecipientBcc => 'Bcc';

  @override
  String get emailAttachmentsTitle => 'Anhänge';

  @override
  String get emailDownloadAll => 'Alle herunterladen';

  @override
  String get emailNip59Dismiss => 'Schließen';

  @override
  String get emailNip59Title => 'NIP-59-Ereignisse';

  @override
  String get emailNip59GiftWrap => 'Gift Wrap';

  @override
  String get emailNip59Seal => 'Seal';

  @override
  String get emailNip59Rumor => 'Rumor';

  @override
  String get emailNip59CopyJson => 'JSON kopieren';

  @override
  String emailNip59Kind(int kind) {
    return 'Kind $kind';
  }

  @override
  String get emailNip59NotAvailable => 'Nicht verfügbar';

  @override
  String get authHeaderTitle => 'Bei Nmail anmelden';

  @override
  String get authSyncCodeLabel => 'Sync-Code';

  @override
  String get authInvalidSyncCode => 'Ungültiger Sync-Code';

  @override
  String get authInvalidSyncCodeDescription =>
      'Wir prüfen deinen Code, während du tippst. Sobald er gültig ist, wirst du automatisch angemeldet.';

  @override
  String get authLogIn => 'Anmelden';

  @override
  String get authCreateAccount => 'Konto erstellen';

  @override
  String get authMoreOptions => 'Weitere Optionen';

  @override
  String get authRegisterPrompt => 'Was sollen andere sehen?';

  @override
  String get authDisplayNameLabel => 'Anzeigename';

  @override
  String get authDisplayNameHint => 'z. B. Alice';

  @override
  String get authBackToLogin => 'Zurück zur Anmeldung';

  @override
  String get authUnableRetrieveCode =>
      'Sync-Code konnte nicht abgerufen werden';

  @override
  String get authYourSyncCode => 'Dein Sync-Code';

  @override
  String get authSyncCodeIntro =>
      'Dieser Code ist der Schlüssel zu deinem Konto. Er gibt dir volle Kontrolle und ermöglicht dir:';

  @override
  String get authSyncCodeFeatureRestore =>
      'Dein Konto auf jedem Gerät wiederherzustellen';

  @override
  String get authSyncCodeFeatureBackup => 'Deine Identität sicher zu sichern';

  @override
  String get authSyncCodeFeatureLogin =>
      'Dich in andere Nostr-Apps einzuloggen';

  @override
  String get authSyncCodeWarning =>
      'Teile diesen Code niemals. Bewahre ihn an einem sicheren Ort auf. Du findest ihn jederzeit wieder in den Einstellungen.';

  @override
  String get authCopied => 'Kopiert!';

  @override
  String get authCopySyncCode => 'Sync-Code kopieren';

  @override
  String get authContinueToInbox => 'Weiter zum Posteingang';

  @override
  String get composeTitle => 'Verfassen';

  @override
  String get composeTo => 'An';

  @override
  String get composeAddMore => 'Weitere hinzufügen';

  @override
  String get composeHideExpanded => 'Cc/Bcc/Von ausblenden';

  @override
  String get composeShowExpanded => 'Cc/Bcc/Von anzeigen';

  @override
  String get composeExpandedFieldsButtonLabel => 'Cc, Von';

  @override
  String get composeCc => 'Cc';

  @override
  String get composeBcc => 'Bcc';

  @override
  String get composeSubject => 'Betreff';

  @override
  String get composeAttachFile => 'Datei anhängen';

  @override
  String get composePlaceholder => 'E-Mail verfassen';

  @override
  String get composeFrom => 'Von';

  @override
  String get composeSendAs => 'Senden als';

  @override
  String get composeCreateNewIdentity => 'Neue Identität erstellen';

  @override
  String get composeRemoveAttachment => 'Anhang entfernen';

  @override
  String get composeSend => 'Senden';

  @override
  String get composeMoreSendOptions => 'Weitere Sendeoptionen';

  @override
  String get composeChooseSendMode => 'Sendemodus wählen';

  @override
  String get composeModePrivateDeniable => 'Privat & abstreitbar';

  @override
  String get composeModePrivateSigned => 'Privat & signiert';

  @override
  String get composeModePublic => 'Öffentlich';

  @override
  String get composeModePrivateDeniableDescription =>
      'Als verschlüsselte E-Mail senden. Ohne Signatur – bei Bedarf abstreitbar.';

  @override
  String get composeModePrivateSignedDescription =>
      'Als verschlüsselte E-Mail senden. Signiert – beweist deine Urheberschaft.';

  @override
  String get composeModePublicDescription =>
      'Als öffentliches Ereignis senden. Jeder kann es lesen. Keine Verschlüsselung.';

  @override
  String get composeResolvingNip05 => 'NIP-05 wird aufgelöst...';

  @override
  String get contactSourceAddressBook => 'Adressbuch';

  @override
  String get contactSourceEmailHistory => 'E-Mail-Verlauf';

  @override
  String get contactSourceFollowing => 'Folgt';

  @override
  String get contactSourceCachedProfile => 'Profil im Cache';

  @override
  String get contactSourceNip05Verified => 'NIP-05-verifiziert';

  @override
  String get contactsTitle => 'Kontakte';

  @override
  String get contactsAdd => 'Kontakt hinzufügen';

  @override
  String get contactsAddToContacts => 'Zu Kontakten hinzufügen';

  @override
  String get contactsSync => 'Kontakte synchronisieren';

  @override
  String get contactsRetry => 'Ausstehende Kontakt-Updates erneut versuchen';

  @override
  String get contactsSearchHint => 'Kontakte suchen';

  @override
  String get contactsEmpty => 'Noch keine Kontakte';

  @override
  String get contactsSearchEmpty => 'Keine passenden Kontakte';

  @override
  String get contactsSelectPrompt => 'Kontakt auswählen';

  @override
  String get contactsCreateTitle => 'Neuer Kontakt';

  @override
  String get contactsEditTitle => 'Kontakt bearbeiten';

  @override
  String get contactsNameLabel => 'Name';

  @override
  String get contactsEmailsLabel => 'E-Mail-Adressen';

  @override
  String get contactsAddEmailHint => 'E-Mail-Adresse hinzufügen';

  @override
  String get contactsPhonesLabel => 'Telefonnummern';

  @override
  String get contactsAddPhoneHint => 'Telefonnummer hinzufügen';

  @override
  String get contactsBirthdayLabel => 'Geburtstag';

  @override
  String get contactsBirthdayAdd => 'Geburtstag hinzufügen';

  @override
  String get contactsBirthdayDayLabel => 'Tag';

  @override
  String get contactsBirthdayMonthLabel => 'Monat';

  @override
  String get contactsBirthdayYearLabel => 'Jahr';

  @override
  String get contactsNostrLabel => 'Nostr-Identitäten';

  @override
  String get contactsAddNostrHint =>
      'npub, nprofile, Hex-Pubkey oder NIP-05 hinzufügen';

  @override
  String get contactsCancel => 'Abbrechen';

  @override
  String get contactsSave => 'Speichern';

  @override
  String get contactsEdit => 'Kontakt bearbeiten';

  @override
  String get contactsCopyVCard => 'vCard kopieren';

  @override
  String get contactsVCardCopied => 'vCard kopiert';

  @override
  String get contactsDelete => 'Löschen';

  @override
  String get contactsDeleteTitle => 'Kontakt löschen?';

  @override
  String get contactsDeleteBody =>
      'Dies entfernt den Kontakt aus deinem privaten Adressbuch.';

  @override
  String get contactsEmailsTitle => 'E-Mail';

  @override
  String get contactsPhonesTitle => 'Telefon';

  @override
  String get contactsBirthdayTitle => 'Geburtstag';

  @override
  String get contactsNostrTitle => 'Nostr';

  @override
  String get contactsCall => 'Anrufen';

  @override
  String get contactsSendSms => 'SMS senden';

  @override
  String get contactsImport => 'Kontakte importieren';

  @override
  String get contactsExport => 'Kontakte exportieren';

  @override
  String get contactsExportEmpty => 'Keine Kontakte zum Exportieren';

  @override
  String contactsExportSaved(String path) {
    return 'Kontakte exportiert: $path';
  }

  @override
  String contactsExportFailed(String error) {
    return 'Export der Kontakte fehlgeschlagen: $error';
  }

  @override
  String get contactsImportEmpty => 'Keine Kontakte in der Datei gefunden';

  @override
  String contactsImportFailed(String error) {
    return 'Import der Kontakte fehlgeschlagen: $error';
  }

  @override
  String contactsImportSummary(int imported, int skipped) {
    return '$imported importiert, $skipped übersprungen';
  }

  @override
  String get contactsImportConflictTitle => 'Kontakte bereits vorhanden';

  @override
  String contactsImportConflictBody(int count) {
    return '$count der importierten Kontakte sind bereits vorhanden. Wie sollen sie behandelt werden?';
  }

  @override
  String get contactsImportMergeAll => 'Alle zusammenführen';

  @override
  String get contactsImportReplaceAll => 'Alle ersetzen';

  @override
  String get contactsImportSkip => 'Duplikate überspringen';

  @override
  String get profileEditTitle => 'Profil bearbeiten';

  @override
  String get profileDisplayNameLabel => 'Anzeigename';

  @override
  String get profileDisplayNameHint => 'Dein vollständiger Name oder Pseudonym';

  @override
  String get profileUsernameLabel => 'Benutzername';

  @override
  String get profileUsernameHint => 'kennung';

  @override
  String get profileAboutLabel => 'Über mich';

  @override
  String get profileAboutHint => 'Eine kurze Biografie über dich';

  @override
  String get profileAdvanced => 'Erweitert';

  @override
  String get profilePictureUrlLabel => 'Bild-URL';

  @override
  String get profilePictureUrlHint => 'https://beispiel.de/avatar.png';

  @override
  String get profileChangePicture => 'Profilbild ändern';

  @override
  String get onboardingPage1Title => 'Willkommen bei Nmail';

  @override
  String get onboardingPage1Body =>
      'Entdecke eine dezentrale E-Mail-Erfahrung, bei der du die Kontrolle hast. Eine neue Art zu kommunizieren – ganz auf dich ausgerichtet.';

  @override
  String get onboardingPage2Title => 'Ein Netzwerk ohne Herrscher';

  @override
  String get onboardingPage2Body =>
      'Deine Nachrichten laufen über ein globales Netzwerk unabhängiger Server. Kein einzelnes Unternehmen besitzt deinen Posteingang.';

  @override
  String get onboardingPage3Title => 'Freie Wahl';

  @override
  String get onboardingPage3Body =>
      'Du bist nie an einen einzigen Anbieter gebunden. Wechsle Bridges oder Relays jederzeit, ohne deine Identität oder Kontakte zu verlieren.';

  @override
  String get onboardingPage4Title => 'Eine Identität für alles';

  @override
  String get onboardingPage4Body =>
      'Nutze dein Konto, um E-Mails zu senden, Profilen zu folgen oder andere Apps zu nutzen. Eine permanente Identität, die in vielen verschiedenen Anwendungen funktioniert.';

  @override
  String get onboardingPage5Title => 'Für die Zukunft gebaut';

  @override
  String get onboardingPage5Body =>
      'Profitiere von einer modernen, datenschutzorientierten Architektur. Nmail hilft dir, sanft zu einer sichereren und widerstandsfähigeren Kommunikation überzugehen.';

  @override
  String get onboardingPage6Title => 'Frühzugriff';

  @override
  String get onboardingPage6Body =>
      'Nmail und das zugrundeliegende Protokoll sind noch sehr jung. Alles ist darauf ausgelegt, so gut wie möglich zu funktionieren, doch Fehler können auftreten und manches kann sich langsam oder unvollständig anfühlen. Danke, dass du zu den frühen Nutzern gehörst. Deine Geduld hilft, das Projekt zu gestalten.';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingDone => 'Fertig';

  @override
  String get createIdentityTitle => 'Identität erstellen';

  @override
  String get createIdentityAddress => 'Adresse';

  @override
  String get createIdentityCustomUsername => 'Eigener Benutzername';

  @override
  String get createIdentityBridge => 'Bridge';

  @override
  String get createIdentityNoBridges => 'Keine Bridges verfügbar';

  @override
  String get createIdentityBridgeHint => 'bridge.de';

  @override
  String get createIdentityPreview => 'Vorschau';

  @override
  String get createIdentityPreviewEmpty =>
      'Adresse eingeben und Bridge auswählen, um die Vorschau zu sehen';

  @override
  String get createIdentityAlreadyExists => 'Diese Identität existiert bereits';

  @override
  String get leftRailSettings => 'Einstellungen';

  @override
  String get linkOpenTitle => 'Link öffnen?';

  @override
  String get linkCopied => 'Link kopiert';

  @override
  String get debugNotAuthenticated => 'Nicht authentifiziert';

  @override
  String get debugTestEmailCreated =>
      'Test-E-Mail erstellt und in den Papierkorb verschoben (31 Tage alt)';

  @override
  String get debugTestEmailPartial =>
      'E-Mail erstellt und in den Papierkorb verschoben, aber Zeitstempel konnte nicht aktualisiert werden';

  @override
  String debugError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get composeSelectAttachments => 'Anhänge auswählen';

  @override
  String composePickFilesFailed(String error) {
    return 'Dateien konnten nicht ausgewählt werden: $error';
  }

  @override
  String get composeInvalidRecipient => 'Ungültiges Empfängerformat';

  @override
  String get composeAddRecipient => 'Mindestens einen Empfänger hinzufügen';

  @override
  String get composeSendFailed => 'E-Mail konnte nicht gesendet werden';

  @override
  String get composeScheduleSend => 'Senden planen';

  @override
  String get composeScheduleClear => 'Zeitplan entfernen';

  @override
  String get composeScheduleTimePast => 'Einen Zeitpunkt in der Zukunft wählen';

  @override
  String get composeScheduleFailed => 'E-Mail konnte nicht geplant werden';

  @override
  String get scheduledEmpty => 'Keine geplanten E-Mails';

  @override
  String scheduledSendsAt(String time) {
    return 'Wird gesendet $time';
  }

  @override
  String get scheduledCancel => 'Senden abbrechen';

  @override
  String get scheduledCancelFailed =>
      'Geplante E-Mail konnte nicht abgebrochen werden';

  @override
  String get scheduledStatusSent => 'Gesendet';

  @override
  String get scheduledStatusFailed => 'Fehlgeschlagen';

  @override
  String get scheduledStatusError => 'Abgelehnt';

  @override
  String get profileLoadFailed => 'Profildaten konnten nicht geladen werden';

  @override
  String get profileSelectPicture => 'Profilbild auswählen';

  @override
  String get profileUploadNoServers => 'Keine Server haben geantwortet';

  @override
  String get profileUploadFailed => 'Upload fehlgeschlagen';

  @override
  String get profileUploadError => 'Beim Upload ist ein Fehler aufgetreten';

  @override
  String get profileUpdateFailed => 'Profil konnte nicht aktualisiert werden';

  @override
  String get authEnterUsername => 'Bitte einen Benutzernamen eingeben';

  @override
  String createIdentityFailed(String error) {
    return 'Identität konnte nicht erstellt werden: $error';
  }

  @override
  String get dateYesterday => 'Gestern';

  @override
  String get notFoundTitle => 'Seite nicht gefunden';

  @override
  String get notFoundBackToInbox => 'Zurück zum Posteingang';

  @override
  String get backgroundPresetAnimatedWaves => 'Animierte Wellen';

  @override
  String get backgroundPresetSoftGradient => 'Sanfter Verlauf';

  @override
  String get backgroundPresetBloomImage => 'Blüte';

  @override
  String get relaySetupSearching => 'Suche nach deiner Relay-Liste...';

  @override
  String get relaySetupUnreachableTitle => 'Kein Relay erreichbar';

  @override
  String get relaySetupUnreachableDescription =>
      'Solange kein Relay antwortet, lässt sich nicht sagen, ob deine Relay-Liste existiert. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get relaySetupRetry => 'Erneut versuchen';

  @override
  String get relaySetupMissingTitle => 'Deine Relay-Liste wurde nicht gefunden';

  @override
  String get relaySetupMissingDescription =>
      'Deine Relay-Liste sagt Apps, wo dein Konto lebt. Wenn du eine hast, sag uns, wo wir suchen sollen. Wenn nicht, kannst du jetzt eine anlegen.';

  @override
  String get relaySetupHintLabel => 'Wo sollen wir suchen?';

  @override
  String get relaySetupHintHelper =>
      'Ein Relay, eine Nostr-Adresse oder ein nprofile. Es darf auch das einer anderen Person sein.';

  @override
  String get relaySetupHintHint => 'wss://relay.example.com';

  @override
  String get relaySetupHintErrorEmpty =>
      'Gib ein Relay, eine Nostr-Adresse oder ein nprofile ein';

  @override
  String get relaySetupHintErrorNpub =>
      'Ein npub enthält kein Relay. Nutze ein nprofile, eine Nostr-Adresse oder eine Relay-URL.';

  @override
  String get relaySetupHintErrorMalformed =>
      'Das ist weder ein Relay noch eine Nostr-Adresse noch ein nprofile';

  @override
  String get relaySetupSearch => 'Suchen';

  @override
  String get relaySetupHintNotFound =>
      'Dort liegt keine Relay-Liste für dein Konto';

  @override
  String get relaySetupHintUnreachable => 'Dieses Relay ist nicht erreichbar';

  @override
  String get relaySetupHintNip05NotFound =>
      'Diese Nostr-Adresse nennt kein Relay';

  @override
  String get relaySetupHintNip05Unreachable =>
      'Diese Nostr-Adresse konnte nicht aufgelöst werden';

  @override
  String get relaySetupFoundTitle => 'Relay-Liste gefunden';

  @override
  String relaySetupFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Relays',
      one: '$count Relay',
    );
    return '$_temp0';
  }

  @override
  String get relaySetupUseFoundList => 'Diese Liste verwenden';

  @override
  String get relaySetupSearchAgain => 'Woanders suchen';

  @override
  String get relaySetupOr => 'oder';

  @override
  String get relaySetupCreate => 'Neue Relay-Liste anlegen';

  @override
  String relaySetupCreateDescription(String relays) {
    return 'Veröffentlicht eine Liste mit: $relays';
  }

  @override
  String get relaySetupContinueWithout => 'Ohne Liste fortfahren';

  @override
  String get relaySetupContinueAnyway => 'Trotzdem fortfahren';
}
