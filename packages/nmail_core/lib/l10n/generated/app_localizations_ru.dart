// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionClear => 'Очистить';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionCopy => 'Копировать';

  @override
  String get actionOpen => 'Открыть';

  @override
  String get actionUpload => 'Загрузить';

  @override
  String get actionReset => 'Сбросить';

  @override
  String get actionUndo => 'Отменить';

  @override
  String get actionRemove => 'Удалить';

  @override
  String get actionDiscard => 'Отбросить';

  @override
  String get actionKeepEditing => 'Продолжить редактирование';

  @override
  String get discardChangesTitle => 'Отбросить изменения?';

  @override
  String get discardChangesMessage =>
      'У вас есть несохранённые изменения. Если выйти сейчас, они будут потеряны.';

  @override
  String get stateLoadingEllipsis => 'Загрузка...';

  @override
  String get stateResetting => 'Сброс...';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsBackground => 'Фон';

  @override
  String get settingsDynamicTheme => 'Динамическая тема';

  @override
  String get settingsDynamicThemeSubtitle =>
      'Создавать цвета из фонового изображения';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Язык системы';

  @override
  String get settingsLanguageDialogTitle => 'Выберите язык';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsMessages => 'Сообщения';

  @override
  String get settingsEnableNotifications => 'Включить уведомления';

  @override
  String get settingsEnableNotificationsSubtitle =>
      'Получайте уведомления о новых письмах.';

  @override
  String get settingsUnifiedPushDistributorMissingTitle =>
      'Push-уведомления недоступны';

  @override
  String get settingsUnifiedPushDistributorMissingSubtitle =>
      'Установите дистрибьютор UnifiedPush, например Sunup, чтобы получать уведомления в фоновом режиме.';

  @override
  String get settingsUnifiedPushDistributorInstallSunup => 'Установить Sunup';

  @override
  String get settingsAlwaysLoadImages => 'Всегда загружать изображения';

  @override
  String get settingsAlwaysLoadImagesSubtitle =>
      'По умолчанию изображения блокируются для приватности';

  @override
  String get settingsIdentities => 'Идентичности';

  @override
  String get settingsEmailSignature => 'Подпись письма';

  @override
  String get settingsEmailSignatureEmpty => 'Подпись не настроена';

  @override
  String get settingsEmailSignatureHint => 'Введите вашу подпись...';

  @override
  String get settingsHosting => 'Хостинг';

  @override
  String get settingsDebugTools => 'Инструменты отладки';

  @override
  String get settingsCopySyncCode => 'Скопировать код синхронизации';

  @override
  String get settingsSyncCodeCopied => 'Код синхронизации скопирован';

  @override
  String get settingsLogOut => 'Выйти';

  @override
  String get settingsResetApplication => 'Сбросить приложение';

  @override
  String get settingsResetConfirmMessage =>
      'Все локальные данные, включая настройки и фоновые изображения, будут удалены, и вы выйдете из аккаунта.\n\nЭто действие нельзя отменить.';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsDeveloper => 'Разработчик';

  @override
  String get settingsLicense => 'Лицензия';

  @override
  String get settingsSourceCode => 'Исходный код';

  @override
  String get settingsSourceCodeSubtitle => 'Посмотреть на GitHub';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Сведения о конфиденциальности для Apple App Store';

  @override
  String get settingsEarlyAccess => 'Ранний доступ';

  @override
  String get settingsEarlyAccessMessage =>
      'Nmail и протокол, лежащий в его основе, ещё очень молоды. Всё сделано, чтобы работать как можно лучше, но могут возникать ошибки, а что-то может казаться медленным или отсутствующим. Спасибо, что вы один из первых пользователей.';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeAuto => 'Авто';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsBackgroundDefaultLabel => 'Цвет темы по умолчанию';

  @override
  String get settingsBackgroundSelectLabel => 'Выбрать фоновое изображение';

  @override
  String get settingsBackgroundDeleteLabel => 'Удалить фоновое изображение';

  @override
  String get settingsBackgroundRemoveLabel => 'Убрать фоновое изображение';

  @override
  String get settingsBackgroundAddLabel => 'Добавить фоновое изображение';

  @override
  String get settingsBackgroundDeleteTitle => 'Удалить фон';

  @override
  String get settingsBackgroundDeleteMessage =>
      'Убрать это изображение из сохранённых фонов?';

  @override
  String get settingsBackgroundDeleteFailed => 'Не удалось удалить изображение';

  @override
  String get settingsBackgroundDialogTitle => 'Фон';

  @override
  String get settingsBackgroundSelectFile => 'Выбрать файл';

  @override
  String get settingsBackgroundPasteUrl => 'Вставить URL';

  @override
  String get settingsBackgroundUrlTitle => 'URL фона';

  @override
  String get settingsBackgroundUrlHint => 'https://example.com/image.jpg';

  @override
  String get settingsBackgroundCopyFailed =>
      'Не удалось скопировать изображение';

  @override
  String get settingsBackgroundUrlError =>
      'Изображение недоступно (ошибка CORS или сети)';

  @override
  String get settingsBackgroundDownloadFailed =>
      'Не удалось скачать изображение';

  @override
  String get settingsBackgroundUploadTitle => 'Загрузить изображение';

  @override
  String get settingsBackgroundUploadWarning =>
      'Это изображение будет загружено на серверы Blossom. Операторы серверов и все, у кого есть ссылка, смогут его видеть.';

  @override
  String get hostingRecommended => 'Рекомендуемые:';

  @override
  String hostingWillBeAddedAs(String url) {
    return 'Будет добавлено как: $url';
  }

  @override
  String get relayAddTitle => 'Добавить реле';

  @override
  String get relayUrlLabel => 'URL реле';

  @override
  String get relayUrlHint => 'wss://relay.example.com';

  @override
  String get relayInvalidUrl => 'Недействительный URL реле';

  @override
  String get relayDirection => 'Направление';

  @override
  String get relayReadWrite => 'Чтение и запись';

  @override
  String get relayRead => 'Чтение';

  @override
  String get relayWrite => 'Запись';

  @override
  String get relayMarkerReadWrite => 'чтение/запись';

  @override
  String get relayMarkerRead => 'чтение';

  @override
  String get relayMarkerWrite => 'запись';

  @override
  String get relayInboxOutboxTitle => 'Реле входящих/исходящих';

  @override
  String get relayInboxOutboxDescription =>
      'Реле, куда ваш аккаунт публикует и откуда читает.';

  @override
  String get relayAdd => 'Добавить реле';

  @override
  String get relayRemoveTooltip => 'Удалить реле';

  @override
  String get relayInboxOutboxEmpty => 'Реле входящих/исходящих не настроены';

  @override
  String get dmRelayAddTitle => 'Добавить DM-реле';

  @override
  String get dmRelaySectionTitle => 'DM-реле';

  @override
  String get dmRelayDescription =>
      'Реле, которые принимают ваши зашифрованные сообщения.';

  @override
  String get dmRelayAdd => 'Добавить DM-реле';

  @override
  String get dmRelayEmpty => 'DM-реле не настроены';

  @override
  String get bridgeAddTitle => 'Добавить мост';

  @override
  String get bridgeDomainLabel => 'Домен моста';

  @override
  String get bridgeDomainHint => 'bridge.example.com';

  @override
  String get bridgeInvalidDomain => 'Недействительный домен';

  @override
  String get bridgeSectionTitle => 'Мосты';

  @override
  String get bridgeDescription =>
      'Домены, которые дают вам обычный адрес электронной почты.';

  @override
  String get bridgeAdd => 'Добавить мост';

  @override
  String get bridgeEmpty => 'Мосты не настроены';

  @override
  String get bridgeDefault => 'Мост по умолчанию';

  @override
  String get blossomAddTitle => 'Добавить сервер Blossom';

  @override
  String get blossomServerUrlLabel => 'URL сервера';

  @override
  String get blossomServerUrlHint => 'https://blossom.example.com';

  @override
  String get blossomInvalidUrl => 'Недействительный URL сервера';

  @override
  String get blossomSectionTitle => 'Хостинг файлов';

  @override
  String get blossomDescription =>
      'Серверы, где хранятся ваши вложения и изображения.';

  @override
  String get blossomAdd => 'Добавить сервер';

  @override
  String get blossomRemoveTooltip => 'Удалить сервер';

  @override
  String get blossomEmpty => 'Серверы Blossom не настроены';

  @override
  String get connectivitySectionTitle => 'Подключение в реальном времени';

  @override
  String connectivityConnectedCount(int connected, int total) {
    return 'Подключено реле: $connected из $total';
  }

  @override
  String get connectivityConnected => 'Подключено';

  @override
  String get connectivityDisconnected => 'Нет подключения';

  @override
  String get syncStatusSectionTitle => 'Статус синхронизации';

  @override
  String get syncStatusEmpty => 'Нет данных о синхронизации';

  @override
  String get syncStatusResync => 'Пересинхронизировать';

  @override
  String get syncStatusResyncSubtitle =>
      'Заново прочитать все сообщения с ваших реле.';

  @override
  String get syncStatusBeginningOfTime => 'Начало времён';

  @override
  String get identitiesTitle => 'Идентичности';

  @override
  String get identitiesEmptyTitle => 'Идентичностей пока нет';

  @override
  String get identitiesEmptyMessage =>
      'Создайте одну, чтобы отправлять письма с собственного адреса.';

  @override
  String get identitiesCreate => 'Создать идентичность';

  @override
  String get accountsTitle => 'Аккаунты';

  @override
  String get accountsManage => 'Управление аккаунтами';

  @override
  String get accountsRemove => 'Удалить аккаунт';

  @override
  String get accountsRemoveTitle => 'Удалить этот аккаунт?';

  @override
  String accountsRemoveMessage(String name) {
    return '$name будет удалён с этого устройства, а его локальные данные стёрты: письма, контакты и настройки. На реле ничего не удаляется.';
  }

  @override
  String get accountsRemoveKeyWarning =>
      'Сначала сохраните код синхронизации этого аккаунта. Без него войти снова не получится.';

  @override
  String get accountsRemoveLastWarning =>
      'Это ваш последний аккаунт, поэтому вы выйдете из приложения.';

  @override
  String get accountsRemoveFailed => 'Не удалось удалить этот аккаунт';

  @override
  String get accountSignerPrivateKey => 'Код синхронизации';

  @override
  String get accountSignerExtension => 'Расширение браузера';

  @override
  String get accountSignerApp => 'Приложение для подписи';

  @override
  String get accountSignerBunker => 'Удалённая подпись';

  @override
  String get accountSignerExternal => 'Внешняя подпись';

  @override
  String get debugToolsEmailTesting => 'Тестирование писем';

  @override
  String get debugToolsCreateOldTrashed => 'Создать старое письмо в корзине';

  @override
  String get debugToolsCreateOldTrashedDescription =>
      'Создаёт тестовое письмо в корзине возрастом 31 день. Используйте, чтобы протестировать функцию «Удалить старые письма».';

  @override
  String get debugToolsTriggerNotification => 'Показать тестовое уведомление';

  @override
  String get debugToolsTriggerNotificationDescription =>
      'Показывает локальное уведомление, как будто пришло новое письмо, чтобы проверить отображение уведомления и обработку нажатия.';

  @override
  String get debugNotificationPermissionDenied =>
      'Разрешение на уведомления отклонено.';

  @override
  String get folderInbox => 'Входящие';

  @override
  String get folderSent => 'Отправленные';

  @override
  String get folderTrash => 'Корзина';

  @override
  String get folderArchive => 'Архив';

  @override
  String get folderScheduled => 'Запланированные';

  @override
  String get inboxEmptyInbox => 'Писем пока нет';

  @override
  String get inboxEmptySent => 'Нет отправленных писем';

  @override
  String get inboxEmptyTrash => 'Корзина пуста';

  @override
  String get inboxEmptyArchive => 'Архив пуст';

  @override
  String get inboxSyncFromRelays => 'Синхронизировать с реле';

  @override
  String get inboxSearch => 'Поиск';

  @override
  String get inboxSync => 'Синхронизация';

  @override
  String get inboxMenu => 'Меню';

  @override
  String get inboxClearSelection => 'Снять выделение';

  @override
  String inboxSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get inboxProfile => 'Профиль';

  @override
  String get inboxCopyNpub => 'Скопировать npub';

  @override
  String get inboxAddAccount => 'Добавить аккаунт';

  @override
  String get inboxLogout => 'Выйти';

  @override
  String get inboxAccount => 'Аккаунт';

  @override
  String get inboxCompose => 'Написать';

  @override
  String get inboxNpubCopied => 'npub скопирован';

  @override
  String get inboxUnknown => 'Неизвестно';

  @override
  String get inboxEditProfile => 'Редактировать профиль';

  @override
  String get inboxSettings => 'Настройки';

  @override
  String get inboxDeleteOldEmailsTitle => 'Удалить старые письма';

  @override
  String inboxDeleteOldEmailsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count письма',
      many: '$count писем',
      few: '$count письма',
      one: '$count письмо',
    );
    return 'Это навсегда удалит $_temp0 старше 30 дней.\n\nЭто действие нельзя отменить.';
  }

  @override
  String get inboxDeleteFailed => 'Ошибка удаления';

  @override
  String inboxDeleteFailedDescription(String error) {
    return 'Не удалось удалить старые письма: $error';
  }

  @override
  String inboxOldEmailsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count старых писем к удалению',
      many: '$count старых писем к удалению',
      few: '$count старых письма к удалению',
      one: '$count старое письмо к удалению',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeleteNow => 'Удалить сейчас';

  @override
  String get inboxDeleteOldEmailsTooltip => 'Удалить старые письма';

  @override
  String get inboxSearchHint => 'Поиск по всем письмам...';

  @override
  String get inboxCloseSearch => 'Закрыть поиск';

  @override
  String get inboxSelectAll => 'Выделить всё';

  @override
  String get inboxMoreActions => 'Больше действий';

  @override
  String get emailReply => 'Ответить';

  @override
  String get emailForward => 'Переслать';

  @override
  String get emailArchive => 'В архив';

  @override
  String get emailUnarchive => 'Из архива';

  @override
  String get emailMarkAsRead => 'Отметить как прочитанное';

  @override
  String get emailMarkAsUnread => 'Отметить как непрочитанное';

  @override
  String get emailMoveToTrash => 'В корзину';

  @override
  String get emailRestore => 'Восстановить';

  @override
  String get emailDeletePermanently => 'Удалить навсегда';

  @override
  String get emailNoSubject => '(Без темы)';

  @override
  String emailExtraRecipients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ещё $count получателя',
      many: 'ещё $count получателей',
      few: 'ещё $count получателя',
      one: 'ещё $count получатель',
    );
    return '$_temp0';
  }

  @override
  String get emailNotFound => 'Письмо не найдено';

  @override
  String emailSenderNpub(String npub) {
    return 'npub отправителя: $npub';
  }

  @override
  String get emailDeletePermanentlyTitle => 'Удалить навсегда?';

  @override
  String get emailDeletePermanentlyMessage => 'Это действие нельзя отменить.';

  @override
  String get emailDefaultFilename => 'email';

  @override
  String emailSaved(String path) {
    return 'Письмо сохранено: $path';
  }

  @override
  String emailSaveFailed(String error) {
    return 'Не удалось сохранить письмо: $error';
  }

  @override
  String get emailRawContentUnavailable =>
      'Не удалось загрузить содержимое письма';

  @override
  String get emailRepostFailedEvent =>
      'Не удалось получить событие для репоста';

  @override
  String get emailRepostSuccess => 'Письмо успешно репостнуто';

  @override
  String emailRepostFailed(String error) {
    return 'Не удалось репостнуть письмо: $error';
  }

  @override
  String get emailAttachmentLoadFailed => 'Не удалось загрузить вложение';

  @override
  String get emailFileSaved => 'Вложение сохранено в «Загрузки»';

  @override
  String emailFileSaveFailed(String error) {
    return 'Не удалось сохранить файл: $error';
  }

  @override
  String emailDownloadedAllSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скачано $count файла',
      many: 'Скачано $count файлов',
      few: 'Скачано $count файла',
      one: 'Скачан $count файл',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не удалось скачать $count файла',
      many: 'Не удалось скачать $count файлов',
      few: 'Не удалось скачать $count файла',
      one: 'Не удалось скачать $count файл',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedMixed(int success, int failed) {
    return 'Скачано: $success, с ошибкой: $failed';
  }

  @override
  String get emailDownload => 'Скачать';

  @override
  String get emailImageLoadFailed => 'Не удалось загрузить изображение';

  @override
  String get emailPdfLoadFailed => 'Не удалось загрузить PDF';

  @override
  String get emailActionReply => 'Ответить';

  @override
  String get emailActionReplyAll => 'Ответить всем';

  @override
  String get emailActionForward => 'Переслать';

  @override
  String get emailActionArchive => 'В архив';

  @override
  String get emailActionUnarchive => 'Из архива';

  @override
  String get emailActionMarkRead => 'Прочитано';

  @override
  String get emailActionMarkUnread => 'Непрочитано';

  @override
  String get emailActionNip59 => 'События NIP-59';

  @override
  String get emailActionRepost => 'Репост';

  @override
  String get emailActionDownload => 'Скачать письмо';

  @override
  String get emailActionViewSource => 'Показать исходный код';

  @override
  String get emailMoreActions => 'Больше действий';

  @override
  String get emailMoreOptions => 'Больше опций';

  @override
  String get emailShowRecipients => 'Показать получателей';

  @override
  String get emailImagesHidden => 'Изображения скрыты для приватности';

  @override
  String get emailLoadImages => 'Загрузить изображения';

  @override
  String get emailRecipientTo => 'Кому';

  @override
  String get emailRecipientCc => 'Копия';

  @override
  String get emailRecipientBcc => 'Скрытая копия';

  @override
  String get emailAttachmentsTitle => 'Вложения';

  @override
  String get emailDownloadAll => 'Скачать всё';

  @override
  String get emailNip59Dismiss => 'Закрыть';

  @override
  String get emailNip59Title => 'События NIP-59';

  @override
  String get emailNip59GiftWrap => 'Gift Wrap';

  @override
  String get emailNip59Seal => 'Seal';

  @override
  String get emailNip59Rumor => 'Rumor';

  @override
  String get emailNip59CopyJson => 'Скопировать JSON';

  @override
  String emailNip59Kind(int kind) {
    return 'Kind $kind';
  }

  @override
  String get emailNip59NotAvailable => 'Недоступно';

  @override
  String get authHeaderTitle => 'Вход в Nmail';

  @override
  String get authSyncCodeLabel => 'Код синхронизации';

  @override
  String get authInvalidSyncCode => 'Недействительный код синхронизации';

  @override
  String get authInvalidSyncCodeDescription =>
      'Мы проверяем ваш код по мере ввода. Как только он станет действительным, вы войдёте автоматически.';

  @override
  String get authLogIn => 'Войти';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authMoreOptions => 'Больше опций';

  @override
  String get authRegisterPrompt => 'Что увидят другие?';

  @override
  String get authDisplayNameLabel => 'Отображаемое имя';

  @override
  String get authDisplayNameHint => 'например, Алиса';

  @override
  String get authBackToLogin => 'Назад ко входу';

  @override
  String get authUnableRetrieveCode => 'Не удалось получить код синхронизации';

  @override
  String get authYourSyncCode => 'Ваш код синхронизации';

  @override
  String get authSyncCodeIntro =>
      'Этот код — ключ к вашему аккаунту. Он даёт полный контроль и позволяет:';

  @override
  String get authSyncCodeFeatureRestore =>
      'Восстанавливать аккаунт на любом устройстве';

  @override
  String get authSyncCodeFeatureBackup =>
      'Безопасно резервировать вашу идентичность';

  @override
  String get authSyncCodeFeatureLogin => 'Входить в другие приложения Nostr';

  @override
  String get authSyncCodeWarning =>
      'Никогда не делитесь этим кодом. Храните его в надёжном месте. Вы всегда сможете найти его в Настройках.';

  @override
  String get authCopied => 'Скопировано!';

  @override
  String get authCopySyncCode => 'Скопировать код синхронизации';

  @override
  String get authContinueToInbox => 'Перейти ко входящим';

  @override
  String get composeTitle => 'Написать';

  @override
  String get composeTo => 'Кому';

  @override
  String get composeAddMore => 'Добавить ещё';

  @override
  String get composeHideExpanded => 'Скрыть Копия/СК/От';

  @override
  String get composeShowExpanded => 'Показать Копия/СК/От';

  @override
  String get composeExpandedFieldsButtonLabel => 'Копия, От';

  @override
  String get composeCc => 'Копия';

  @override
  String get composeBcc => 'Скрытая копия';

  @override
  String get composeSubject => 'Тема';

  @override
  String get composeAttachFile => 'Прикрепить файл';

  @override
  String get composePlaceholder => 'Напишите письмо';

  @override
  String get composeFrom => 'От';

  @override
  String get composeSendAs => 'Отправить от';

  @override
  String get composeCreateNewIdentity => 'Создать новую идентичность';

  @override
  String get composeRemoveAttachment => 'Удалить вложение';

  @override
  String get composeSend => 'Отправить';

  @override
  String get composeMoreSendOptions => 'Больше опций отправки';

  @override
  String get composeChooseSendMode => 'Выберите режим отправки';

  @override
  String get composeModePrivateDeniable => 'Приватный отрицаемый';

  @override
  String get composeModePrivateSigned => 'Приватный подписанный';

  @override
  String get composeModePublic => 'Публичный';

  @override
  String get composeModePrivateDeniableDescription =>
      'Отправить как зашифрованное письмо. Без подписи — отрицаемое при необходимости.';

  @override
  String get composeModePrivateSignedDescription =>
      'Отправить как зашифрованное письмо. Подписанное — подтверждает авторство.';

  @override
  String get composeModePublicDescription =>
      'Отправить как публичное событие. Каждый может прочитать. Без шифрования.';

  @override
  String get composeResolvingNip05 => 'Разрешение NIP-05...';

  @override
  String get contactSourceAddressBook => 'Адресная книга';

  @override
  String get contactSourceEmailHistory => 'История писем';

  @override
  String get contactSourceFollowing => 'Подписки';

  @override
  String get contactSourceCachedProfile => 'Профиль из кеша';

  @override
  String get contactSourceNip05Verified => 'Подтверждён NIP-05';

  @override
  String get contactsTitle => 'Контакты';

  @override
  String get contactsAdd => 'Добавить контакт';

  @override
  String get contactsAddToContacts => 'Добавить в контакты';

  @override
  String get contactsSync => 'Синхронизировать контакты';

  @override
  String get contactsRetry => 'Повторить ожидающие обновления контактов';

  @override
  String get contactsSearchHint => 'Поиск контактов';

  @override
  String get contactsEmpty => 'Контактов пока нет';

  @override
  String get contactsSearchEmpty => 'Подходящих контактов нет';

  @override
  String get contactsSelectPrompt => 'Выберите контакт';

  @override
  String get contactsCreateTitle => 'Новый контакт';

  @override
  String get contactsEditTitle => 'Редактировать контакт';

  @override
  String get contactsNameLabel => 'Имя';

  @override
  String get contactsEmailsLabel => 'Адреса электронной почты';

  @override
  String get contactsAddEmailHint => 'Добавить адрес электронной почты';

  @override
  String get contactsPhonesLabel => 'Номера телефонов';

  @override
  String get contactsAddPhoneHint => 'Добавить номер телефона';

  @override
  String get contactsBirthdayLabel => 'День рождения';

  @override
  String get contactsBirthdayAdd => 'Добавить день рождения';

  @override
  String get contactsBirthdayDayLabel => 'День';

  @override
  String get contactsBirthdayMonthLabel => 'Месяц';

  @override
  String get contactsBirthdayYearLabel => 'Год';

  @override
  String get contactsNostrLabel => 'Идентификаторы Nostr';

  @override
  String get contactsAddNostrHint =>
      'Добавить npub, nprofile, hex-публичный ключ или NIP-05';

  @override
  String get contactsCancel => 'Отмена';

  @override
  String get contactsSave => 'Сохранить';

  @override
  String get contactsEdit => 'Редактировать контакт';

  @override
  String get contactsCopyVCard => 'Копировать vCard';

  @override
  String get contactsVCardCopied => 'vCard скопирована';

  @override
  String get contactsDelete => 'Удалить';

  @override
  String get contactsDeleteTitle => 'Удалить контакт?';

  @override
  String get contactsDeleteBody =>
      'Контакт будет удален из вашей приватной адресной книги.';

  @override
  String get contactsEmailsTitle => 'Почта';

  @override
  String get contactsPhonesTitle => 'Телефон';

  @override
  String get contactsBirthdayTitle => 'День рождения';

  @override
  String get contactsNostrTitle => 'Nostr';

  @override
  String get contactsCall => 'Позвонить';

  @override
  String get contactsSendSms => 'Отправить SMS';

  @override
  String get contactsImport => 'Импортировать контакты';

  @override
  String get contactsExport => 'Экспортировать контакты';

  @override
  String get contactsExportEmpty => 'Нет контактов для экспорта';

  @override
  String contactsExportSaved(String path) {
    return 'Контакты экспортированы: $path';
  }

  @override
  String contactsExportFailed(String error) {
    return 'Не удалось экспортировать контакты: $error';
  }

  @override
  String get contactsImportEmpty => 'В файле не найдено контактов';

  @override
  String contactsImportFailed(String error) {
    return 'Не удалось импортировать контакты: $error';
  }

  @override
  String contactsImportSummary(int imported, int skipped) {
    return 'Импортировано: $imported, пропущено: $skipped';
  }

  @override
  String get contactsImportConflictTitle => 'Контакты уже существуют';

  @override
  String contactsImportConflictBody(int count) {
    return '$count из импортируемых контактов уже существуют. Что с ними делать?';
  }

  @override
  String get contactsImportMergeAll => 'Объединить все';

  @override
  String get contactsImportReplaceAll => 'Заменить все';

  @override
  String get contactsImportSkip => 'Пропустить дубликаты';

  @override
  String get profileEditTitle => 'Редактирование профиля';

  @override
  String get profileDisplayNameLabel => 'Отображаемое имя';

  @override
  String get profileDisplayNameHint => 'Ваше полное имя или псевдоним';

  @override
  String get profileUsernameLabel => 'Имя пользователя';

  @override
  String get profileUsernameHint => 'идентификатор';

  @override
  String get profileAboutLabel => 'О себе';

  @override
  String get profileAboutHint => 'Короткая биография';

  @override
  String get profileAdvanced => 'Дополнительно';

  @override
  String get profilePictureUrlLabel => 'URL изображения';

  @override
  String get profilePictureUrlHint => 'https://example.com/avatar.png';

  @override
  String get profileChangePicture => 'Изменить фото профиля';

  @override
  String get onboardingPage1Title => 'Добро пожаловать в Nmail';

  @override
  String get onboardingPage1Body =>
      'Откройте для себя децентрализованную почту, где контроль в ваших руках. Новый способ общения, сосредоточенный на вас.';

  @override
  String get onboardingPage2Title => 'Сеть без хозяев';

  @override
  String get onboardingPage2Body =>
      'Ваши сообщения проходят через глобальную сеть независимых серверов. Ни одна компания не владеет вашей почтой.';

  @override
  String get onboardingPage3Title => 'Свобода выбора';

  @override
  String get onboardingPage3Body =>
      'Вы никогда не привязаны к одному провайдеру. Меняйте мосты или реле в любой момент, не теряя идентичность или контакты.';

  @override
  String get onboardingPage4Title => 'Одна идентичность для всего';

  @override
  String get onboardingPage4Body =>
      'Используйте свой аккаунт для писем, подписок на профили или других приложений. Постоянная идентичность работает во многих приложениях.';

  @override
  String get onboardingPage5Title => 'Построено для будущего';

  @override
  String get onboardingPage5Body =>
      'Воспользуйтесь современной архитектурой, ориентированной на приватность. Nmail помогает плавно перейти к более безопасному и устойчивому общению.';

  @override
  String get onboardingPage6Title => 'Ранний доступ';

  @override
  String get onboardingPage6Body =>
      'Nmail и протокол, лежащий в его основе, ещё очень молоды. Всё сделано, чтобы работать как можно лучше, но могут возникать ошибки, а что-то может казаться медленным или отсутствующим. Спасибо, что вы один из первых пользователей. Ваше терпение помогает формировать дальнейшее развитие.';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingDone => 'Готово';

  @override
  String get createIdentityTitle => 'Создать идентичность';

  @override
  String get createIdentityAddress => 'Адрес';

  @override
  String get createIdentityCustomUsername => 'Собственное имя пользователя';

  @override
  String get createIdentityBridge => 'Мост';

  @override
  String get createIdentityNoBridges => 'Мосты недоступны';

  @override
  String get createIdentityBridgeHint => 'bridge.com';

  @override
  String get createIdentityPreview => 'Предпросмотр';

  @override
  String get createIdentityPreviewEmpty =>
      'Введите адрес и выберите мост, чтобы увидеть предпросмотр';

  @override
  String get createIdentityAlreadyExists => 'Эта идентичность уже существует';

  @override
  String get leftRailSettings => 'Настройки';

  @override
  String get linkOpenTitle => 'Открыть ссылку?';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get debugNotAuthenticated => 'Не авторизовано';

  @override
  String get debugTestEmailCreated =>
      'Тестовое письмо создано и перемещено в корзину (31 день)';

  @override
  String get debugTestEmailPartial =>
      'Письмо создано и перемещено в корзину, но не удалось обновить отметку времени';

  @override
  String debugError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get composeSelectAttachments => 'Выбрать вложения';

  @override
  String composePickFilesFailed(String error) {
    return 'Не удалось выбрать файлы: $error';
  }

  @override
  String get composeInvalidRecipient => 'Неверный формат получателя';

  @override
  String get composeAddRecipient => 'Добавьте хотя бы одного получателя';

  @override
  String get composeSendFailed => 'Не удалось отправить письмо';

  @override
  String get composeScheduleSend => 'Запланировать отправку';

  @override
  String get composeScheduleClear => 'Убрать запланированную отправку';

  @override
  String get composeScheduleTimePast => 'Выберите время в будущем';

  @override
  String get composeScheduleFailed => 'Не удалось запланировать письмо';

  @override
  String get scheduledEmpty => 'Нет запланированных писем';

  @override
  String scheduledSendsAt(String time) {
    return 'Отправка $time';
  }

  @override
  String get scheduledCancel => 'Отменить отправку';

  @override
  String get scheduledCancelFailed =>
      'Не удалось отменить запланированное письмо';

  @override
  String get scheduledStatusSent => 'Отправленные';

  @override
  String get scheduledStatusFailed => 'Не удалось';

  @override
  String get scheduledStatusError => 'Отклонено';

  @override
  String get profileLoadFailed => 'Не удалось загрузить данные профиля';

  @override
  String get profileSelectPicture => 'Выбрать фото профиля';

  @override
  String get profileUploadNoServers => 'Серверы не ответили';

  @override
  String get profileUploadFailed => 'Ошибка загрузки';

  @override
  String get profileUploadError => 'Во время загрузки произошла ошибка';

  @override
  String get profileUpdateFailed => 'Не удалось обновить профиль';

  @override
  String get authEnterUsername => 'Введите имя пользователя';

  @override
  String createIdentityFailed(String error) {
    return 'Не удалось создать идентичность: $error';
  }

  @override
  String get dateYesterday => 'Вчера';

  @override
  String get notFoundTitle => 'Страница не найдена';

  @override
  String get notFoundBackToInbox => 'Вернуться во входящие';
}
