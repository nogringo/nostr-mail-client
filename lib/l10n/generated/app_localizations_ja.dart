// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '削除';

  @override
  String get actionAdd => '追加';

  @override
  String get actionClear => 'クリア';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionContinue => '続ける';

  @override
  String get actionBack => '戻る';

  @override
  String get actionConfirm => '確認';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCopy => 'コピー';

  @override
  String get actionOpen => '開く';

  @override
  String get actionUpload => 'アップロード';

  @override
  String get actionReset => 'リセット';

  @override
  String get actionUndo => '元に戻す';

  @override
  String get actionRemove => '削除';

  @override
  String get actionDiscard => '破棄';

  @override
  String get stateLoading => '読み込み中';

  @override
  String get stateLoadingEllipsis => '読み込み中...';

  @override
  String get stateResetting => 'リセット中...';

  @override
  String get stateValidating => '検証中...';

  @override
  String get stateDownloading => 'ダウンロード中...';

  @override
  String get stateUploading => 'アップロード中...';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsDynamicTheme => 'ダイナミックテーマ';

  @override
  String get settingsDynamicThemeSubtitle => '背景画像から色を生成';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => 'システムの既定';

  @override
  String get settingsLanguageDialogTitle => '言語を選択';

  @override
  String get settingsAdvancedOptions => '詳細設定';

  @override
  String get settingsShowEmailSource => 'メールのソースコードを表示';

  @override
  String get settingsShowEmailSourceSubtitle => '生メールを表示するボタンを追加します';

  @override
  String get settingsAlwaysLoadImages => '常に画像を読み込む';

  @override
  String get settingsAlwaysLoadImagesSubtitle => 'プライバシー保護のため、画像は既定でブロックされます';

  @override
  String get settingsIdentities => 'アイデンティティ';

  @override
  String get settingsManageIdentities => 'アイデンティティを管理';

  @override
  String get settingsManageIdentitiesSubtitle => 'アドレスの追加・削除・並び替え';

  @override
  String get settingsCompose => '作成';

  @override
  String get settingsEmailSignature => 'メール署名';

  @override
  String get settingsEmailSignatureEmpty => '署名が設定されていません';

  @override
  String get settingsEmailSignatureHint => '署名を入力...';

  @override
  String get settingsSynchronization => '同期';

  @override
  String get settingsHosting => 'ホスティング';

  @override
  String get settingsHostingSubtitle => 'リレー、Blossom サーバー、接続';

  @override
  String get settingsDebugTools => 'デバッグツール';

  @override
  String get settingsDebugToolsSubtitle => 'テストおよび開発機能';

  @override
  String get settingsAccount => 'アカウント';

  @override
  String get settingsCopySyncCode => '同期コードをコピー';

  @override
  String get settingsCopySyncCodeSubtitle => 'このコードで他のデバイスとアカウントを同期できます';

  @override
  String get settingsSyncCodeCopied => '同期コードをコピーしました';

  @override
  String get settingsLogOut => 'ログアウト';

  @override
  String get settingsResetApplication => 'アプリをリセット';

  @override
  String get settingsResetApplicationSubtitle => 'ローカルデータをすべて削除';

  @override
  String get settingsResetConfirmMessage =>
      '設定や背景画像を含むすべてのローカルデータが削除され、ログアウトされます。\n\nこの操作は元に戻せません。';

  @override
  String get settingsAbout => 'アプリ情報';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsSourceCode => 'ソースコード';

  @override
  String get settingsSourceCodeSubtitle => 'GitHubで見る';

  @override
  String get settingsEarlyAccess => 'アーリーアクセス';

  @override
  String get settingsEarlyAccessMessage =>
      'Nmail とその基盤となるプロトコルはまだ非常に若いです。可能な限りうまく動くように作られていますが、バグが発生したり、一部の機能が遅く感じられたり、不足していることがあります。早期のユーザーとして使ってくださりありがとうございます。';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeAuto => '自動';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsBackgroundDefaultLabel => '既定のテーマカラー';

  @override
  String get settingsBackgroundSelectLabel => '背景画像を選択';

  @override
  String get settingsBackgroundDeleteLabel => '背景画像を削除';

  @override
  String get settingsBackgroundRemoveLabel => '背景画像を取り除く';

  @override
  String get settingsBackgroundAddLabel => '背景画像を追加';

  @override
  String get settingsBackgroundDeleteTitle => '背景を削除';

  @override
  String get settingsBackgroundDeleteMessage => '保存済みの背景からこの画像を削除しますか?';

  @override
  String get settingsBackgroundImageDeleted => '画像を削除しました';

  @override
  String get settingsBackgroundDeleteFailed => '画像の削除に失敗しました';

  @override
  String get settingsBackgroundDialogTitle => '背景';

  @override
  String get settingsBackgroundSelectFile => 'ファイルを選択';

  @override
  String get settingsBackgroundPasteUrl => 'URL を貼り付け';

  @override
  String get settingsBackgroundUrlTitle => '背景の URL';

  @override
  String get settingsBackgroundUrlHint => 'https://example.com/image.jpg';

  @override
  String get settingsBackgroundSet => '背景を設定しました';

  @override
  String get settingsBackgroundImageSet => '画像を設定しました';

  @override
  String get settingsBackgroundCopyFailed => '画像のコピーに失敗しました';

  @override
  String get settingsBackgroundUrlError => '画像にアクセスできません (CORS またはネットワークエラー)';

  @override
  String get settingsBackgroundDownloaded => '画像をダウンロードしました';

  @override
  String get settingsBackgroundDownloadFailed => '画像のダウンロードに失敗しました';

  @override
  String get settingsBackgroundUploadTitle => '画像をアップロード';

  @override
  String get settingsBackgroundUploadWarning =>
      'この画像は Blossom サーバーにアップロードされます。サーバー運営者やリンクを知る誰でも閲覧できます。';

  @override
  String get hostingRecommended => 'おすすめ:';

  @override
  String hostingWillBeAddedAs(String url) {
    return '次のように追加されます: $url';
  }

  @override
  String get relayAddTitle => 'リレーを追加';

  @override
  String get relayUrlLabel => 'リレー URL';

  @override
  String get relayUrlHint => 'wss://relay.example.com';

  @override
  String get relayInvalidUrl => '無効なリレー URL';

  @override
  String get relayDirection => '方向';

  @override
  String get relayReadWrite => '読み書き';

  @override
  String get relayRead => '読み取り';

  @override
  String get relayWrite => '書き込み';

  @override
  String get relayMarkerReadWrite => '読み書き';

  @override
  String get relayMarkerRead => '読み取り';

  @override
  String get relayMarkerWrite => '書き込み';

  @override
  String get relayInboxOutboxTitle => '受信/送信リレー';

  @override
  String get relayAddTooltip => 'リレーを追加';

  @override
  String get relayRemoveTooltip => 'リレーを削除';

  @override
  String get relayInboxOutboxEmpty => '受信/送信リレーが設定されていません';

  @override
  String get relayEmptyHint => '+ をタップしてリレーを追加';

  @override
  String get dmRelayAddTitle => 'DM リレーを追加';

  @override
  String get dmRelaySectionTitle => 'DM リレー';

  @override
  String get dmRelayEmpty => 'DM リレーが設定されていません';

  @override
  String get bridgeAddTitle => 'ブリッジを追加';

  @override
  String get bridgeDomainLabel => 'ブリッジドメイン';

  @override
  String get bridgeDomainHint => 'bridge.example.com';

  @override
  String get bridgeInvalidDomain => '無効なドメイン';

  @override
  String get bridgeSectionTitle => 'ブリッジ';

  @override
  String get bridgeAddTooltip => 'ブリッジを追加';

  @override
  String get bridgeEmpty => 'ブリッジが設定されていません';

  @override
  String get bridgeEmptyHint => '+ をタップしてブリッジを追加';

  @override
  String get bridgeDefault => '既定のブリッジ';

  @override
  String get blossomAddTitle => 'Blossom サーバーを追加';

  @override
  String get blossomServerUrlLabel => 'サーバー URL';

  @override
  String get blossomServerUrlHint => 'https://blossom.example.com';

  @override
  String get blossomInvalidUrl => '無効なサーバー URL';

  @override
  String get blossomSectionTitle => 'ファイルホスティング';

  @override
  String get blossomAddTooltip => 'サーバーを追加';

  @override
  String get blossomRemoveTooltip => 'サーバーを削除';

  @override
  String get blossomEmpty => 'Blossom サーバーが設定されていません';

  @override
  String get blossomEmptyHint => '+ をタップしてサーバーを追加';

  @override
  String get connectivitySectionTitle => 'リアルタイム接続';

  @override
  String get connectivityRelayConnectivity => 'リレー接続状態';

  @override
  String get syncStatusSectionTitle => '同期ステータス';

  @override
  String get syncStatusEmpty => '同期データがありません';

  @override
  String get syncStatusEmptyHint => 'メールを同期するとリレーの状態が表示されます';

  @override
  String get syncStatusResync => '再同期';

  @override
  String get syncStatusBeginningOfTime => '時の始まり';

  @override
  String get identitiesTitle => 'アイデンティティ';

  @override
  String get identitiesEmptyTitle => 'アイデンティティがありません';

  @override
  String get identitiesEmptyMessage => 'カスタムアドレスからメールを送信するために 1 つ作成してください。';

  @override
  String get identitiesCreate => 'アイデンティティを作成';

  @override
  String get identitiesDiscardTitle => '変更を破棄しますか?';

  @override
  String get identitiesDiscardMessage => '保存されていない変更があります。今離れると破棄されます。';

  @override
  String get identitiesKeepEditing => '編集を続ける';

  @override
  String get debugToolsEmailTesting => 'メールテスト';

  @override
  String get debugToolsCreateOldTrashed => '古いゴミ箱メールを作成';

  @override
  String get debugToolsCreateOldTrashedDescription =>
      '31 日前のテストメールをゴミ箱に作成します。「古いメールを削除」機能のテストに使用します。';

  @override
  String get folderInbox => '受信トレイ';

  @override
  String get folderSent => '送信済み';

  @override
  String get folderTrash => 'ゴミ箱';

  @override
  String get folderArchive => 'アーカイブ';

  @override
  String get inboxEmptyInbox => 'メールはまだありません';

  @override
  String get inboxEmptySent => '送信済みメールはありません';

  @override
  String get inboxEmptyTrash => 'ゴミ箱は空です';

  @override
  String get inboxEmptyArchive => 'アーカイブは空です';

  @override
  String get inboxSyncFromRelays => 'リレーから同期';

  @override
  String get inboxSearch => '検索';

  @override
  String get inboxSync => '同期';

  @override
  String get inboxMenu => 'メニュー';

  @override
  String get inboxClearSelection => '選択を解除';

  @override
  String inboxSelectedCount(int count) {
    return '$count 件選択中';
  }

  @override
  String get inboxProfile => 'プロフィール';

  @override
  String get inboxCopyNpub => 'npub をコピー';

  @override
  String get inboxLogout => 'ログアウト';

  @override
  String get inboxAccount => 'アカウント';

  @override
  String get inboxCompose => '作成';

  @override
  String get inboxNpubCopied => 'npub をコピーしました';

  @override
  String get inboxUnknown => '不明';

  @override
  String get inboxEditProfile => 'プロフィールを編集';

  @override
  String get inboxSettings => '設定';

  @override
  String get inboxDeleteOldEmailsTitle => '古いメールを削除';

  @override
  String inboxDeleteOldEmailsMessage(int count) {
    return '30 日以上前のメール $count 件を完全に削除します。\n\nこの操作は元に戻せません。';
  }

  @override
  String get inboxDeleteFailed => '削除に失敗しました';

  @override
  String inboxDeleteFailedDescription(String error) {
    return '古いメールの削除に失敗しました: $error';
  }

  @override
  String inboxOldEmailsCount(int count) {
    return '削除予定の古いメール $count 件';
  }

  @override
  String get inboxDeleteNow => '今すぐ削除';

  @override
  String get inboxDeleteOldEmailsTooltip => '古いメールを削除';

  @override
  String get inboxSearchHint => 'すべてのメールを検索...';

  @override
  String get inboxCloseSearch => '検索を閉じる';

  @override
  String get inboxSelectAll => 'すべて選択';

  @override
  String get inboxMoreActions => 'その他の操作';

  @override
  String get emailReply => '返信';

  @override
  String get emailForward => '転送';

  @override
  String get emailArchive => 'アーカイブ';

  @override
  String get emailUnarchive => 'アーカイブ解除';

  @override
  String get emailMarkAsRead => '既読にする';

  @override
  String get emailMarkAsUnread => '未読にする';

  @override
  String get emailMoveToTrash => 'ゴミ箱へ移動';

  @override
  String get emailRestore => '復元';

  @override
  String get emailDeletePermanently => '完全に削除';

  @override
  String get emailNoSubject => '(件名なし)';

  @override
  String emailExtraRecipients(int count) {
    return '他に $count 人の受信者';
  }

  @override
  String get emailNotFound => 'メールが見つかりません';

  @override
  String get emailShowFormatted => '整形表示';

  @override
  String get emailShowRaw => 'ソースを表示';

  @override
  String emailSenderNpub(String npub) {
    return '送信者の npub: $npub';
  }

  @override
  String get emailDeletePermanentlyTitle => '完全に削除しますか?';

  @override
  String get emailDeletePermanentlyMessage => 'この操作は元に戻せません。';

  @override
  String get emailDefaultFilename => 'email';

  @override
  String emailSaved(String path) {
    return 'メールを保存しました: $path';
  }

  @override
  String emailSaveFailed(String error) {
    return 'メールの保存に失敗しました: $error';
  }

  @override
  String get emailRawContentUnavailable => 'メールの内容を読み込めませんでした';

  @override
  String get emailRepostFailedEvent => 'リポスト用のイベントを取得できませんでした';

  @override
  String get emailRepostSuccess => 'メールをリポストしました';

  @override
  String emailRepostFailed(String error) {
    return 'メールのリポストに失敗しました: $error';
  }

  @override
  String get emailAttachmentLoadFailed => '添付ファイルの読み込みに失敗しました';

  @override
  String emailFileSaved(String path) {
    return 'ファイルを保存しました: $path';
  }

  @override
  String emailFileSaveFailed(String error) {
    return 'ファイルの保存に失敗しました: $error';
  }

  @override
  String emailDownloadedAllSuccess(int count) {
    return '$count 件のファイルをダウンロードしました';
  }

  @override
  String emailDownloadedAllFailed(int count) {
    return '$count 件のファイルのダウンロードに失敗しました';
  }

  @override
  String emailDownloadedMixed(int success, int failed) {
    return '$success 件成功、$failed 件失敗';
  }

  @override
  String get emailDownload => 'ダウンロード';

  @override
  String get emailImageLoadFailed => '画像の読み込みに失敗しました';

  @override
  String get emailPdfLoadFailed => 'PDF の読み込みに失敗しました';

  @override
  String get emailActionReply => '返信';

  @override
  String get emailActionReplyAll => '全員に返信';

  @override
  String get emailActionForward => '転送';

  @override
  String get emailActionArchive => 'アーカイブ';

  @override
  String get emailActionUnarchive => 'アーカイブ解除';

  @override
  String get emailActionMarkRead => '既読';

  @override
  String get emailActionMarkUnread => '未読';

  @override
  String get emailActionNip59 => 'NIP-59 イベント';

  @override
  String get emailActionRepost => 'リポスト';

  @override
  String get emailActionDownload => 'メールをダウンロード';

  @override
  String get emailMoreActions => 'その他の操作';

  @override
  String get emailMoreOptions => 'その他のオプション';

  @override
  String get emailShowRecipients => '宛先を表示';

  @override
  String get emailImagesHidden => 'プライバシー保護のため画像は非表示です';

  @override
  String get emailLoadImages => '画像を読み込む';

  @override
  String get emailRecipientTo => '宛先';

  @override
  String get emailRecipientCc => 'Cc';

  @override
  String get emailRecipientBcc => 'Bcc';

  @override
  String get emailAttachmentsTitle => '添付ファイル';

  @override
  String get emailDownloadAll => 'すべてダウンロード';

  @override
  String get emailNip59Dismiss => '閉じる';

  @override
  String get emailNip59Title => 'NIP-59 イベント';

  @override
  String get emailNip59GiftWrap => 'Gift Wrap';

  @override
  String get emailNip59Seal => 'Seal';

  @override
  String get emailNip59Rumor => 'Rumor';

  @override
  String get emailNip59CopyJson => 'JSON をコピー';

  @override
  String emailNip59Kind(int kind) {
    return 'Kind $kind';
  }

  @override
  String get emailNip59NotAvailable => '利用できません';

  @override
  String get authHeaderTitle => 'Nmail にログイン';

  @override
  String get authSyncCodeLabel => '同期コード';

  @override
  String get authInvalidSyncCode => '無効な同期コード';

  @override
  String get authInvalidSyncCodeDescription =>
      '入力中にコードを確認しています。有効になると自動的にログインされます。';

  @override
  String get authLogIn => 'ログイン';

  @override
  String get authCreateAccount => 'アカウントを作成';

  @override
  String get authMoreOptions => 'その他のオプション';

  @override
  String get authRegisterPrompt => '他の人に表示する名前は?';

  @override
  String get authDisplayNameLabel => '表示名';

  @override
  String get authDisplayNameHint => '例: アリス';

  @override
  String get authBackToLogin => 'ログイン画面に戻る';

  @override
  String get authUnableRetrieveCode => '同期コードを取得できませんでした';

  @override
  String get authYourSyncCode => 'あなたの同期コード';

  @override
  String get authSyncCodeIntro => 'このコードはアカウントの鍵です。完全なコントロールを得られ、次のことができます:';

  @override
  String get authSyncCodeFeatureRestore => '任意のデバイスでアカウントを復元';

  @override
  String get authSyncCodeFeatureBackup => 'アイデンティティを安全にバックアップ';

  @override
  String get authSyncCodeFeatureLogin => '他の Nostr アプリにログイン';

  @override
  String get authSyncCodeWarning =>
      'このコードを誰とも共有しないでください。安全な場所に保管してください。後から「設定」でいつでも確認できます。';

  @override
  String get authCopied => 'コピーしました!';

  @override
  String get authCopySyncCode => '同期コードをコピー';

  @override
  String get authContinueToInbox => '受信トレイへ';

  @override
  String get composeTitle => '作成';

  @override
  String get composeTo => '宛先';

  @override
  String get composeAddMore => 'さらに追加';

  @override
  String get composeHideExpanded => 'Cc/Bcc/送信元を隠す';

  @override
  String get composeShowExpanded => 'Cc/Bcc/送信元を表示';

  @override
  String get composeCc => 'Cc';

  @override
  String get composeBcc => 'Bcc';

  @override
  String get composeSubject => '件名';

  @override
  String get composeAttachFile => 'ファイルを添付';

  @override
  String get composePlaceholder => 'メールを作成';

  @override
  String get composeFrom => '送信元';

  @override
  String get composeSendAs => '送信元として';

  @override
  String get composeCreateNewIdentity => '新しいアイデンティティを作成';

  @override
  String get composeRemoveAttachment => '添付を削除';

  @override
  String get composeSend => '送信';

  @override
  String get composeMoreSendOptions => 'その他の送信オプション';

  @override
  String get composeChooseSendMode => '送信モードを選択';

  @override
  String get composeModePrivateDeniable => 'プライベート(否認可能)';

  @override
  String get composeModePrivateSigned => 'プライベート(署名付き)';

  @override
  String get composeModePublic => '公開';

  @override
  String get composeModePrivateDeniableDescription =>
      '暗号化メールとして送信。署名なし — 必要に応じて否認可能。';

  @override
  String get composeModePrivateSignedDescription =>
      '暗号化メールとして送信。署名付き — 作者であることを証明。';

  @override
  String get composeModePublicDescription => '公開イベントとして送信。誰でも読めます。暗号化なし。';

  @override
  String get composeResolvingNip05 => 'NIP-05 を解決中...';

  @override
  String get contactSourceAddressBook => 'アドレス帳';

  @override
  String get contactSourceEmailHistory => 'メール履歴';

  @override
  String get contactSourceFollowing => 'フォロー中';

  @override
  String get contactSourceCachedProfile => 'キャッシュされたプロフィール';

  @override
  String get contactSourceNip05Verified => 'NIP-05 認証済み';

  @override
  String get contactsTitle => '連絡先';

  @override
  String get contactsAdd => '連絡先を追加';

  @override
  String get contactsAddToContacts => '連絡先に追加';

  @override
  String get contactsSync => '連絡先を同期';

  @override
  String get contactsRetry => '保留中の連絡先更新を再試行';

  @override
  String get contactsSearchHint => '連絡先を検索';

  @override
  String get contactsEmpty => '連絡先はまだありません';

  @override
  String get contactsSearchEmpty => '一致する連絡先はありません';

  @override
  String get contactsSelectPrompt => '連絡先を選択';

  @override
  String get contactsCreateTitle => '新しい連絡先';

  @override
  String get contactsEditTitle => '連絡先を編集';

  @override
  String get contactsNameLabel => '名前';

  @override
  String get contactsEmailsLabel => 'メールアドレス';

  @override
  String get contactsMultilineHint => '1 行に 1 件';

  @override
  String get contactsAddEmailHint => 'メールアドレスを追加';

  @override
  String get contactsPhonesLabel => '電話番号';

  @override
  String get contactsAddPhoneHint => '電話番号を追加';

  @override
  String get contactsBirthdayLabel => '誕生日';

  @override
  String get contactsBirthdayAdd => '誕生日を追加';

  @override
  String get contactsBirthdayDayLabel => '日';

  @override
  String get contactsBirthdayMonthLabel => '月';

  @override
  String get contactsBirthdayYearLabel => '年';

  @override
  String get contactsBirthdayHint => 'YYYY-MM-DD';

  @override
  String get contactsNostrLabel => 'Nostr アイデンティティ';

  @override
  String get contactsNostrHint => 'npub、nprofile、hex 公開鍵、または NIP-05';

  @override
  String get contactsAddNostrHint => 'npub、nprofile、hex 公開鍵、または NIP-05 を追加';

  @override
  String get contactsCancel => 'キャンセル';

  @override
  String get contactsSave => '保存';

  @override
  String get contactsEdit => '連絡先を編集';

  @override
  String get contactsCopyVCard => 'vCard をコピー';

  @override
  String get contactsVCardCopied => 'vCard をコピーしました';

  @override
  String get contactsDelete => '削除';

  @override
  String get contactsDeleteTitle => '連絡先を削除しますか？';

  @override
  String get contactsDeleteBody => 'この連絡先をあなたの非公開アドレス帳から削除します。';

  @override
  String get contactsEmailsTitle => 'メール';

  @override
  String get contactsPhonesTitle => '電話';

  @override
  String get contactsBirthdayTitle => '誕生日';

  @override
  String get contactsNostrTitle => 'Nostr';

  @override
  String get contactsCall => '発信';

  @override
  String get contactsSendSms => 'SMSを送信';

  @override
  String get contactsImport => '連絡先をインポート';

  @override
  String get contactsExport => '連絡先をエクスポート';

  @override
  String get contactsExportEmpty => 'エクスポートする連絡先がありません';

  @override
  String contactsExportSaved(String path) {
    return '連絡先をエクスポートしました: $path';
  }

  @override
  String contactsExportFailed(String error) {
    return '連絡先のエクスポートに失敗しました: $error';
  }

  @override
  String get contactsImportEmpty => 'ファイルに連絡先が見つかりません';

  @override
  String contactsImportFailed(String error) {
    return '連絡先のインポートに失敗しました: $error';
  }

  @override
  String contactsImportSummary(int imported, int skipped) {
    return '$imported 件インポート、$skipped 件スキップ';
  }

  @override
  String get contactsImportConflictTitle => '既に存在する連絡先';

  @override
  String contactsImportConflictBody(int count) {
    return 'インポートした連絡先のうち $count 件は既に存在します。どう処理しますか？';
  }

  @override
  String get contactsImportMergeAll => 'すべて結合';

  @override
  String get contactsImportReplaceAll => 'すべて置き換え';

  @override
  String get contactsImportSkip => '重複をスキップ';

  @override
  String get profileEditTitle => 'プロフィールを編集';

  @override
  String get profileDisplayNameLabel => '表示名';

  @override
  String get profileDisplayNameHint => 'フルネームまたはエイリアス';

  @override
  String get profileUsernameLabel => 'ユーザー名';

  @override
  String get profileUsernameHint => 'ハンドル';

  @override
  String get profileAboutLabel => '自己紹介';

  @override
  String get profileAboutHint => 'あなたについての短いプロフィール';

  @override
  String get profileAdvanced => '詳細';

  @override
  String get profilePictureUrlLabel => '画像 URL';

  @override
  String get profilePictureUrlHint => 'https://example.com/avatar.png';

  @override
  String get profileChangePicture => 'プロフィール画像を変更';

  @override
  String get onboardingPage1Title => 'Nmail へようこそ';

  @override
  String get onboardingPage1Body =>
      'あなたが主導権を握る分散型メール体験を発見しましょう。あなたを中心にした、新しいコミュニケーションの形です。';

  @override
  String get onboardingPage2Title => '支配者のいないネットワーク';

  @override
  String get onboardingPage2Body =>
      'メッセージは独立したサーバーのグローバルネットワークを通じて流れます。あなたの受信トレイを所有する企業はありません。';

  @override
  String get onboardingPage3Title => '選択の自由';

  @override
  String get onboardingPage3Body =>
      '単一のプロバイダーに縛られることはありません。アイデンティティや連絡先を失うことなく、いつでもブリッジやリレーを切り替えられます。';

  @override
  String get onboardingPage4Title => 'すべてに 1 つのアイデンティティ';

  @override
  String get onboardingPage4Body =>
      'メール送信、プロフィールのフォロー、他のアプリの利用にあなたのアカウントを使用。多くのアプリで動作する、永続的なアイデンティティです。';

  @override
  String get onboardingPage5Title => '未来のために設計';

  @override
  String get onboardingPage5Body =>
      'プライバシーのために設計されたモダンなアーキテクチャの恩恵を受けましょう。Nmail は、より安全で回復力のあるコミュニケーションへの円滑な移行を支援します。';

  @override
  String get onboardingPage6Title => 'アーリーアクセス';

  @override
  String get onboardingPage6Body =>
      'Nmail とその基盤となるプロトコルはまだ非常に若いです。可能な限りうまく動くように作られていますが、バグが発生したり、一部の機能が遅く感じられたり、不足していることがあります。早期のユーザーとして使ってくださりありがとうございます。あなたの忍耐がこの先を形づくります。';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingDone => '完了';

  @override
  String get createIdentityTitle => 'アイデンティティを作成';

  @override
  String get createIdentityAddress => 'アドレス';

  @override
  String get createIdentityCustomUsername => 'カスタムユーザー名';

  @override
  String get createIdentityBridge => 'ブリッジ';

  @override
  String get createIdentityNoBridges => '利用可能なブリッジがありません';

  @override
  String get createIdentityBridgeHint => 'bridge.com';

  @override
  String get createIdentityPreview => 'プレビュー';

  @override
  String get createIdentityPreviewEmpty => 'プレビューを表示するにはアドレスを入力しブリッジを選択してください';

  @override
  String get createIdentityAlreadyExists => 'このアイデンティティは既に存在します';

  @override
  String get leftRailSettings => '設定';

  @override
  String get linkOpenTitle => 'リンクを開きますか?';

  @override
  String get linkCopied => 'リンクをコピーしました';

  @override
  String get debugNotAuthenticated => '未認証';

  @override
  String get debugTestEmailCreated => 'テストメールを作成しゴミ箱に移動しました (31 日前)';

  @override
  String get debugTestEmailPartial => 'メールを作成しゴミ箱に移動しましたが、タイムスタンプを更新できませんでした';

  @override
  String debugError(String error) {
    return 'エラー: $error';
  }

  @override
  String get composeSelectAttachments => '添付ファイルを選択';

  @override
  String composePickFilesFailed(String error) {
    return 'ファイルの選択に失敗しました: $error';
  }

  @override
  String get composeInvalidRecipient => '宛先の形式が無効です';

  @override
  String get composeAddRecipient => '宛先を 1 つ以上追加してください';

  @override
  String get composeSendFailed => 'メールの送信に失敗しました';

  @override
  String get composeScheduleSend => '送信を予約';

  @override
  String get composeScheduleTimePast => '未来の時刻を選択してください';

  @override
  String get composeScheduleFailed => 'メールの送信予約に失敗しました';

  @override
  String get profileLoadFailed => 'プロフィールデータの読み込みに失敗しました';

  @override
  String get profileSelectPicture => 'プロフィール画像を選択';

  @override
  String get profileUploadNoServers => '応答するサーバーがありません';

  @override
  String get profileUploadFailed => 'アップロードに失敗しました';

  @override
  String get profileUploadError => 'アップロード中にエラーが発生しました';

  @override
  String get profileUpdateFailed => 'プロフィールの更新に失敗しました';

  @override
  String get authEnterUsername => 'ユーザー名を入力してください';

  @override
  String createIdentityFailed(String error) {
    return 'アイデンティティの作成に失敗しました: $error';
  }

  @override
  String get dateYesterday => '昨日';

  @override
  String get notFoundTitle => 'ページが見つかりません';

  @override
  String get notFoundBackToInbox => '受信トレイに戻る';
}
