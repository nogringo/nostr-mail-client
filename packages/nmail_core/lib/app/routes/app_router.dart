import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/entities/naddr.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:nostr_mail/nostr_mail.dart' hide Recipient;

import '../../controllers/about_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/backgrounds_controller.dart';
import '../../controllers/blossom_servers_controller.dart';
import '../../controllers/bridges_controller.dart';
import '../../controllers/community_theme_controller.dart';
import '../../controllers/community_themes_controller.dart';
import '../../controllers/compose_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../controllers/dm_relays_controller.dart';
import '../../controllers/identities_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../models/mailbox.dart';
import '../../controllers/nip65_relays_controller.dart';
import '../../controllers/scheduled_controller.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import '../../views/account_deleted/account_deleted_view.dart';
import '../../views/accounts/accounts_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/compose/compose_view.dart';
import '../../views/contacts/contacts_view.dart';
import '../../views/contacts/widgets/contact_form_page.dart';
import '../../views/email/email_controller.dart';
import '../../views/email/email_view.dart';
import '../../views/identity/create_identity_view.dart';
import '../../views/inbox/inbox_view.dart';
import '../../views/inbox/request_sender_view.dart';
import '../../views/nostr/profile_share_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/relay_setup/relay_setup_view.dart';
import '../../views/scheduled/scheduled_view.dart';
import '../../views/settings/about_settings_view.dart';
import '../../views/settings/appearance_settings_view.dart';
import '../../views/settings/community_theme_view.dart';
import '../../views/settings/community_themes_view.dart';
import '../../views/settings/confirm_discard_hosting_changes.dart';
import '../../views/settings/confirm_discard_identity_changes.dart';
import '../../views/settings/debug_tools_view.dart';
import '../../views/settings/hosting_settings_view.dart';
import '../../views/settings/identities_view.dart';
import '../../views/settings/mailboxes_settings_view.dart';
import '../../views/settings/messages_settings_view.dart';
import '../../views/settings/notifications_settings_view.dart';
import '../../views/settings/settings_view.dart';
import '../../views/shared/auth_shell.dart';
import '../../views/shared/not_found_view.dart';
import '../../views/shared/window_caption_inset.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  /// For controllers, which have no `BuildContext` of their own to show
  /// toasts and dialogs.
  static BuildContext? get rootContext => _rootNavigatorKey.currentContext;

  static _AuthRefreshNotifier? _authNotifier;

  /// Must be called from `main()` *after* `AuthController` is registered.
  static GoRouter init() {
    _authNotifier ??= _AuthRefreshNotifier();
    Get.lazyPut(() => InboxController());
    _registerOnce(ContactsController.new);
    return _router;
  }

  /// Global access for controllers that don't have a `BuildContext`
  /// (e.g. `AuthController` after login, `EmailController` after delete).
  /// In widgets, prefer `context.go` / `context.push`.
  static GoRouter get router => _router;

  /// Pop the current route if possible, otherwise fall back to `/inbox`.
  /// Used by controllers after destructive actions (delete, archive)
  /// when we don't know whether the user arrived via in-app navigation
  /// (canPop) or a cold-start deep link (cannot pop).
  static void popOrGoInbox() {
    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go(AppRoutes.inbox);
    }
  }

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.inbox,
    refreshListenable: _authNotifier,
    redirect: _globalRedirect,
    errorBuilder: (_, _) => const WindowCaptionInset(child: NotFoundView()),
    routes: [
      // Public routes (outside shell)
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const WindowCaptionInset(child: LoginView()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const WindowCaptionInset(child: OnboardingView()),
      ),
      GoRoute(
        path: AppRoutes.accountDeleted,
        builder: (_, state) => WindowCaptionInset(
          child: AccountDeletedView(
            requestId:
                state.uri.queryParameters[AppRoutes
                    .accountDeletedRequestParam] ??
                '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.relaySetup,
        builder: (_, _) => const WindowCaptionInset(child: RelaySetupView()),
      ),
      // Account management, outside the shell: full screen, and `add` nests so
      // that leaving it lands back on the list.
      GoRoute(
        path: AppRoutes.accounts,
        builder: (_, _) => const WindowCaptionInset(child: AccountsView()),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, _) => const WindowCaptionInset(
              child: LoginView(isAddingAccount: true),
            ),
          ),
        ],
      ),

      // Authenticated shell: holds DesktopShell (sidebar) on wide screens
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, _, child) => AuthShell(child: child),
        routes: [
          // Root path inside shell: send to inbox
          GoRoute(path: '/', redirect: (_, _) => AppRoutes.inbox),

          // Mailbox routes (URL drives InboxController.currentMailbox).
          // Each one nests `email/:id` so opening a message via
          // `context.go('/<mailbox>/email/<id>')` updates the URL AND
          // preserves a real back-stack to the mailbox.
          _mailboxRoute(AppRoutes.inbox, (_) => Mailbox.inbox),
          _mailboxRoute(
            AppRoutes.requests,
            (_) => Mailbox.requests,
            routes: [
              GoRoute(
                path: AppRoutes.requestSenderSegment,
                builder: (_, state) => RequestSenderView(
                  senderKey: state.pathParameters[AppRoutes.senderKeyParam]!,
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.emailSegment,
                    builder: (_, state) {
                      final id = state.pathParameters['id']!;
                      _ensureEmailController(id, Mailbox.requests);
                      return const EmailView();
                    },
                  ),
                ],
              ),
            ],
          ),
          _mailboxRoute(AppRoutes.sent, (_) => Mailbox.sent),
          _mailboxRoute(AppRoutes.archive, (_) => Mailbox.archive),
          _mailboxRoute(AppRoutes.spam, (_) => Mailbox.spam),
          _mailboxRoute(AppRoutes.trash, (_) => Mailbox.trash),
          _mailboxRoute(
            AppRoutes.userFolder,
            (state) => FolderMailbox(state.pathParameters['folderId']!),
          ),
          _mailboxRoute(
            AppRoutes.label,
            (state) => TagMailbox(state.pathParameters['labelId']!),
          ),

          GoRoute(
            path: AppRoutes.contacts,
            builder: (_, _) => const ContactsView(),
          ),

          GoRoute(
            path: AppRoutes.scheduled,
            pageBuilder: (_, state) {
              if (!Get.isRegistered<ScheduledController>()) {
                Get.put(ScheduledController());
              }
              return NoTransitionPage(
                key: state.pageKey,
                child: const ScheduledView(),
              );
            },
          ),

          // Contact form (create/edit). Full-screen route on mobile; the
          // desktop dialog path is handled imperatively by showContactForm.
          // The ContactFormController is owned by ContactFormPage's
          // ControllerBuilder, so no onExit cleanup is needed here.
          GoRoute(
            path: AppRoutes.contactForm,
            builder: (_, state) {
              final extra = state.extra is Map ? state.extra as Map : null;
              return ContactFormPage(
                contact: extra?['contact'] as AddressBookContact?,
                initialForm: extra?['initialForm'] as AddressBookContactForm?,
              );
            },
          ),

          // Compose
          GoRoute(
            path: AppRoutes.compose,
            // Dispose the controller when the route actually leaves the
            // stack (pop, redirect away). go_router does NOT call onExit
            // on builder rebuilds, so the in-progress draft survives theme
            // changes / refreshListenable fires.
            onExit: (_, _) {
              if (Get.isRegistered<ComposeController>()) {
                Get.delete<ComposeController>();
              }
              return true;
            },
            builder: (_, state) {
              final extra = state.extra is Map ? state.extra as Map : null;
              _ensureComposeController(
                sourceEmail: extra?['email'] as Email?,
                sourceMode: extra?['mode'] as ComposeMode?,
                initialRecipient: extra?['recipient'] as Recipient?,
                editingScheduled: extra?['scheduledEmail'] as ScheduledEmail?,
              );
              return const ComposeView();
            },
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfileView(),
          ),

          // Settings tree
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) {
              // The root list shows how many identities the account has.
              _registerOnce(IdentitiesController.new);
              return const SettingsView();
            },
            routes: [
              GoRoute(
                path: 'appearance',
                builder: (_, _) {
                  _registerOnce(BackgroundsController.new);
                  return const AppearanceSettingsView();
                },
                routes: [
                  GoRoute(
                    path: 'themes',
                    onExit: (_, _) {
                      GetIt.I.unregister<CommunityThemesController>();
                      return true;
                    },
                    builder: (_, _) {
                      _registerOnce(BackgroundsController.new);
                      _ensureCommunityThemesController();
                      return const CommunityThemesView();
                    },
                    routes: [
                      GoRoute(
                        path: AppRoutes.communityThemeSegment,
                        builder: (_, state) =>
                            _communityThemeView(state.pathParameters),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'identities',
                onExit: (context, _) => confirmDiscardIdentityChanges(context),
                builder: (_, _) {
                  _registerOnce(IdentitiesController.new);
                  return const IdentitiesView();
                },
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const CreateIdentityView(),
                  ),
                ],
              ),
              GoRoute(
                path: 'folders',
                builder: (_, _) => const MailboxesSettingsView(),
              ),
              GoRoute(
                path: 'messages',
                builder: (_, _) => const MessagesSettingsView(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (_, _) => const NotificationsSettingsView(),
              ),
              GoRoute(
                path: 'hosting',
                onExit: (context, _) async {
                  if (!await confirmDiscardHostingChanges(context)) {
                    return false;
                  }
                  _disposeHostingControllers();
                  return true;
                },
                builder: (_, _) {
                  _ensureHostingControllers();
                  return const HostingSettingsView();
                },
              ),
              GoRoute(
                path: 'debug-tools',
                builder: (_, _) => const DebugToolsView(),
              ),
              GoRoute(
                path: 'about',
                builder: (_, _) {
                  _registerOnce(AboutController.new);
                  return const AboutSettingsView();
                },
              ),
            ],
          ),

          // Backward compat: legacy /email/:hex links
          GoRoute(
            path: AppRoutes.emailLegacy,
            redirect: (_, state) {
              final id = state.pathParameters['id'];
              if (id == null) return AppRoutes.inbox;
              return '/$id';
            },
          ),

          // Root-level NIP-19 dispatcher (handles nevent, note, npub, nprofile,
          // naddr)
          GoRoute(
            path: '/:${AppRoutes.nostrIdParam}',
            builder: (_, state) {
              final id = state.pathParameters[AppRoutes.nostrIdParam]!;
              return _dispatchNostrId(id);
            },
          ),
        ],
      ),
    ],
  );

  /// Mailbox route + nested `email/:id` child, plus any other [routes]. The
  /// nested child means `context.go('/<mailbox>/email/<id>')` updates the URL
  /// and pushes EmailView on top of the mailbox in the navigator stack, so
  /// `pop()` returns to the mailbox naturally.
  static GoRoute _mailboxRoute(
    String path,
    Mailbox Function(GoRouterState state) mailboxOf, {
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      // Mailboxes are lateral peers (tab-like), not a hierarchy. Skip the
      // default slide so switching between them is instant. The nested
      // email child keeps the default transition.
      pageBuilder: (_, state) => NoTransitionPage(
        key: state.pageKey,
        child: InboxView(mailbox: mailboxOf(state)),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.emailSegment,
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            _ensureEmailController(id, mailboxOf(state));
            return const EmailView();
          },
        ),
        ...routes,
      ],
    );
  }

  /// Register ComposeController once per route entry. The compose route's
  /// `onExit` disposes it on actual exit, so a fresh push always lands here
  /// with no existing controller. On builder re-runs while the route stays
  /// on-stack (theme change, refreshListenable fire) the existing controller
  /// is kept and the in-progress draft is preserved.
  static void _ensureComposeController({
    required Email? sourceEmail,
    required ComposeMode? sourceMode,
    required Recipient? initialRecipient,
    required ScheduledEmail? editingScheduled,
  }) {
    if (Get.isRegistered<ComposeController>()) return;
    Get.put(
      ComposeController(
        sourceEmail: sourceEmail,
        sourceMode: sourceMode,
        initialRecipient: initialRecipient,
        editingScheduled: editingScheduled,
      ),
    );
  }

  /// Created on first use and kept.
  static void _registerOnce<T extends ChangeNotifier>(T Function() create) {
    if (GetIt.I.isRegistered<T>()) return;
    GetIt.I.registerLazySingleton(
      create,
      dispose: (controller) => controller.dispose(),
    );
  }

  /// One set per entry to the hosting route, shared by the save button, the
  /// sections and the exit guard.
  static void _ensureHostingControllers() {
    if (GetIt.I.isRegistered<Nip65RelaysController>()) return;
    GetIt.I
      ..registerLazySingleton(
        Nip65RelaysController.new,
        dispose: (controller) => controller.dispose(),
      )
      ..registerLazySingleton(
        DmRelaysController.new,
        dispose: (controller) => controller.dispose(),
      )
      ..registerLazySingleton(
        BlossomServersController.new,
        dispose: (controller) => controller.dispose(),
      )
      ..registerLazySingleton(
        BridgesController.new,
        dispose: (controller) => controller.dispose(),
      );
  }

  static void _disposeHostingControllers() {
    GetIt.I
      ..unregister<Nip65RelaysController>()
      ..unregister<DmRelaysController>()
      ..unregister<BlossomServersController>()
      ..unregister<BridgesController>();
  }

  /// (Re)register EmailController for `eventReference` only when needed.
  /// Builders can fire on rebuilds (refreshListenable, theme changes);
  /// we must not nuke an in-flight controller for the same event/mailbox.
  static void _ensureEmailController(String eventReference, Mailbox? mailbox) {
    if (GetIt.I.isRegistered<EmailController>()) {
      final existing = GetIt.I<EmailController>();
      if (existing.eventReference == eventReference &&
          existing.mailbox == mailbox) {
        return;
      }
      GetIt.I.unregister<EmailController>();
    }
    GetIt.I.registerSingleton(
      EmailController(eventReference: eventReference, mailbox: mailbox),
      dispose: (controller) => controller.dispose(),
    );
  }

  /// One per visit, so each visit reloads. The theme opened from the page
  /// shares it.
  static void _ensureCommunityThemesController() {
    if (GetIt.I.isRegistered<CommunityThemesController>()) return;
    GetIt.I.registerLazySingleton(
      CommunityThemesController.new,
      dispose: (controller) => controller.dispose(),
    );
  }

  static void _ensureCommunityThemeController({
    required String pubkey,
    required String identifier,
    List<String> relays = const [],
  }) {
    if (GetIt.I.isRegistered<CommunityThemeController>()) {
      final existing = GetIt.I<CommunityThemeController>();
      if (existing.pubkey == pubkey && existing.identifier == identifier) {
        return;
      }
      GetIt.I.unregister<CommunityThemeController>();
    }
    GetIt.I.registerSingleton(
      CommunityThemeController(
        pubkey: pubkey,
        identifier: identifier,
        relays: relays,
      ),
      dispose: (controller) => controller.dispose(),
    );
  }

  static Widget _communityThemeView(Map<String, String> parameters) {
    final npub = parameters[AppRoutes.communityThemeAuthorParam]!;
    final pubkey = npub.startsWith('npub1') ? Nip19.decode(npub) : '';
    if (pubkey.isEmpty) return const NotFoundView();
    _ensureCommunityThemeController(
      pubkey: pubkey,
      identifier: parameters[AppRoutes.communityThemeIdentifierParam]!,
    );
    return const CommunityThemeView();
  }

  static Widget _dispatchNostrId(String id) {
    if (id.startsWith('npub1') || id.startsWith('nprofile1')) {
      return ProfileShareView(bech32: id);
    }

    if (id.startsWith('naddr1')) {
      final Naddr naddr;
      try {
        naddr = Nip19.decodeNaddr(id);
      } catch (_) {
        return const NotFoundView();
      }
      if (naddr.kind != CommunityTheme.kind) return const NotFoundView();
      _registerOnce(BackgroundsController.new);
      _ensureCommunityThemeController(
        pubkey: naddr.pubkey,
        identifier: naddr.identifier,
        relays: naddr.relays ?? const [],
      );
      return const CommunityThemeView();
    }

    if (nostrEventReferenceFromString(id) == null) {
      return const NotFoundView();
    }

    // Share-link entry point: mailbox context is unknown.
    _ensureEmailController(id, null);
    return const EmailView();
  }

  static String? _globalRedirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    final storage = Get.find<StorageService>();
    final auth = Get.find<AuthController>();

    // 1. Onboarding gate
    if (!storage.hasSeenOnboarding && loc != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    // 2. Guest paths: don't force auth on /login or /onboarding,
    // but kick logged-in users off /login. Exception: after a fresh signup
    // we want LoginView to render SyncCodeExplanationView (nsec backup).
    const publicPaths = {
      AppRoutes.login,
      AppRoutes.onboarding,
      AppRoutes.accountDeleted,
    };
    if (publicPaths.contains(loc)) {
      if (auth.isLoggedIn.value &&
          loc == AppRoutes.login &&
          !auth.showSyncCodeExplanation.value) {
        return auth.needsRelayListSetup.value
            ? AppRoutes.relaySetup
            : AppRoutes.inbox;
      }
      return null;
    }

    // 3. Protected paths require auth.
    if (!auth.isLoggedIn.value) {
      return AppRoutes.login;
    }

    // 4. The app is unusable without a NIP-65 relay list, bar account
    // management, and the setup screen must not offer to overwrite one that
    // exists.
    final needsSetup = auth.needsRelayListSetup.value;
    if (needsSetup &&
        loc != AppRoutes.relaySetup &&
        !loc.startsWith(AppRoutes.accounts)) {
      return AppRoutes.relaySetup;
    }
    if (!needsSetup && loc == AppRoutes.relaySetup) return AppRoutes.inbox;

    return null;
  }
}

/// Bridges GetX's `Rx` reactivity to go_router's `refreshListenable`.
/// When `isLoggedIn` or `needsRelayListSetup` flips, the router re-evaluates
/// its redirect so gated routes immediately bounce.
class _AuthRefreshNotifier extends ChangeNotifier {
  late final Worker _loginWorker;
  late final Worker _relayListWorker;

  _AuthRefreshNotifier() {
    final auth = Get.find<AuthController>();
    _loginWorker = ever(auth.isLoggedIn, (_) => notifyListeners());
    _relayListWorker = ever(auth.needsRelayListSetup, (_) => notifyListeners());
  }

  @override
  void dispose() {
    _loginWorker.dispose();
    _relayListWorker.dispose();
    super.dispose();
  }
}
