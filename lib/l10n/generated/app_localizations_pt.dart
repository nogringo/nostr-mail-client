// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionOpen => 'Abrir';

  @override
  String get actionUpload => 'Enviar';

  @override
  String get actionReset => 'Redefinir';

  @override
  String get actionUndo => 'Desfazer';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get stateLoading => 'Carregando';

  @override
  String get stateLoadingEllipsis => 'Carregando...';

  @override
  String get stateResetting => 'Redefinindo...';

  @override
  String get stateValidating => 'Validando...';

  @override
  String get stateDownloading => 'Baixando...';

  @override
  String get stateUploading => 'Enviando...';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsDynamicTheme => 'Tema dinâmico';

  @override
  String get settingsDynamicThemeSubtitle =>
      'Gerar cores a partir da imagem de fundo';

  @override
  String get settingsAdvancedOptions => 'Opções avançadas';

  @override
  String get settingsShowEmailSource => 'Mostrar código-fonte do e-mail';

  @override
  String get settingsShowEmailSourceSubtitle =>
      'Adiciona um botão para ver o e-mail bruto';

  @override
  String get settingsAlwaysLoadImages => 'Sempre carregar imagens';

  @override
  String get settingsAlwaysLoadImagesSubtitle =>
      'Imagens são bloqueadas por padrão para privacidade';

  @override
  String get settingsIdentities => 'Identidades';

  @override
  String get settingsManageIdentities => 'Gerenciar identidades';

  @override
  String get settingsManageIdentitiesSubtitle =>
      'Adicionar, remover ou reordenar endereços';

  @override
  String get settingsCompose => 'Composição';

  @override
  String get settingsEmailSignature => 'Assinatura de e-mail';

  @override
  String get settingsEmailSignatureEmpty => 'Nenhuma assinatura configurada';

  @override
  String get settingsEmailSignatureHint => 'Digite sua assinatura...';

  @override
  String get settingsSynchronization => 'Sincronização';

  @override
  String get settingsHosting => 'Hospedagem';

  @override
  String get settingsHostingSubtitle =>
      'Relays, servidores Blossom, conectividade';

  @override
  String get settingsDebugTools => 'Ferramentas de depuração';

  @override
  String get settingsDebugToolsSubtitle =>
      'Recursos de teste e desenvolvimento';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsCopySyncCode => 'Copiar código de sincronização';

  @override
  String get settingsCopySyncCodeSubtitle =>
      'Use este código para sincronizar sua conta em outros dispositivos';

  @override
  String get settingsSyncCodeCopied => 'Código de sincronização copiado';

  @override
  String get settingsLogOut => 'Sair';

  @override
  String get settingsResetApplication => 'Redefinir aplicativo';

  @override
  String get settingsResetApplicationSubtitle =>
      'Excluir todos os dados locais';

  @override
  String get settingsResetConfirmMessage =>
      'Isso excluirá todos os dados locais, incluindo configurações e imagens de fundo, e fará logout.\n\nEsta ação não pode ser desfeita.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsBackgroundDefaultLabel => 'Cor padrão do tema';

  @override
  String get settingsBackgroundSelectLabel => 'Selecionar imagem de fundo';

  @override
  String get settingsBackgroundDeleteLabel => 'Excluir imagem de fundo';

  @override
  String get settingsBackgroundRemoveLabel => 'Remover imagem de fundo';

  @override
  String get settingsBackgroundAddLabel => 'Adicionar imagem de fundo';

  @override
  String get settingsBackgroundDeleteTitle => 'Excluir fundo';

  @override
  String get settingsBackgroundDeleteMessage =>
      'Remover esta imagem dos seus fundos salvos?';

  @override
  String get settingsBackgroundImageDeleted => 'Imagem excluída';

  @override
  String get settingsBackgroundDeleteFailed => 'Falha ao excluir a imagem';

  @override
  String get settingsBackgroundDialogTitle => 'Fundo';

  @override
  String get settingsBackgroundSelectFile => 'Selecionar arquivo';

  @override
  String get settingsBackgroundPasteUrl => 'Colar URL';

  @override
  String get settingsBackgroundUrlTitle => 'URL do fundo';

  @override
  String get settingsBackgroundUrlHint => 'https://exemplo.com/imagem.jpg';

  @override
  String get settingsBackgroundSet => 'Fundo definido';

  @override
  String get settingsBackgroundImageSet => 'Imagem definida';

  @override
  String get settingsBackgroundCopyFailed => 'Falha ao copiar a imagem';

  @override
  String get settingsBackgroundUrlError =>
      'Imagem inacessível (erro de CORS ou rede)';

  @override
  String get settingsBackgroundDownloaded => 'Imagem baixada';

  @override
  String get settingsBackgroundDownloadFailed => 'Falha ao baixar a imagem';

  @override
  String get settingsBackgroundUploadTitle => 'Enviar imagem';

  @override
  String get settingsBackgroundUploadWarning =>
      'Esta imagem será enviada para servidores Blossom. Os operadores dos servidores e qualquer pessoa com o link poderão vê-la.';

  @override
  String get hostingRecommended => 'Recomendados:';

  @override
  String hostingWillBeAddedAs(String url) {
    return 'Será adicionado como: $url';
  }

  @override
  String get relayAddTitle => 'Adicionar relay';

  @override
  String get relayUrlLabel => 'URL do relay';

  @override
  String get relayUrlHint => 'wss://relay.exemplo.com';

  @override
  String get relayInvalidUrl => 'URL de relay inválida';

  @override
  String get relayDirection => 'Direção';

  @override
  String get relayReadWrite => 'Leitura e escrita';

  @override
  String get relayRead => 'Leitura';

  @override
  String get relayWrite => 'Escrita';

  @override
  String get relayMarkerReadWrite => 'leitura/escrita';

  @override
  String get relayMarkerRead => 'leitura';

  @override
  String get relayMarkerWrite => 'escrita';

  @override
  String get relayInboxOutboxTitle => 'Relays de entrada e saída';

  @override
  String get relayAddTooltip => 'Adicionar relay';

  @override
  String get relayRemoveTooltip => 'Remover relay';

  @override
  String get relayInboxOutboxEmpty =>
      'Nenhum relay de entrada/saída configurado';

  @override
  String get relayEmptyHint => 'Toque em + para adicionar um relay';

  @override
  String get dmRelayAddTitle => 'Adicionar relay DM';

  @override
  String get dmRelaySectionTitle => 'Relays DM';

  @override
  String get dmRelayEmpty => 'Nenhum relay DM configurado';

  @override
  String get bridgeAddTitle => 'Adicionar bridge';

  @override
  String get bridgeDomainLabel => 'Domínio do bridge';

  @override
  String get bridgeDomainHint => 'bridge.exemplo.com';

  @override
  String get bridgeInvalidDomain => 'Domínio inválido';

  @override
  String get bridgeSectionTitle => 'Bridges';

  @override
  String get bridgeAddTooltip => 'Adicionar bridge';

  @override
  String get bridgeEmpty => 'Nenhum bridge configurado';

  @override
  String get bridgeEmptyHint => 'Toque em + para adicionar um bridge';

  @override
  String get bridgeDefault => 'Bridge padrão';

  @override
  String get blossomAddTitle => 'Adicionar servidor Blossom';

  @override
  String get blossomServerUrlLabel => 'URL do servidor';

  @override
  String get blossomServerUrlHint => 'https://blossom.exemplo.com';

  @override
  String get blossomInvalidUrl => 'URL de servidor inválida';

  @override
  String get blossomSectionTitle => 'Hospedagem de arquivos';

  @override
  String get blossomAddTooltip => 'Adicionar servidor';

  @override
  String get blossomRemoveTooltip => 'Remover servidor';

  @override
  String get blossomEmpty => 'Nenhum servidor Blossom configurado';

  @override
  String get blossomEmptyHint => 'Toque em + para adicionar um servidor';

  @override
  String get connectivitySectionTitle => 'Conexão em tempo real';

  @override
  String get connectivityRelayConnectivity => 'Conectividade dos relays';

  @override
  String get syncStatusSectionTitle => 'Status de sincronização';

  @override
  String get syncStatusEmpty => 'Nenhum dado de sincronização disponível';

  @override
  String get syncStatusEmptyHint =>
      'Sincronize seus e-mails para ver o status dos relays';

  @override
  String get syncStatusResync => 'Ressincronizar';

  @override
  String get syncStatusBeginningOfTime => 'Início dos tempos';

  @override
  String get identitiesTitle => 'Identidades';

  @override
  String get identitiesEmptyTitle => 'Nenhuma identidade ainda';

  @override
  String get identitiesEmptyMessage =>
      'Crie uma para enviar e-mails a partir de um endereço personalizado.';

  @override
  String get identitiesCreate => 'Criar identidade';

  @override
  String get identitiesDiscardTitle => 'Descartar alterações?';

  @override
  String get identitiesDiscardMessage =>
      'Você tem alterações não salvas. Sair agora irá descartá-las.';

  @override
  String get identitiesKeepEditing => 'Continuar editando';

  @override
  String get debugToolsEmailTesting => 'Teste de e-mails';

  @override
  String get debugToolsCreateOldTrashed => 'Criar e-mail antigo na lixeira';

  @override
  String get debugToolsCreateOldTrashedDescription =>
      'Cria um e-mail de teste na lixeira com 31 dias. Use para testar o recurso \"Excluir e-mails antigos\".';

  @override
  String get folderInbox => 'Caixa de entrada';

  @override
  String get folderSent => 'Enviados';

  @override
  String get folderTrash => 'Lixeira';

  @override
  String get folderArchive => 'Arquivo';

  @override
  String get inboxEmptyInbox => 'Nenhum e-mail ainda';

  @override
  String get inboxEmptySent => 'Nenhum e-mail enviado';

  @override
  String get inboxEmptyTrash => 'A lixeira está vazia';

  @override
  String get inboxEmptyArchive => 'O arquivo está vazio';

  @override
  String get inboxSyncFromRelays => 'Sincronizar dos relays';

  @override
  String get inboxSearch => 'Pesquisar';

  @override
  String get inboxSync => 'Sincronizar';

  @override
  String get inboxMenu => 'Menu';

  @override
  String get inboxClearSelection => 'Limpar seleção';

  @override
  String inboxSelectedCount(int count) {
    return '$count selecionado(s)';
  }

  @override
  String get inboxProfile => 'Perfil';

  @override
  String get inboxCopyNpub => 'Copiar npub';

  @override
  String get inboxLogout => 'Sair';

  @override
  String get inboxAccount => 'Conta';

  @override
  String get inboxCompose => 'Compor';

  @override
  String get inboxNpubCopied => 'npub copiado';

  @override
  String get inboxUnknown => 'Desconhecido';

  @override
  String get inboxEditProfile => 'Editar perfil';

  @override
  String get inboxSettings => 'Configurações';

  @override
  String get inboxDeleteOldEmailsTitle => 'Excluir e-mails antigos';

  @override
  String inboxDeleteOldEmailsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# e-mails',
      one: '# e-mail',
    );
    return 'Isso excluirá permanentemente $_temp0 com mais de 30 dias.\n\nEsta ação não pode ser desfeita.';
  }

  @override
  String get inboxDeleteFailed => 'Falha na exclusão';

  @override
  String inboxDeleteFailedDescription(String error) {
    return 'Falha ao excluir e-mails antigos: $error';
  }

  @override
  String inboxOldEmailsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# e-mails antigos a excluir',
      one: '# e-mail antigo a excluir',
    );
    return '$_temp0';
  }

  @override
  String get inboxDeleteNow => 'Excluir agora';

  @override
  String get inboxDeleteOldEmailsTooltip => 'Excluir e-mails antigos';

  @override
  String get inboxSearchHint => 'Pesquisar em todos os e-mails...';

  @override
  String get inboxCloseSearch => 'Fechar pesquisa';

  @override
  String get inboxSelectAll => 'Selecionar tudo';

  @override
  String get inboxMoreActions => 'Mais ações';

  @override
  String get emailReply => 'Responder';

  @override
  String get emailForward => 'Encaminhar';

  @override
  String get emailArchive => 'Arquivar';

  @override
  String get emailUnarchive => 'Desarquivar';

  @override
  String get emailMarkAsRead => 'Marcar como lido';

  @override
  String get emailMarkAsUnread => 'Marcar como não lido';

  @override
  String get emailMoveToTrash => 'Mover para lixeira';

  @override
  String get emailRestore => 'Restaurar';

  @override
  String get emailDeletePermanently => 'Excluir permanentemente';

  @override
  String get emailNoSubject => '(Sem assunto)';

  @override
  String get emailNotFound => 'E-mail não encontrado';

  @override
  String get emailShowFormatted => 'Mostrar formatado';

  @override
  String get emailShowRaw => 'Mostrar fonte';

  @override
  String emailSenderNpub(String npub) {
    return 'npub do remetente: $npub';
  }

  @override
  String get emailDeletePermanentlyTitle => 'Excluir permanentemente?';

  @override
  String get emailDeletePermanentlyMessage =>
      'Esta ação não pode ser desfeita.';

  @override
  String get emailDefaultFilename => 'email';

  @override
  String emailSaved(String path) {
    return 'E-mail salvo: $path';
  }

  @override
  String emailSaveFailed(String error) {
    return 'Falha ao salvar o e-mail: $error';
  }

  @override
  String get emailRepostFailedEvent => 'Falha ao obter evento para repostar';

  @override
  String get emailRepostSuccess => 'E-mail repostado com sucesso';

  @override
  String emailRepostFailed(String error) {
    return 'Falha ao repostar o e-mail: $error';
  }

  @override
  String get emailAttachmentLoadFailed => 'Falha ao carregar o anexo';

  @override
  String emailFileSaved(String path) {
    return 'Arquivo salvo: $path';
  }

  @override
  String emailFileSaveFailed(String error) {
    return 'Falha ao salvar o arquivo: $error';
  }

  @override
  String emailDownloadedAllSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# arquivos baixados com sucesso',
      one: '# arquivo baixado com sucesso',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Falha ao baixar # arquivos',
      one: 'Falha ao baixar # arquivo',
    );
    return '$_temp0';
  }

  @override
  String emailDownloadedMixed(int success, int failed) {
    return '$success arquivos baixados, $failed falharam';
  }

  @override
  String get emailDownload => 'Baixar';

  @override
  String get emailImageLoadFailed => 'Falha ao carregar a imagem';

  @override
  String get emailPdfLoadFailed => 'Falha ao carregar o PDF';

  @override
  String get emailActionReply => 'Responder';

  @override
  String get emailActionReplyAll => 'Responder a todos';

  @override
  String get emailActionForward => 'Encaminhar';

  @override
  String get emailActionArchive => 'Arquivar';

  @override
  String get emailActionUnarchive => 'Desarquivar';

  @override
  String get emailActionMarkRead => 'Marcar lido';

  @override
  String get emailActionMarkUnread => 'Marcar não lido';

  @override
  String get emailActionNip59 => 'Eventos NIP-59';

  @override
  String get emailActionRepost => 'Repostar';

  @override
  String get emailActionDownload => 'Baixar e-mail';

  @override
  String get emailMoreActions => 'Mais ações';

  @override
  String get emailMoreOptions => 'Mais opções';

  @override
  String get emailShowRecipients => 'Mostrar destinatários';

  @override
  String get emailImagesHidden => 'Imagens ocultas por privacidade';

  @override
  String get emailLoadImages => 'Carregar imagens';

  @override
  String get emailRecipientTo => 'Para';

  @override
  String get emailRecipientCc => 'Cc';

  @override
  String get emailRecipientBcc => 'Cco';

  @override
  String get emailAttachmentsTitle => 'Anexos';

  @override
  String get emailDownloadAll => 'Baixar todos';

  @override
  String get emailNip59Dismiss => 'Fechar';

  @override
  String get emailNip59Title => 'Eventos NIP-59';

  @override
  String get emailNip59GiftWrap => 'Gift Wrap';

  @override
  String get emailNip59Seal => 'Seal';

  @override
  String get emailNip59Rumor => 'Rumor';

  @override
  String get emailNip59CopyJson => 'Copiar JSON';

  @override
  String emailNip59Kind(int kind) {
    return 'Kind $kind';
  }

  @override
  String get emailNip59NotAvailable => 'Não disponível';

  @override
  String get authHeaderTitle => 'Entrar no Nmail';

  @override
  String get authSyncCodeLabel => 'Código de sincronização';

  @override
  String get authInvalidSyncCode => 'Código de sincronização inválido';

  @override
  String get authInvalidSyncCodeDescription =>
      'Estamos verificando seu código enquanto você digita. Assim que for válido, você será conectado automaticamente.';

  @override
  String get authLogIn => 'Entrar';

  @override
  String get authCreateAccount => 'Criar uma conta';

  @override
  String get authMoreOptions => 'Mais opções';

  @override
  String get authRegisterPrompt => 'O que os outros devem ver?';

  @override
  String get authDisplayNameLabel => 'Nome de exibição';

  @override
  String get authDisplayNameHint => 'ex. Alice';

  @override
  String get authBackToLogin => 'Voltar para login';

  @override
  String get authUnableRetrieveCode =>
      'Não foi possível recuperar o código de sincronização';

  @override
  String get authYourSyncCode => 'Seu código de sincronização';

  @override
  String get authSyncCodeIntro =>
      'Este código é a chave da sua conta. Ele dá controle total e permite que você:';

  @override
  String get authSyncCodeFeatureRestore =>
      'Restaure sua conta em qualquer dispositivo';

  @override
  String get authSyncCodeFeatureBackup =>
      'Faça backup da sua identidade com segurança';

  @override
  String get authSyncCodeFeatureLogin => 'Entre em outros aplicativos Nostr';

  @override
  String get authSyncCodeWarning =>
      'Nunca compartilhe este código com ninguém. Guarde-o em um lugar seguro. Você sempre poderá encontrá-lo depois em Configurações.';

  @override
  String get authCopied => 'Copiado!';

  @override
  String get authCopySyncCode => 'Copiar código de sincronização';

  @override
  String get authContinueToInbox => 'Ir para a caixa de entrada';

  @override
  String get composeTitle => 'Compor';

  @override
  String get composeTo => 'Para';

  @override
  String get composeAddMore => 'Adicionar mais';

  @override
  String get composeHideExpanded => 'Ocultar Cc/Cco/De';

  @override
  String get composeShowExpanded => 'Mostrar Cc/Cco/De';

  @override
  String get composeCc => 'Cc';

  @override
  String get composeBcc => 'Cco';

  @override
  String get composeSubject => 'Assunto';

  @override
  String get composeAttachFile => 'Anexar arquivo';

  @override
  String get composePlaceholder => 'Escreva seu e-mail';

  @override
  String get composeFrom => 'De';

  @override
  String get composeSendAs => 'Enviar como';

  @override
  String get composeCreateNewIdentity => 'Criar nova identidade';

  @override
  String get composeRemoveAttachment => 'Remover anexo';

  @override
  String get composeSend => 'Enviar';

  @override
  String get composeMoreSendOptions => 'Mais opções de envio';

  @override
  String get composeChooseSendMode => 'Escolher modo de envio';

  @override
  String get composeModePrivateDeniable => 'Privado negável';

  @override
  String get composeModePrivateSigned => 'Privado assinado';

  @override
  String get composeModePublic => 'Público';

  @override
  String get composeModePrivateDeniableDescription =>
      'Enviar como e-mail criptografado. Sem assinatura — negável se necessário.';

  @override
  String get composeModePrivateSignedDescription =>
      'Enviar como e-mail criptografado. Assinado — prova que você é o autor.';

  @override
  String get composeModePublicDescription =>
      'Enviar como evento público. Qualquer pessoa pode ler. Sem criptografia.';

  @override
  String get composeResolvingNip05 => 'Resolvendo NIP-05...';

  @override
  String get contactSourceEmailHistory => 'Histórico de e-mails';

  @override
  String get contactSourceFollowing => 'Seguindo';

  @override
  String get contactSourceCachedProfile => 'Perfil em cache';

  @override
  String get contactSourceNip05Verified => 'Verificado NIP-05';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileDisplayNameLabel => 'Nome de exibição';

  @override
  String get profileDisplayNameHint => 'Seu nome completo ou apelido';

  @override
  String get profileUsernameLabel => 'Nome de usuário';

  @override
  String get profileUsernameHint => 'identificador';

  @override
  String get profileAboutLabel => 'Sobre';

  @override
  String get profileAboutHint => 'Uma breve biografia sobre você';

  @override
  String get profileAdvanced => 'Avançado';

  @override
  String get profilePictureUrlLabel => 'URL da imagem';

  @override
  String get profilePictureUrlHint => 'https://exemplo.com/avatar.png';

  @override
  String get profileChangePicture => 'Alterar foto de perfil';

  @override
  String get onboardingPage1Title => 'Bem-vindo ao Nmail';

  @override
  String get onboardingPage1Body =>
      'Descubra uma experiência de e-mail descentralizada que coloca você no controle. Uma nova forma de comunicar, centrada em você.';

  @override
  String get onboardingPage2Title => 'Uma rede sem donos';

  @override
  String get onboardingPage2Body =>
      'Suas mensagens passam por uma rede global de servidores independentes. Nenhuma empresa é dona da sua caixa de entrada.';

  @override
  String get onboardingPage3Title => 'Liberdade de escolha';

  @override
  String get onboardingPage3Body =>
      'Você nunca fica preso a um único provedor. Troque de bridges ou relays a qualquer momento sem perder sua identidade ou contatos.';

  @override
  String get onboardingPage4Title => 'Uma identidade para tudo';

  @override
  String get onboardingPage4Body =>
      'Use sua conta para enviar e-mails, seguir perfis ou usar outros aplicativos. Uma identidade permanente que funciona em muitos aplicativos diferentes.';

  @override
  String get onboardingPage5Title => 'Feito para o futuro';

  @override
  String get onboardingPage5Body =>
      'Aproveite uma arquitetura moderna projetada para privacidade. O Nmail ajuda você a fazer uma transição suave para uma forma mais segura e resiliente de comunicar.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingDone => 'Concluído';

  @override
  String get createIdentityTitle => 'Criar identidade';

  @override
  String get createIdentityAddress => 'Endereço';

  @override
  String get createIdentityCustomUsername => 'Nome de usuário personalizado';

  @override
  String get createIdentityBridge => 'Bridge';

  @override
  String get createIdentityNoBridges => 'Nenhum bridge disponível';

  @override
  String get createIdentityBridgeHint => 'bridge.com';

  @override
  String get createIdentityPreview => 'Visualização';

  @override
  String get createIdentityPreviewEmpty =>
      'Digite um endereço e selecione um bridge para ver a visualização';

  @override
  String get leftRailSettings => 'Configurações';

  @override
  String get linkOpenTitle => 'Abrir link?';

  @override
  String get linkCopied => 'Link copiado';

  @override
  String get debugNotAuthenticated => 'Não autenticado';

  @override
  String get debugTestEmailCreated =>
      'E-mail de teste criado e movido para a lixeira (31 dias)';

  @override
  String get debugTestEmailPartial =>
      'E-mail criado e movido para a lixeira, mas não foi possível atualizar o carimbo de data/hora';

  @override
  String debugError(String error) {
    return 'Erro: $error';
  }

  @override
  String get composeSelectAttachments => 'Selecionar anexos';

  @override
  String composePickFilesFailed(String error) {
    return 'Falha ao selecionar arquivos: $error';
  }

  @override
  String get composeInvalidRecipient => 'Formato de destinatário inválido';

  @override
  String get composeAddRecipient => 'Adicione pelo menos um destinatário';

  @override
  String get composeSendFailed => 'Falha ao enviar o e-mail';

  @override
  String get profileLoadFailed => 'Falha ao carregar dados do perfil';

  @override
  String get profileSelectPicture => 'Selecionar foto de perfil';

  @override
  String get profileUploadNoServers => 'Nenhum servidor respondeu';

  @override
  String get profileUploadFailed => 'Falha no envio';

  @override
  String get profileUploadError => 'Ocorreu um erro durante o envio';

  @override
  String get profileUpdateFailed => 'Falha ao atualizar o perfil';

  @override
  String get authEnterUsername => 'Por favor, insira um nome de usuário';

  @override
  String createIdentityFailed(String error) {
    return 'Falha ao criar identidade: $error';
  }

  @override
  String get dateYesterday => 'Ontem';

  @override
  String get dateJustNow => 'just now';

  @override
  String dateMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String dateHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '1 h ago',
    );
    return '$_temp0';
  }

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String localQueueIndicatorLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# items pending sync',
      one: '# item pending sync',
    );
    return '$_temp0';
  }

  @override
  String get localQueueHeaderTitle => 'Pending on this device';

  @override
  String get localQueueEmptyTitle => 'Everything is synced';

  @override
  String get localQueueEmptyHint =>
      'All your events and files have been broadcast to their relays and servers.';

  @override
  String get localQueueRetryAll => 'Retry all now';

  @override
  String get localQueueRetryItem => 'Retry';

  @override
  String get localQueueSectionBroadcasts => 'EVENTS';

  @override
  String get localQueueSectionUploads => 'FILES';

  @override
  String get localQueueShowDetails => 'Details';

  @override
  String get localQueueHideDetails => 'Hide';

  @override
  String get localQueueStatItems => 'Items';

  @override
  String get localQueueStatSucceeded => 'Succeeded';

  @override
  String get localQueueStatFailed => 'Failed';

  @override
  String localQueueBlobLabel(String hash) {
    return 'Blob $hash';
  }

  @override
  String get localQueueKindMetadata => 'Profile update';

  @override
  String get localQueueKindGiftWrap => 'Email';

  @override
  String get localQueueKindLabel => 'Read/unread state';

  @override
  String get localQueueKindNip65 => 'Relay list';

  @override
  String get localQueueKindDmRelays => 'DM relays';

  @override
  String get localQueueKindBlossomServers => 'Blossom servers';

  @override
  String localQueueKindGeneric(int kind) {
    return 'Event (kind $kind)';
  }
}
