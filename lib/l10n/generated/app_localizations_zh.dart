// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String get actionAdd => '添加';

  @override
  String get actionClose => '关闭';

  @override
  String get actionContinue => '继续';

  @override
  String get actionBack => '返回';

  @override
  String get actionConfirm => '确认';

  @override
  String get actionOk => '确定';

  @override
  String get actionCopy => '复制';

  @override
  String get actionOpen => '打开';

  @override
  String get actionUpload => '上传';

  @override
  String get actionReset => '重置';

  @override
  String get actionUndo => '撤销';

  @override
  String get actionRemove => '移除';

  @override
  String get actionDiscard => '放弃';

  @override
  String get stateLoading => '加载中';

  @override
  String get stateLoadingEllipsis => '加载中...';

  @override
  String get stateResetting => '重置中...';

  @override
  String get stateValidating => '验证中...';

  @override
  String get stateDownloading => '下载中...';

  @override
  String get stateUploading => '上传中...';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsDynamicTheme => '动态主题';

  @override
  String get settingsDynamicThemeSubtitle => '根据背景图片生成颜色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '系统默认';

  @override
  String get settingsLanguageDialogTitle => '选择语言';

  @override
  String get settingsAdvancedOptions => '高级选项';

  @override
  String get settingsShowEmailSource => '显示邮件源代码';

  @override
  String get settingsShowEmailSourceSubtitle => '添加查看原始邮件的按钮';

  @override
  String get settingsAlwaysLoadImages => '始终加载图片';

  @override
  String get settingsAlwaysLoadImagesSubtitle => '为保护隐私,图片默认被屏蔽';

  @override
  String get settingsIdentities => '身份';

  @override
  String get settingsManageIdentities => '管理身份';

  @override
  String get settingsManageIdentitiesSubtitle => '添加、移除或重新排序地址';

  @override
  String get settingsCompose => '撰写';

  @override
  String get settingsEmailSignature => '邮件签名';

  @override
  String get settingsEmailSignatureEmpty => '未配置签名';

  @override
  String get settingsEmailSignatureHint => '输入您的签名...';

  @override
  String get settingsSynchronization => '同步';

  @override
  String get settingsHosting => '托管';

  @override
  String get settingsHostingSubtitle => '中继、Blossom 服务器、连接';

  @override
  String get settingsDebugTools => '调试工具';

  @override
  String get settingsDebugToolsSubtitle => '测试和开发功能';

  @override
  String get settingsAccount => '账户';

  @override
  String get settingsCopySyncCode => '复制同步码';

  @override
  String get settingsCopySyncCodeSubtitle => '使用此代码在其他设备上同步您的账户';

  @override
  String get settingsSyncCodeCopied => '已复制同步码';

  @override
  String get settingsLogOut => '退出登录';

  @override
  String get settingsResetApplication => '重置应用';

  @override
  String get settingsResetApplicationSubtitle => '删除所有本地数据';

  @override
  String get settingsResetConfirmMessage =>
      '这将删除所有本地数据,包括设置和背景图片,并将您注销。\n\n此操作无法撤销。';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsSourceCode => '源代码';

  @override
  String get settingsSourceCodeSubtitle => '在 GitHub 上查看';

  @override
  String get settingsEarlyAccess => '抢先体验';

  @override
  String get settingsEarlyAccessMessage =>
      'Nmail 及其背后的协议都还很年轻。一切都尽力做到最好，但仍可能出现 bug，有些功能可能显得缓慢或缺失。感谢你成为早期用户。';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeAuto => '自动';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsBackgroundDefaultLabel => '默认主题颜色';

  @override
  String get settingsBackgroundSelectLabel => '选择背景图片';

  @override
  String get settingsBackgroundDeleteLabel => '删除背景图片';

  @override
  String get settingsBackgroundRemoveLabel => '移除背景图片';

  @override
  String get settingsBackgroundAddLabel => '添加背景图片';

  @override
  String get settingsBackgroundDeleteTitle => '删除背景';

  @override
  String get settingsBackgroundDeleteMessage => '从已保存的背景中移除此图片?';

  @override
  String get settingsBackgroundImageDeleted => '图片已删除';

  @override
  String get settingsBackgroundDeleteFailed => '删除图片失败';

  @override
  String get settingsBackgroundDialogTitle => '背景';

  @override
  String get settingsBackgroundSelectFile => '选择文件';

  @override
  String get settingsBackgroundPasteUrl => '粘贴 URL';

  @override
  String get settingsBackgroundUrlTitle => '背景 URL';

  @override
  String get settingsBackgroundUrlHint => 'https://example.com/image.jpg';

  @override
  String get settingsBackgroundSet => '已设置背景';

  @override
  String get settingsBackgroundImageSet => '已设置图片';

  @override
  String get settingsBackgroundCopyFailed => '复制图片失败';

  @override
  String get settingsBackgroundUrlError => '图片无法访问(CORS 或网络错误)';

  @override
  String get settingsBackgroundDownloaded => '图片已下载';

  @override
  String get settingsBackgroundDownloadFailed => '下载图片失败';

  @override
  String get settingsBackgroundUploadTitle => '上传图片';

  @override
  String get settingsBackgroundUploadWarning =>
      '此图片将被上传到 Blossom 服务器。服务器运营者和拥有链接的任何人都可以查看。';

  @override
  String get hostingRecommended => '推荐:';

  @override
  String hostingWillBeAddedAs(String url) {
    return '将以以下方式添加: $url';
  }

  @override
  String get relayAddTitle => '添加中继';

  @override
  String get relayUrlLabel => '中继 URL';

  @override
  String get relayUrlHint => 'wss://relay.example.com';

  @override
  String get relayInvalidUrl => '无效的中继 URL';

  @override
  String get relayDirection => '方向';

  @override
  String get relayReadWrite => '读和写';

  @override
  String get relayRead => '读';

  @override
  String get relayWrite => '写';

  @override
  String get relayMarkerReadWrite => '读/写';

  @override
  String get relayMarkerRead => '读';

  @override
  String get relayMarkerWrite => '写';

  @override
  String get relayInboxOutboxTitle => '收件箱/发件箱中继';

  @override
  String get relayAddTooltip => '添加中继';

  @override
  String get relayRemoveTooltip => '移除中继';

  @override
  String get relayInboxOutboxEmpty => '未配置收件箱/发件箱中继';

  @override
  String get relayEmptyHint => '点击 + 添加中继';

  @override
  String get dmRelayAddTitle => '添加 DM 中继';

  @override
  String get dmRelaySectionTitle => 'DM 中继';

  @override
  String get dmRelayEmpty => '未配置 DM 中继';

  @override
  String get bridgeAddTitle => '添加桥接';

  @override
  String get bridgeDomainLabel => '桥接域名';

  @override
  String get bridgeDomainHint => 'bridge.example.com';

  @override
  String get bridgeInvalidDomain => '无效的域名';

  @override
  String get bridgeSectionTitle => '桥接';

  @override
  String get bridgeAddTooltip => '添加桥接';

  @override
  String get bridgeEmpty => '未配置桥接';

  @override
  String get bridgeEmptyHint => '点击 + 添加桥接';

  @override
  String get bridgeDefault => '默认桥接';

  @override
  String get blossomAddTitle => '添加 Blossom 服务器';

  @override
  String get blossomServerUrlLabel => '服务器 URL';

  @override
  String get blossomServerUrlHint => 'https://blossom.example.com';

  @override
  String get blossomInvalidUrl => '无效的服务器 URL';

  @override
  String get blossomSectionTitle => '文件托管';

  @override
  String get blossomAddTooltip => '添加服务器';

  @override
  String get blossomRemoveTooltip => '移除服务器';

  @override
  String get blossomEmpty => '未配置 Blossom 服务器';

  @override
  String get blossomEmptyHint => '点击 + 添加服务器';

  @override
  String get connectivitySectionTitle => '实时连接';

  @override
  String get connectivityRelayConnectivity => '中继连接状态';

  @override
  String get syncStatusSectionTitle => '同步状态';

  @override
  String get syncStatusEmpty => '暂无同步数据';

  @override
  String get syncStatusEmptyHint => '同步您的邮件以查看中继状态';

  @override
  String get syncStatusResync => '重新同步';

  @override
  String get syncStatusBeginningOfTime => '时间的起点';

  @override
  String get identitiesTitle => '身份';

  @override
  String get identitiesEmptyTitle => '暂无身份';

  @override
  String get identitiesEmptyMessage => '创建一个以从自定义地址发送邮件。';

  @override
  String get identitiesCreate => '创建身份';

  @override
  String get identitiesDiscardTitle => '放弃更改?';

  @override
  String get identitiesDiscardMessage => '您有未保存的更改。现在离开将被放弃。';

  @override
  String get identitiesKeepEditing => '继续编辑';

  @override
  String get debugToolsEmailTesting => '邮件测试';

  @override
  String get debugToolsCreateOldTrashed => '创建旧的已删除邮件';

  @override
  String get debugToolsCreateOldTrashedDescription =>
      '在回收站创建一封 31 天前的测试邮件。用于测试「删除旧邮件」功能。';

  @override
  String get folderInbox => '收件箱';

  @override
  String get folderSent => '已发送';

  @override
  String get folderTrash => '回收站';

  @override
  String get folderArchive => '归档';

  @override
  String get inboxEmptyInbox => '暂无邮件';

  @override
  String get inboxEmptySent => '没有已发送邮件';

  @override
  String get inboxEmptyTrash => '回收站为空';

  @override
  String get inboxEmptyArchive => '归档为空';

  @override
  String get inboxSyncFromRelays => '从中继同步';

  @override
  String get inboxSearch => '搜索';

  @override
  String get inboxSync => '同步';

  @override
  String get inboxMenu => '菜单';

  @override
  String get inboxClearSelection => '清除选择';

  @override
  String inboxSelectedCount(int count) {
    return '已选择 $count 项';
  }

  @override
  String get inboxProfile => '个人资料';

  @override
  String get inboxCopyNpub => '复制 npub';

  @override
  String get inboxLogout => '退出登录';

  @override
  String get inboxAccount => '账户';

  @override
  String get inboxCompose => '撰写';

  @override
  String get inboxNpubCopied => '已复制 npub';

  @override
  String get inboxUnknown => '未知';

  @override
  String get inboxEditProfile => '编辑个人资料';

  @override
  String get inboxSettings => '设置';

  @override
  String get inboxDeleteOldEmailsTitle => '删除旧邮件';

  @override
  String inboxDeleteOldEmailsMessage(int count) {
    return '这将永久删除 $count 封超过 30 天的邮件。\n\n此操作无法撤销。';
  }

  @override
  String get inboxDeleteFailed => '删除失败';

  @override
  String inboxDeleteFailedDescription(String error) {
    return '无法删除旧邮件: $error';
  }

  @override
  String inboxOldEmailsCount(int count) {
    return '$count 封待删除的旧邮件';
  }

  @override
  String get inboxDeleteNow => '立即删除';

  @override
  String get inboxDeleteOldEmailsTooltip => '删除旧邮件';

  @override
  String get inboxSearchHint => '搜索所有邮件...';

  @override
  String get inboxCloseSearch => '关闭搜索';

  @override
  String get inboxSelectAll => '全选';

  @override
  String get inboxMoreActions => '更多操作';

  @override
  String get emailReply => '回复';

  @override
  String get emailForward => '转发';

  @override
  String get emailArchive => '归档';

  @override
  String get emailUnarchive => '取消归档';

  @override
  String get emailMarkAsRead => '标记为已读';

  @override
  String get emailMarkAsUnread => '标记为未读';

  @override
  String get emailMoveToTrash => '移至回收站';

  @override
  String get emailRestore => '恢复';

  @override
  String get emailDeletePermanently => '永久删除';

  @override
  String get emailNoSubject => '(无主题)';

  @override
  String emailExtraRecipients(int count) {
    return '另外 $count 位收件人';
  }

  @override
  String get emailNotFound => '未找到邮件';

  @override
  String get emailShowFormatted => '显示格式化版本';

  @override
  String get emailShowRaw => '显示源代码';

  @override
  String emailSenderNpub(String npub) {
    return '发件人 npub: $npub';
  }

  @override
  String get emailDeletePermanentlyTitle => '永久删除?';

  @override
  String get emailDeletePermanentlyMessage => '此操作无法撤销。';

  @override
  String get emailDefaultFilename => 'email';

  @override
  String emailSaved(String path) {
    return '邮件已保存: $path';
  }

  @override
  String emailSaveFailed(String error) {
    return '保存邮件失败: $error';
  }

  @override
  String get emailRawContentUnavailable => '无法加载邮件内容';

  @override
  String get emailRepostFailedEvent => '无法获取用于转发的邮件事件';

  @override
  String get emailRepostSuccess => '邮件转发成功';

  @override
  String emailRepostFailed(String error) {
    return '转发邮件失败: $error';
  }

  @override
  String get emailAttachmentLoadFailed => '加载附件失败';

  @override
  String emailFileSaved(String path) {
    return '文件已保存: $path';
  }

  @override
  String emailFileSaveFailed(String error) {
    return '保存文件失败: $error';
  }

  @override
  String emailDownloadedAllSuccess(int count) {
    return '成功下载 $count 个文件';
  }

  @override
  String emailDownloadedAllFailed(int count) {
    return '无法下载 $count 个文件';
  }

  @override
  String emailDownloadedMixed(int success, int failed) {
    return '成功 $success 个,失败 $failed 个';
  }

  @override
  String get emailDownload => '下载';

  @override
  String get emailImageLoadFailed => '加载图片失败';

  @override
  String get emailPdfLoadFailed => '加载 PDF 失败';

  @override
  String get emailActionReply => '回复';

  @override
  String get emailActionReplyAll => '全部回复';

  @override
  String get emailActionForward => '转发';

  @override
  String get emailActionArchive => '归档';

  @override
  String get emailActionUnarchive => '取消归档';

  @override
  String get emailActionMarkRead => '已读';

  @override
  String get emailActionMarkUnread => '未读';

  @override
  String get emailActionNip59 => 'NIP-59 事件';

  @override
  String get emailActionRepost => '转发';

  @override
  String get emailActionDownload => '下载邮件';

  @override
  String get emailMoreActions => '更多操作';

  @override
  String get emailMoreOptions => '更多选项';

  @override
  String get emailShowRecipients => '显示收件人';

  @override
  String get emailImagesHidden => '为保护隐私,图片已隐藏';

  @override
  String get emailLoadImages => '加载图片';

  @override
  String get emailRecipientTo => '收件人';

  @override
  String get emailRecipientCc => '抄送';

  @override
  String get emailRecipientBcc => '密送';

  @override
  String get emailAttachmentsTitle => '附件';

  @override
  String get emailDownloadAll => '全部下载';

  @override
  String get emailNip59Dismiss => '关闭';

  @override
  String get emailNip59Title => 'NIP-59 事件';

  @override
  String get emailNip59GiftWrap => 'Gift Wrap';

  @override
  String get emailNip59Seal => 'Seal';

  @override
  String get emailNip59Rumor => 'Rumor';

  @override
  String get emailNip59CopyJson => '复制 JSON';

  @override
  String emailNip59Kind(int kind) {
    return 'Kind $kind';
  }

  @override
  String get emailNip59NotAvailable => '不可用';

  @override
  String get authHeaderTitle => '登录 Nmail';

  @override
  String get authSyncCodeLabel => '同步码';

  @override
  String get authInvalidSyncCode => '无效的同步码';

  @override
  String get authInvalidSyncCodeDescription => '我们会在您输入时检查代码。一旦有效,您将自动登录。';

  @override
  String get authLogIn => '登录';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authMoreOptions => '更多选项';

  @override
  String get authRegisterPrompt => '其他人会看到什么?';

  @override
  String get authDisplayNameLabel => '显示名称';

  @override
  String get authDisplayNameHint => '例如 Alice';

  @override
  String get authBackToLogin => '返回登录';

  @override
  String get authUnableRetrieveCode => '无法获取同步码';

  @override
  String get authYourSyncCode => '您的同步码';

  @override
  String get authSyncCodeIntro => '此代码是您账户的密钥。它赋予您完全的控制权,并允许您:';

  @override
  String get authSyncCodeFeatureRestore => '在任何设备上恢复您的账户';

  @override
  String get authSyncCodeFeatureBackup => '安全备份您的身份';

  @override
  String get authSyncCodeFeatureLogin => '登录其他 Nostr 应用';

  @override
  String get authSyncCodeWarning => '切勿与任何人分享此代码。请保存在安全的地方。您随时可以在「设置」中找到它。';

  @override
  String get authCopied => '已复制!';

  @override
  String get authCopySyncCode => '复制同步码';

  @override
  String get authContinueToInbox => '进入收件箱';

  @override
  String get composeTitle => '撰写';

  @override
  String get composeTo => '收件人';

  @override
  String get composeAddMore => '添加更多';

  @override
  String get composeHideExpanded => '隐藏抄送/密送/发件人';

  @override
  String get composeShowExpanded => '显示抄送/密送/发件人';

  @override
  String get composeCc => '抄送';

  @override
  String get composeBcc => '密送';

  @override
  String get composeSubject => '主题';

  @override
  String get composeAttachFile => '添加附件';

  @override
  String get composePlaceholder => '撰写邮件';

  @override
  String get composeFrom => '发件人';

  @override
  String get composeSendAs => '发送身份';

  @override
  String get composeCreateNewIdentity => '创建新身份';

  @override
  String get composeRemoveAttachment => '移除附件';

  @override
  String get composeSend => '发送';

  @override
  String get composeMoreSendOptions => '更多发送选项';

  @override
  String get composeChooseSendMode => '选择发送模式';

  @override
  String get composeModePrivateDeniable => '私密(可否认)';

  @override
  String get composeModePrivateSigned => '私密(已签名)';

  @override
  String get composeModePublic => '公开';

  @override
  String get composeModePrivateDeniableDescription => '作为加密邮件发送。无签名 — 必要时可否认。';

  @override
  String get composeModePrivateSignedDescription => '作为加密邮件发送。已签名 — 证明您是作者。';

  @override
  String get composeModePublicDescription => '作为公开事件发送。任何人都能阅读。无加密。';

  @override
  String get composeResolvingNip05 => '正在解析 NIP-05...';

  @override
  String get contactSourceAddressBook => 'Address book';

  @override
  String get contactSourceEmailHistory => '邮件历史';

  @override
  String get contactSourceFollowing => '关注中';

  @override
  String get contactSourceCachedProfile => '缓存的资料';

  @override
  String get contactSourceNip05Verified => '已验证 NIP-05';

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
  String get contactsNostrTitle => 'Nostr';

  @override
  String get profileEditTitle => '编辑个人资料';

  @override
  String get profileDisplayNameLabel => '显示名称';

  @override
  String get profileDisplayNameHint => '您的全名或别名';

  @override
  String get profileUsernameLabel => '用户名';

  @override
  String get profileUsernameHint => '用户名';

  @override
  String get profileAboutLabel => '关于';

  @override
  String get profileAboutHint => '关于您的简短介绍';

  @override
  String get profileAdvanced => '高级';

  @override
  String get profilePictureUrlLabel => '图片 URL';

  @override
  String get profilePictureUrlHint => 'https://example.com/avatar.png';

  @override
  String get profileChangePicture => '更换头像';

  @override
  String get onboardingPage1Title => '欢迎使用 Nmail';

  @override
  String get onboardingPage1Body => '发现一种由您掌控的去中心化邮件体验。一种围绕您构建的全新沟通方式。';

  @override
  String get onboardingPage2Title => '没有主宰的网络';

  @override
  String get onboardingPage2Body => '您的消息通过全球独立服务器网络传输。没有任何一家公司拥有您的收件箱。';

  @override
  String get onboardingPage3Title => '选择的自由';

  @override
  String get onboardingPage3Body => '您永远不会被锁定在单一提供商。随时切换桥接或中继,不会丢失身份或联系人。';

  @override
  String get onboardingPage4Title => '一个身份打通一切';

  @override
  String get onboardingPage4Body => '用您的账户发邮件、关注资料或使用其他应用。在众多应用中通用的永久身份。';

  @override
  String get onboardingPage5Title => '为未来而设计';

  @override
  String get onboardingPage5Body =>
      '受益于专为隐私设计的现代架构。Nmail 助您平稳过渡到更安全、更具韧性的沟通方式。';

  @override
  String get onboardingPage6Title => '抢先体验';

  @override
  String get onboardingPage6Body =>
      'Nmail 及其背后的协议都还很年轻。一切都尽力做到最好，但仍可能出现 bug，有些功能可能显得缓慢或缺失。感谢你成为早期用户。你的耐心将塑造接下来的发展。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingDone => '完成';

  @override
  String get createIdentityTitle => '创建身份';

  @override
  String get createIdentityAddress => '地址';

  @override
  String get createIdentityCustomUsername => '自定义用户名';

  @override
  String get createIdentityBridge => '桥接';

  @override
  String get createIdentityNoBridges => '没有可用的桥接';

  @override
  String get createIdentityBridgeHint => 'bridge.com';

  @override
  String get createIdentityPreview => '预览';

  @override
  String get createIdentityPreviewEmpty => '输入地址并选择桥接以查看预览';

  @override
  String get createIdentityAlreadyExists => '此身份已存在';

  @override
  String get leftRailSettings => '设置';

  @override
  String get linkOpenTitle => '打开链接?';

  @override
  String get linkCopied => '已复制链接';

  @override
  String get debugNotAuthenticated => '未认证';

  @override
  String get debugTestEmailCreated => '测试邮件已创建并移至回收站(31 天)';

  @override
  String get debugTestEmailPartial => '邮件已创建并移至回收站,但无法更新时间戳';

  @override
  String debugError(String error) {
    return '错误: $error';
  }

  @override
  String get composeSelectAttachments => '选择附件';

  @override
  String composePickFilesFailed(String error) {
    return '选择文件失败: $error';
  }

  @override
  String get composeInvalidRecipient => '收件人格式无效';

  @override
  String get composeAddRecipient => '请至少添加一位收件人';

  @override
  String get composeSendFailed => '发送邮件失败';

  @override
  String get profileLoadFailed => '加载个人资料失败';

  @override
  String get profileSelectPicture => '选择头像';

  @override
  String get profileUploadNoServers => '没有服务器响应';

  @override
  String get profileUploadFailed => '上传失败';

  @override
  String get profileUploadError => '上传过程中发生错误';

  @override
  String get profileUpdateFailed => '更新个人资料失败';

  @override
  String get authEnterUsername => '请输入用户名';

  @override
  String createIdentityFailed(String error) {
    return '创建身份失败: $error';
  }

  @override
  String get dateYesterday => '昨天';

  @override
  String get notFoundTitle => '页面未找到';

  @override
  String get notFoundBackToInbox => '返回收件箱';
}
