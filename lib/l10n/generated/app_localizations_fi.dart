// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get actionCancel => 'Peruuta';

  @override
  String get actionSave => 'Tallenna';

  @override
  String get actionDelete => 'Poista';

  @override
  String get actionAdd => 'Lisää';

  @override
  String get actionClear => 'Tyhjennä';

  @override
  String get actionClose => 'Sulje';

  @override
  String get actionContinue => 'Jatka';

  @override
  String get actionBack => 'Takaisin';

  @override
  String get actionConfirm => 'Hyväksy';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCopy => 'Kopioi';

  @override
  String get actionOpen => 'Avaa';

  @override
  String get actionUpload => 'Tallenna palvelimelle';

  @override
  String get actionReset => 'Nollaa';

  @override
  String get actionUndo => 'Kumoa';

  @override
  String get actionRemove => 'Poista';

  @override
  String get actionDiscard => 'Hylkää';

  @override
  String get stateLoading => 'Ladataan';

  @override
  String get stateLoadingEllipsis => 'Ladataan...';

  @override
  String get stateResetting => 'Nollataan...';

  @override
  String get stateValidating => 'Vahvistetaan...';

  @override
  String get stateDownloading => 'Lataa...';

  @override
  String get stateUploading => 'Tallennetaan palvelimelle...';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String get settingsAppearance => 'Ulkoasu';

  @override
  String get settingsDynamicTheme => 'Mukautuva teema';

  @override
  String get settingsDynamicThemeSubtitle => 'Luo värit taustakuvasta';

  @override
  String get settingsLanguage => 'Kieli';

  @override
  String get settingsLanguageSystem => 'Järjestelmän oletus';

  @override
  String get settingsLanguageDialogTitle => 'Valitse kieli';

  @override
  String get settingsAdvancedOptions => 'Edistyneet asetukset';

  @override
  String get settingsShowEmailSource => 'Näytä sähköpostin lähdekoodi';

  @override
  String get settingsShowEmailSourceSubtitle =>
      'Lisää painikkeen muotoilemattoman sähköpostin näyttämiselle';

  @override
  String get settingsAlwaysLoadImages => 'Lataa kuvat aina';

  @override
  String get settingsAlwaysLoadImagesSubtitle =>
      'Yksityisyyden suojaamiseksi kuvat estetään oletuksena';

  @override
  String get settingsIdentities => 'Henkilöllisyydet';

  @override
  String get settingsManageIdentities => 'Hallitse henkilöllisyyksiä';

  @override
  String get settingsManageIdentitiesSubtitle =>
      'Lisää, poista tai järjestele henkilöllisyyksiä';

  @override
  String get settingsCompose => 'Kirjoita';

  @override
  String get settingsEmailSignature => 'Sähköpostin allekirjoitus';

  @override
  String get settingsEmailSignatureEmpty => 'Ei allekirjoitusta';

  @override
  String get settingsEmailSignatureHint => 'Luo allekirjoitus...';

  @override
  String get settingsSynchronization => 'Synkronointi';

  @override
  String get settingsHosting => 'Palvelimet';

  @override
  String get settingsHostingSubtitle =>
      'Nostr-palvelimet, Blossom-palvelimet, yhteydet';

  @override
  String get settingsDebugTools => 'Kehittäjätyökalut';

  @override
  String get settingsDebugToolsSubtitle => 'Testaus- ja kehitysominaisuudet';

  @override
  String get settingsAccount => 'Tili';

  @override
  String get settingsCopySyncCode => 'Kopioi synkronointikoodi';

  @override
  String get settingsCopySyncCodeSubtitle =>
      'Koodin avulla voit synkronoida sovelluksen muilla laitteilla';

  @override
  String get settingsSyncCodeCopied => 'Synkronointikoodi kopioitu';

  @override
  String get settingsLogOut => 'Kirjaudu ulos';

  @override
  String get settingsResetApplication => 'Palauta sovellus';

  @override
  String get settingsResetApplicationSubtitle => 'Poista paikalliset tiedot';

  @override
  String get settingsResetConfirmMessage =>
      'Poistaa kaiken paikallisen datan, mukaan lukien asetukset ja taustakuvat, ja kirjautuu ulos.\n\nToimintoa ei voi kumota.';

  @override
  String get settingsAbout => 'Tietoja';

  @override
  String get settingsVersion => 'Versio';

  @override
  String get settingsSourceCode => 'Lähdekoodi';

  @override
  String get settingsSourceCodeSubtitle => 'Näytä GitHubissa';

  @override
  String get settingsEarlyAccess => 'Kehitysversio';

  @override
  String get settingsEarlyAccessMessage =>
      'Nmail ja sen taustaprotokolla ovat uusia. Bugeja voi esiintyä ja jotkin sähköpostilta odotetut ominaisuudet saattavat tuntua hitailta tai puuttua vielä kokonaan. Kiitos, kun tuet varhaista kehitystyötä.';

  @override
  String get settingsTheme => 'Teema';

  @override
  String get settingsThemeAuto => 'Automaattinen';

  @override
  String get settingsThemeLight => 'Vaalea';

  @override
  String get settingsThemeDark => 'Tumma';

  @override
  String get settingsBackgroundDefaultLabel => 'Teeman oletusväri';

  @override
  String get settingsBackgroundSelectLabel => 'Valitse taustakuva';

  @override
  String get settingsBackgroundDeleteLabel => 'Poista taustakuva';

  @override
  String get settingsBackgroundRemoveLabel => 'Irrota taustakuva';

  @override
  String get settingsBackgroundAddLabel => 'Lisää taustakuva';

  @override
  String get settingsBackgroundDeleteTitle => 'Poista taustakuva';

  @override
  String get settingsBackgroundDeleteMessage =>
      'Poista kuvan tallennus taustakuvista?';

  @override
  String get settingsBackgroundImageDeleted => 'Kuva poistettu';

  @override
  String get settingsBackgroundDeleteFailed => 'Kuvan poisto epäonnistui';

  @override
  String get settingsBackgroundDialogTitle => 'Taustakuva';

  @override
  String get settingsBackgroundSelectFile => 'Valitse tiedosto';

  @override
  String get settingsBackgroundPasteUrl => 'Liitä URL';

  @override
  String get settingsBackgroundUrlTitle => 'Taustakuvan URL';

  @override
  String get settingsBackgroundUrlHint => 'https://example.com/image.jpg';

  @override
  String get settingsBackgroundSet => 'Taustakuva asetettu';

  @override
  String get settingsBackgroundImageSet => 'Kuva asetettu';

  @override
  String get settingsBackgroundCopyFailed => 'Kuvan kopiointi epäonnistui';

  @override
  String get settingsBackgroundUrlError =>
      'Kuva ei saatavilla (CORS tai verkko-ongelma)';

  @override
  String get settingsBackgroundDownloaded => 'Kuva ladattu';

  @override
  String get settingsBackgroundDownloadFailed => 'Kuvan lataaminen epäonnistui';

  @override
  String get settingsBackgroundUploadTitle => 'Tallenna kuva palvelimelle';

  @override
  String get settingsBackgroundUploadWarning =>
      'Kuva tallennetaan Blossom-palvelimille. Palvelimen hallinnoijat ja linkin hallussapitäjät voivat nähdä kuvan.';

  @override
  String get hostingRecommended => 'Suositeltu:';

  @override
  String hostingWillBeAddedAs(String url) {
    return 'Lisätään: $url';
  }

  @override
  String get relayAddTitle => 'Lisää palvelin';

  @override
  String get relayUrlLabel => 'Palvelimen URL';

  @override
  String get relayUrlHint => 'wss://relay.example.com';

  @override
  String get relayInvalidUrl => 'Kelvoton palvelimen URL';

  @override
  String get relayDirection => 'Suunta';

  @override
  String get relayReadWrite => 'Lue ja kirjoita';

  @override
  String get relayRead => 'Lue';

  @override
  String get relayWrite => 'Kirjoita';

  @override
  String get relayMarkerReadWrite => 'lue/kirjoita';

  @override
  String get relayMarkerRead => 'lue';

  @override
  String get relayMarkerWrite => 'kirjoita';

  @override
  String get relayInboxOutboxTitle => 'Saapuvien ja lähtevien palvelin';

  @override
  String get relayAddTooltip => 'Lisää palvelin';

  @override
  String get relayRemoveTooltip => 'Poista palvelin';

  @override
  String get relayInboxOutboxEmpty =>
      'Saapuvien/lähtevien palvelimia ei ole asetettu';

  @override
  String get relayEmptyHint => 'Paina + lisätäksesi palvelimen';

  @override
  String get dmRelayAddTitle => 'Lisää yksityisviestien palvelin';

  @override
  String get dmRelaySectionTitle => 'Yksityisviestien palvelimet';

  @override
  String get dmRelayEmpty => 'Yksityisviestien palvelimia ei ole asetettu';

  @override
  String get bridgeAddTitle => 'Lisää silta';

  @override
  String get bridgeDomainLabel => 'Sillan verkko-osoite';

  @override
  String get bridgeDomainHint => 'bridge.example.com';

  @override
  String get bridgeInvalidDomain => 'Kelvoton verkko-osoite';

  @override
  String get bridgeSectionTitle => 'Sillat';

  @override
  String get bridgeAddTooltip => 'Lisää silta';

  @override
  String get bridgeEmpty => 'Siltoja ei asetettu';

  @override
  String get bridgeEmptyHint => 'Paina + lisätäksesi sillan';

  @override
  String get bridgeDefault => 'Oletussilta';

  @override
  String get blossomAddTitle => 'Lisää Blossom-palvelimia';

  @override
  String get blossomServerUrlLabel => 'Palvelimen URL';

  @override
  String get blossomServerUrlHint => 'https://blossom.example.com';

  @override
  String get blossomInvalidUrl => 'Kelvoton palvelimen URL';

  @override
  String get blossomSectionTitle => 'Tiedostojen ylläpito';

  @override
  String get blossomAddTooltip => 'Lisää palvelin';

  @override
  String get blossomRemoveTooltip => 'Poista palvelin';

  @override
  String get blossomEmpty => 'Blossom-palvelimia ei asetettu';

  @override
  String get blossomEmptyHint => 'Paina + lisätäksesi palvelimen';

  @override
  String get connectivitySectionTitle => 'Reaaliaikainen yhteys';

  @override
  String get connectivityRelayConnectivity => 'Välityspalvelimen yhteys';

  @override
  String get syncStatusSectionTitle => 'Synkronoinnin tila';

  @override
  String get syncStatusEmpty => 'Synkronointitietoja ei saatavilla';

  @override
  String get syncStatusEmptyHint =>
      'Synkronoi posti nähdäksesi palvelimen tilan';

  @override
  String get syncStatusResync => 'Synkronoi uudelleen';

  @override
  String get syncStatusBeginningOfTime => 'Alkuhetkestä';

  @override
  String get identitiesTitle => 'Henkilöllisyydet';

  @override
  String get identitiesEmptyTitle => 'Ei henkilöllisyyksiä';

  @override
  String get identitiesEmptyMessage =>
      'Luo henkilöllisyys lähettääksesi sähköpostia mukautetusta osoitteesta.';

  @override
  String get identitiesCreate => 'Luo henkilöllisyys';

  @override
  String get identitiesDiscardTitle => 'Hylkää muutokset?';

  @override
  String get identitiesDiscardMessage =>
      'Muutoksia ei ole tallennettu. Poistuminen hävittää tehdyt muokkaukset.';

  @override
  String get identitiesKeepEditing => 'Jatka muokkausta';

  @override
  String get debugToolsEmailTesting => 'Sähköpostin testaus';

  @override
  String get debugToolsCreateOldTrashed => 'Luo vanha poistettu viesti.';

  @override
  String get debugToolsCreateOldTrashedDescription =>
      'Luo roskakoriin 31 päivää vanhan testiviestin. Käytä \"Poista vanhat viestit\" -ominaisuuden testaukseen.';

  @override
  String get folderInbox => 'Saapuneet';

  @override
  String get folderSent => 'Lähetetyt';

  @override
  String get folderTrash => 'Roskakori';

  @override
  String get folderArchive => 'Arkisto';

  @override
  String get inboxEmptyInbox => 'Ei sähköpostia';

  @override
  String get inboxEmptySent => 'Ei lähetettyjä viestejä';

  @override
  String get inboxEmptyTrash => 'Roskakori on tyhjä';

  @override
  String get inboxEmptyArchive => 'Arkisto on tyhjä';

  @override
  String get inboxSyncFromRelays => 'Synkronoi palvelimilta';

  @override
  String get inboxSearch => 'Hae';

  @override
  String get inboxSync => 'Synkronoi';

  @override
  String get inboxMenu => 'Valikko';

  @override
  String get inboxClearSelection => 'Tyhjää valinta';

  @override
  String inboxSelectedCount(int count) {
    return '$count valittu';
  }

  @override
  String get inboxProfile => 'Profiili';

  @override
  String get inboxCopyNpub => 'Kopioi npub';

  @override
  String get inboxLogout => 'Kirjaudu ulos';

  @override
  String get inboxAccount => 'Tili';

  @override
  String get inboxCompose => 'Luo sähköposti';

  @override
  String get inboxNpubCopied => 'npub kopioitu';

  @override
  String get inboxUnknown => 'Tuntematon';

  @override
  String get inboxEditProfile => 'Muokkaa profiilia';

  @override
  String get inboxSettings => 'Asetukset';

  @override
  String get inboxDeleteOldEmailsTitle => 'Poista vanha posti';

  @override
  String inboxDeleteOldEmailsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yli kuukauden vanhaa viestiä',
      one: '$count yli kuukauden vanha viesti',
    );
    return 'Poistetaan pysyvästi $_temp0.\n\nToimintoa ei voi kumota.';
  }

  @override
  String get inboxDeleteFailed => 'Poisto epäonnistui';

  @override
  String inboxDeleteFailedDescription(String error) {
    return 'Vanhan postin poisto epäonnistui: $error';
  }

  @override
  String inboxOldEmailsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vanhaa viestiä voidaan poistaa',
      one: '$count vanha viesti voidaan poistaa',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeleteNow => 'Poista nyt';

  @override
  String get inboxDeleteOldEmailsTooltip => 'Poista vanha posti';

  @override
  String get inboxSearchHint => 'Hae kaikista viesteistä...';

  @override
  String get inboxCloseSearch => 'Sulje haku';

  @override
  String get inboxSelectAll => 'Valitse kaikki';

  @override
  String get inboxMoreActions => 'Lisää toimintoja';

  @override
  String get emailReply => 'Vastaa';

  @override
  String get emailForward => 'Välitä';

  @override
  String get emailArchive => 'Arkistoi';

  @override
  String get emailUnarchive => 'Palauta arkistosta';

  @override
  String get emailMarkAsRead => 'Merkitse luetuksi';

  @override
  String get emailMarkAsUnread => 'Merkitse lukemattomaksi';

  @override
  String get emailMoveToTrash => 'Siirrä roskakoriin';

  @override
  String get emailRestore => 'Palauta';

  @override
  String get emailDeletePermanently => 'Poista pysyvästi';

  @override
  String get emailNoSubject => '(Ei aihetta)';

  @override
  String emailExtraRecipients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count muuta vastaanottajaa',
      one: '$count muu vastaanottaja',
    );
    return '$_temp0';
  }

  @override
  String get emailNotFound => 'Sähköpostia ei löydy';

  @override
  String get emailShowFormatted => 'Näytä muotoilu';

  @override
  String get emailShowRaw => 'Näytä muotoilematon';

  @override
  String emailSenderNpub(String npub) {
    return 'Lähettäjän npub: $npub';
  }

  @override
  String get emailDeletePermanentlyTitle => 'Poista pysyvästi?';

  @override
  String get emailDeletePermanentlyMessage => 'Toimintoa ei voi kumota.';

  @override
  String get emailDefaultFilename => 'sähköposti';

  @override
  String emailSaved(String path) {
    return 'Sähköposti tallennettu: $path';
  }

  @override
  String emailSaveFailed(String error) {
    return 'Sähköpostin tallennus epäonnistui: $error';
  }

  @override
  String get emailRawContentUnavailable => 'Viestin sisältöä ei voida ladata';

  @override
  String get emailRepostFailedEvent =>
      'Viestin Nostr-tapahtumaa ei voida ladata uudelleenlähetystä varten';

  @override
  String get emailRepostSuccess => 'Viesti lähetetty uudelleen';

  @override
  String emailRepostFailed(String error) {
    return 'Viestin uudelleenlähetys epäonnistui: $error';
  }

  @override
  String get emailAttachmentLoadFailed => 'Liitteen lataaminen epäonnistui';

  @override
  String emailFileSaved(String path) {
    return 'Tiedosto tallennettu: $path';
  }

  @override
  String emailFileSaveFailed(String error) {
    return 'Tiedoston tallennus epäonnistui: $error';
  }

  @override
  String emailDownloadedAllSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ladattiin $count tiedostoa',
      one: 'Ladattiin $count tiedosto',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tiedoston lataaminen epäonnistui',
      one: '$count tiedoston lataaminen epäonnistui',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedMixed(int success, int failed) {
    return 'Ladattiin $success tiedostoa, $failed epäonnistui';
  }

  @override
  String get emailDownload => 'Lataa';

  @override
  String get emailImageLoadFailed => 'Kuvan lataus epäonnistui';

  @override
  String get emailPdfLoadFailed => 'PDF:n lataus epäonnistui';

  @override
  String get emailActionReply => 'Vastaa';

  @override
  String get emailActionReplyAll => 'Vastaa kaikille';

  @override
  String get emailActionForward => 'Välitä';

  @override
  String get emailActionArchive => 'Arkistoi';

  @override
  String get emailActionUnarchive => 'Palauta arkistosta';

  @override
  String get emailActionMarkRead => 'Merkitse luetuksi';

  @override
  String get emailActionMarkUnread => 'Merkitse lukemattomaksi';

  @override
  String get emailActionNip59 => 'NIP-59 tapahtumat';

  @override
  String get emailActionRepost => 'Lähetä uudelleen';

  @override
  String get emailActionDownload => 'Lataa viesti';

  @override
  String get emailMoreActions => 'Lisää toimintoja';

  @override
  String get emailMoreOptions => 'Lisää vaihtoehtoja';

  @override
  String get emailShowRecipients => 'Näytä vastaanottajat';

  @override
  String get emailImagesHidden => 'Kuvat piilotetaan yksityisyyden vuoksi';

  @override
  String get emailLoadImages => 'Lataa kuvat';

  @override
  String get emailRecipientTo => 'Vastaanottaja';

  @override
  String get emailRecipientCc => 'Kopio';

  @override
  String get emailRecipientBcc => 'Piilokopio';

  @override
  String get emailAttachmentsTitle => 'Liitteet';

  @override
  String get emailDownloadAll => 'Lataa kaikki';

  @override
  String get emailNip59Dismiss => 'Unohda';

  @override
  String get emailNip59Title => 'NIP-59 tapahtumat';

  @override
  String get emailNip59GiftWrap => 'Gift Wrap (Nostr-lahjakääre)';

  @override
  String get emailNip59Seal => 'Seal (Nostr-sinetti)';

  @override
  String get emailNip59Rumor => 'Rumor (Nostr-huhu)';

  @override
  String get emailNip59CopyJson => 'Kopioi JSON';

  @override
  String emailNip59Kind(int kind) {
    return 'Kind $kind (Nostr-tyyppi)';
  }

  @override
  String get emailNip59NotAvailable => 'Ei saatavilla';

  @override
  String get authHeaderTitle => 'Kirjaudu Nmailiin';

  @override
  String get authSyncCodeLabel => 'Synkronointikoodi';

  @override
  String get authInvalidSyncCode => 'Kelvoton synkronointikoodi';

  @override
  String get authInvalidSyncCodeDescription =>
      'Koodi tarkistetaan kirjoitettaessa. Kun koodi kelpaa, sinut kirjataan välittömästi sisään.';

  @override
  String get authLogIn => 'Kirjaudu';

  @override
  String get authCreateAccount => 'Luo tili';

  @override
  String get authMoreOptions => 'Lisää vaihtoehtoja';

  @override
  String get authRegisterPrompt => 'Mitä muut näkevät?';

  @override
  String get authDisplayNameLabel => 'Näyttönimi';

  @override
  String get authDisplayNameHint => 'esim. Liisa';

  @override
  String get authBackToLogin => 'Palaa kirjautumiseen';

  @override
  String get authUnableRetrieveCode => 'Synkronointikoodia ei voi hakea';

  @override
  String get authYourSyncCode => 'Synkronointikoodisi';

  @override
  String get authSyncCodeIntro =>
      'Koodi on salasanan kaltainen avain tilillesi. Se antaa täydet valtuudet tilillesi. Sillä voi myös:';

  @override
  String get authSyncCodeFeatureRestore =>
      'Palauttaa tilisi millä tahansa laitteella';

  @override
  String get authSyncCodeFeatureBackup =>
      'Varmuuskopioida tietosi turvallisesti';

  @override
  String get authSyncCodeFeatureLogin => 'Kirjautua muihin Nostr-sovelluksiin';

  @override
  String get authSyncCodeWarning =>
      'Älä koskaan jaa tätä koodia kenenkään kanssa. Talleta se turvallisesti. Koodi löytyy Asetuksista myöhemminkin.';

  @override
  String get authCopied => 'Kopioitu!';

  @override
  String get authCopySyncCode => 'Kopioi synkronointikoodi';

  @override
  String get authContinueToInbox => 'Jatka Saapuneet-kansioon';

  @override
  String get composeTitle => 'Luo sähköpostiviesti';

  @override
  String get composeTo => 'Vastaanottaja';

  @override
  String get composeAddMore => 'Lisää';

  @override
  String get composeHideExpanded => 'Piilota lisäkentät';

  @override
  String get composeShowExpanded => 'Näytä lisäkentät';

  @override
  String get composeCc => 'Kopio';

  @override
  String get composeBcc => 'Piilokopio';

  @override
  String get composeSubject => 'Aihe';

  @override
  String get composeAttachFile => 'Liitä tiedosto';

  @override
  String get composePlaceholder => 'Kirjoita viesti';

  @override
  String get composeFrom => 'Lähettäjä';

  @override
  String get composeSendAs => 'Lähetä henkilöllisyydellä';

  @override
  String get composeCreateNewIdentity => 'Luo henkilöllisyys';

  @override
  String get composeRemoveAttachment => 'Poista liite';

  @override
  String get composeSend => 'Lähetä';

  @override
  String get composeMoreSendOptions => 'Lähetysvalinnat';

  @override
  String get composeChooseSendMode => 'Valitse lähetystapa';

  @override
  String get composeModePrivateDeniable =>
      'Yksityinen, alkuperä kiistettävissä';

  @override
  String get composeModePrivateSigned => 'Yksityinen, allekirjoitettu';

  @override
  String get composeModePublic => 'Julkinen';

  @override
  String get composeModePrivateDeniableDescription =>
      'Lähetä salattuna sähköpostina. Allekirjoittamaton eli viestin alkuperä on tarvittaessa kiistettävissä.';

  @override
  String get composeModePrivateSignedDescription =>
      'Lähetä salattuna sähköpostina. Allekirjoitettu eli osoittaa sinut lähettäjäksi.';

  @override
  String get composeModePublicDescription =>
      'Lähetä julkisena Nostr-tapahtumana. Salaamaton viesti, jonka kuka tahansa voi lukea.';

  @override
  String get composeResolvingNip05 => 'Selvitetään NIP-05...';

  @override
  String get contactSourceAddressBook => 'Osoitekirja';

  @override
  String get contactSourceEmailHistory => 'Sähköpostihistoria';

  @override
  String get contactSourceFollowing => 'Seurataan';

  @override
  String get contactSourceCachedProfile => 'Välimuistissa oleva profiili';

  @override
  String get contactSourceNip05Verified => 'NIP-05 vahvistettu';

  @override
  String get contactsTitle => 'Yhteystiedot';

  @override
  String get contactsAdd => 'Lisää yhteystieto';

  @override
  String get contactsAddToContacts => 'Lisää yhteystietoihin';

  @override
  String get contactsSync => 'Synkronoi yhteystiedot';

  @override
  String get contactsRetry =>
      'Yritä odottavia yhteystietopäivityksiä uudelleen';

  @override
  String get contactsSearchHint => 'Hae yhteystietoja';

  @override
  String get contactsEmpty => 'Ei vielä yhteystietoja';

  @override
  String get contactsSearchEmpty => 'Ei vastaavia yhteystietoja';

  @override
  String get contactsSelectPrompt => 'Valitse yhteystieto';

  @override
  String get contactsCreateTitle => 'Uusi yhteystieto';

  @override
  String get contactsEditTitle => 'Muokkaa yhteystietoa';

  @override
  String get contactsNameLabel => 'Nimi';

  @override
  String get contactsEmailsLabel => 'Sähköpostiosoitteet';

  @override
  String get contactsMultilineHint => 'Yksi per rivi';

  @override
  String get contactsAddEmailHint => 'Lisää sähköpostiosoite';

  @override
  String get contactsPhonesLabel => 'Puhelinnumerot';

  @override
  String get contactsAddPhoneHint => 'Lisää puhelinnumero';

  @override
  String get contactsBirthdayLabel => 'Syntymäpäivä';

  @override
  String get contactsBirthdayAdd => 'Lisää syntymäpäivä';

  @override
  String get contactsBirthdayDayLabel => 'Päivä';

  @override
  String get contactsBirthdayMonthLabel => 'Kuukausi';

  @override
  String get contactsBirthdayYearLabel => 'Vuosi';

  @override
  String get contactsBirthdayHint => 'VVVV-KK-PP';

  @override
  String get contactsNostrLabel => 'Nostr-identiteetit';

  @override
  String get contactsNostrHint =>
      'npub, nprofile, hex-julkinen avain tai NIP-05';

  @override
  String get contactsAddNostrHint =>
      'Lisää npub, nprofile, hex-julkinen avain tai NIP-05';

  @override
  String get contactsCancel => 'Peruuta';

  @override
  String get contactsSave => 'Tallenna';

  @override
  String get contactsEdit => 'Muokkaa yhteystietoa';

  @override
  String get contactsCopyVCard => 'Kopioi vCard';

  @override
  String get contactsVCardCopied => 'vCard kopioitu';

  @override
  String get contactsDelete => 'Poista';

  @override
  String get contactsDeleteTitle => 'Poistetaanko yhteystieto?';

  @override
  String get contactsDeleteBody =>
      'Tämä poistaa yhteystiedon yksityisestä osoitekirjastasi.';

  @override
  String get contactsEmailsTitle => 'Sähköposti';

  @override
  String get contactsPhonesTitle => 'Puhelin';

  @override
  String get contactsBirthdayTitle => 'Syntymäpäivä';

  @override
  String get contactsNostrTitle => 'Nostr';

  @override
  String get contactsCall => 'Soita';

  @override
  String get contactsSendSms => 'Lähetä tekstiviesti';

  @override
  String get contactsImport => 'Tuo yhteystiedot';

  @override
  String get contactsExport => 'Vie yhteystiedot';

  @override
  String get contactsExportEmpty => 'Ei vietäviä yhteystietoja';

  @override
  String contactsExportSaved(String path) {
    return 'Yhteystiedot viety: $path';
  }

  @override
  String contactsExportFailed(String error) {
    return 'Yhteystietojen vienti epäonnistui: $error';
  }

  @override
  String get contactsImportEmpty => 'Tiedostosta ei löytynyt yhteystietoja';

  @override
  String contactsImportFailed(String error) {
    return 'Yhteystietojen tuonti epäonnistui: $error';
  }

  @override
  String contactsImportSummary(int imported, int skipped) {
    return '$imported tuotu, $skipped ohitettu';
  }

  @override
  String get contactsImportConflictTitle => 'Yhteystiedot ovat jo olemassa';

  @override
  String contactsImportConflictBody(int count) {
    return '$count tuotavista yhteystiedoista on jo olemassa. Miten ne käsitellään?';
  }

  @override
  String get contactsImportMergeAll => 'Yhdistä kaikki';

  @override
  String get contactsImportReplaceAll => 'Korvaa kaikki';

  @override
  String get contactsImportSkip => 'Ohita kaksoiskappaleet';

  @override
  String get profileEditTitle => 'Muokkaa profiilia';

  @override
  String get profileDisplayNameLabel => 'Näyttönimi';

  @override
  String get profileDisplayNameHint => 'Koko nimesi tai alias';

  @override
  String get profileUsernameLabel => 'Käyttäjänimi';

  @override
  String get profileUsernameHint => 'käyttäjänimi';

  @override
  String get profileAboutLabel => 'Tietoja';

  @override
  String get profileAboutHint => 'Lyhyt esittelyteksti';

  @override
  String get profileAdvanced => 'Edistyneet';

  @override
  String get profilePictureUrlLabel => 'Kuvan URL';

  @override
  String get profilePictureUrlHint => 'https://example.com/avatar.png';

  @override
  String get profileChangePicture => 'Vaihda profiilikuva';

  @override
  String get onboardingPage1Title => 'Tervetuloa Nmailiin';

  @override
  String get onboardingPage1Body =>
      'Hajautettu sähköposti, jossa sinä omistat omat viestisi. Uusi henkilökohtainen tapa viestiä.';

  @override
  String get onboardingPage2Title => 'Verkko ilman hallitsijaa.';

  @override
  String get onboardingPage2Body =>
      'Viestisi liikkuvat maailmanlaajuisen itsenäisten palvelinten verkon läpi. Mikään yksittäinen yritys ei omista viestejäsi.';

  @override
  String get onboardingPage3Title => 'Valinnanvapaus';

  @override
  String get onboardingPage3Body =>
      'Sinua ei lukita yhteen palveluntarjoajaan. Vaihda siltoja tai välityspalvelimia milloin vain menettämättä tilisi hallintaa tai yhteystietojasi.';

  @override
  String get onboardingPage4Title => 'Yhtenäinen identiteetti joka paikassa';

  @override
  String get onboardingPage4Body =>
      'Käytä tiliäsi sähköpostissa, sosiaalisessa mediassa tai muissa sovelluksissa. Yksi pysyvä identiteetti toimii erilaisissa sovelluksissa.';

  @override
  String get onboardingPage5Title => 'Rakennettu tulevaisuutta varten';

  @override
  String get onboardingPage5Body =>
      'Nykyaikainen yksityinen arkkitehtuuri. Nmail auttaa siirtymään helposti turvallisempaan, joustavampaan ja vähemmän haavoittuvaan viestintään.';

  @override
  String get onboardingPage6Title => 'Varhainen kehitysversio';

  @override
  String get onboardingPage6Body =>
      'Nmail ja sen taustaprotokolla ovat uusia. Kaikki on pyritty rakentamaan toimivaksi, mutta bugeja voi esiintyä. Jotkut sähköpostilta odotetut toiminnot voivat tuntua hitailta tai puuttua vielä kokonaan. Kiitos varhaisen kehityksen tukemisesta. Kärsivällisyytesi auttaa muovaamaan tulevaisuutta.';

  @override
  String get onboardingSkip => 'Ohita';

  @override
  String get onboardingNext => 'Seuraava';

  @override
  String get onboardingDone => 'Valmis';

  @override
  String get createIdentityTitle => 'Luo henkilöllisyys';

  @override
  String get createIdentityAddress => 'Osoite';

  @override
  String get createIdentityCustomUsername => 'Mukautettu käyttäjänimi';

  @override
  String get createIdentityBridge => 'Silta';

  @override
  String get createIdentityNoBridges => 'Siltoja ei saatavilla';

  @override
  String get createIdentityBridgeHint => 'bridge.com';

  @override
  String get createIdentityPreview => 'Esikatselu';

  @override
  String get createIdentityPreviewEmpty =>
      'Valitse osoite ja silta nähdäksesi esikatselun';

  @override
  String get createIdentityAlreadyExists => 'Tämä identiteetti on jo olemassa';

  @override
  String get leftRailSettings => 'Asetukset';

  @override
  String get linkOpenTitle => 'Avaa linkki?';

  @override
  String get linkCopied => 'Linkki kopioitu';

  @override
  String get debugNotAuthenticated => 'Ei todennettu';

  @override
  String get debugTestEmailCreated =>
      'Luotu ja poistettu testiviesti (31 päivää vanha)';

  @override
  String get debugTestEmailPartial =>
      'Viesti luotu ja poistettu, mutta aikaleiman päivitys epäonnistui';

  @override
  String debugError(String error) {
    return 'Virhe: $error';
  }

  @override
  String get composeSelectAttachments => 'Valitse liitteet';

  @override
  String composePickFilesFailed(String error) {
    return 'Tiedostojen valinta epäonnistui: $error';
  }

  @override
  String get composeInvalidRecipient => 'Vastaanottajan osoite ei kelpaa';

  @override
  String get composeAddRecipient => 'Lisää vähintään yksi vastaanottaja';

  @override
  String get composeSendFailed => 'Viestin lähetys epäonnistui';

  @override
  String get profileLoadFailed => 'Profiilitietojen haku epäonnistui';

  @override
  String get profileSelectPicture => 'Valitse profiilikuva';

  @override
  String get profileUploadNoServers => 'Yksikään palvelin ei vastaa';

  @override
  String get profileUploadFailed => 'Palvelimelle tallentaminen epäonnistui';

  @override
  String get profileUploadError =>
      'Palvelimelle tallentamisessa tapahtui virhe';

  @override
  String get profileUpdateFailed => 'Profiilin päivitys epäonnistui';

  @override
  String get authEnterUsername => 'Anna käyttäjänimi';

  @override
  String createIdentityFailed(String error) {
    return 'Henkilöllisyyden luonti epäonnistui: $error';
  }

  @override
  String get dateYesterday => 'Eilen';

  @override
  String get notFoundTitle => 'Sivua ei löydy';

  @override
  String get notFoundBackToInbox => 'Palaa saapuneisiin';
}
