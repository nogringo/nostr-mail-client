import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:nostr_mail/nostr_mail.dart' hide Recipient;

import '../../controllers/auth_controller.dart';
import '../../controllers/compose_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../controllers/identities_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/scheduled_controller.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/recipient.dart';
import '../../services/storage_service.dart';
import '../../views/auth/login_view.dart';
import '../../views/compose/compose_view.dart';
import '../../views/contacts/contacts_view.dart';
import '../../views/contacts/widgets/contact_form_page.dart';
import '../../views/email/email_controller.dart';
import '../../views/email/email_view.dart';
import '../../views/identity/create_identity_view.dart';
import '../../views/inbox/inbox_view.dart';
import '../../views/nostr/profile_share_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/scheduled/scheduled_view.dart';
import '../../views/settings/debug_tools_view.dart';
import '../../views/settings/hosting_settings_view.dart';
import '../../views/settings/identities_view.dart';
import '../../views/settings/settings_view.dart';
import '../../views/shared/auth_shell.dart';
import '../../views/shared/not_found_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  /// Shared with GetX so `Get.context`, `Get.dialog`, `Get.snackbar` keep
  /// working without a `GetMaterialApp`. They all read `Get.key.currentContext`.
  ///
  /// TODO: drop GetX for navigation entirely. Replace `Get.dialog` with
  /// `showDialog`, `Get.snackbar` with toastification, and pass `BuildContext`
  /// through controllers instead of reading `Get.context!`. Once those are
  /// gone, this aliasing line can be deleted and `_rootNavigatorKey` can
  /// become a plain `GlobalKey<NavigatorState>()`.
  static final GlobalKey<NavigatorState> _rootNavigatorKey = Get.key;
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static _AuthRefreshNotifier? _authNotifier;

  /// Must be called from `main()` *after* `AuthController` is registered.
  static GoRouter init() {
    _authNotifier ??= _AuthRefreshNotifier();
    Get.lazyPut(() => InboxController());
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
    errorBuilder: (_, _) => const NotFoundView(),
    routes: [
      // Public routes (outside shell)
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginView()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingView(),
      ),

      // Authenticated shell: holds DesktopShell (sidebar) on wide screens
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, _, child) => AuthShell(child: child),
        routes: [
          // Root path inside shell: send to inbox
          GoRoute(path: '/', redirect: (_, _) => AppRoutes.inbox),

          // Folder routes (URL drives InboxController.currentFolder).
          // Each folder nests `email/:id` so opening a message via
          // `context.go('/<folder>/email/<id>')` updates the URL AND
          // preserves a real back-stack to the folder.
          _folderRoute(AppRoutes.inbox, MailFolder.inbox),
          _folderRoute(AppRoutes.sent, MailFolder.sent),
          _folderRoute(AppRoutes.archive, MailFolder.archive),
          _folderRoute(AppRoutes.trash, MailFolder.trash),

          GoRoute(
            path: AppRoutes.contacts,
            builder: (_, _) {
              if (!Get.isRegistered<ContactsController>()) {
                Get.put(ContactsController());
              }
              return const ContactsView();
            },
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
          // The ContactFormController is owned by ContactFormPage's GetBuilder,
          // so no onExit cleanup is needed here.
          GoRoute(
            path: AppRoutes.contactForm,
            builder: (_, state) {
              if (!Get.isRegistered<ContactsController>()) {
                Get.put(ContactsController());
              }
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
            builder: (_, _) {
              Get.lazyPut(() => ProfileController());
              return const ProfileView();
            },
          ),

          // Settings tree
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) => const SettingsView(),
            routes: [
              GoRoute(
                path: 'identities',
                builder: (_, _) {
                  Get.lazyPut(() => IdentitiesController());
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
                path: 'hosting',
                builder: (_, _) => const HostingSettingsView(),
              ),
              GoRoute(
                path: 'debug-tools',
                builder: (_, _) => const DebugToolsView(),
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

          // Root-level NIP-19 dispatcher (handles nevent, note, npub, nprofile)
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

  /// Folder route + nested `email/:id` child. The nested child means
  /// `context.go('/<folder>/email/<id>')` updates the URL and pushes
  /// EmailView on top of the folder in the navigator stack, so `pop()`
  /// returns to the folder naturally.
  static GoRoute _folderRoute(String path, MailFolder folder) {
    return GoRoute(
      path: path,
      // Folders are lateral peers (tab-like), not a hierarchy. Skip the
      // default slide so switching between Inbox/Sent/Archive/Trash is
      // instant. The nested email child keeps the default transition.
      pageBuilder: (_, state) => NoTransitionPage(
        key: state.pageKey,
        child: InboxView(folder: folder),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.emailSegment,
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            _ensureEmailController(id, folder);
            return const EmailView();
          },
        ),
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

  /// (Re)register EmailController for `hex` only when needed.
  /// Builders can fire on rebuilds (refreshListenable, theme changes);
  /// we must not nuke an in-flight controller for the same event/folder.
  static void _ensureEmailController(String hex, MailFolder? folder) {
    if (Get.isRegistered<EmailController>()) {
      final existing = Get.find<EmailController>();
      if (existing.eventIdHex == hex && existing.folder == folder) {
        return;
      }
      Get.delete<EmailController>();
    }
    Get.put(EmailController(eventIdHex: hex, folder: folder));
  }

  static Widget _dispatchNostrId(String id) {
    if (id.startsWith('npub1') || id.startsWith('nprofile1')) {
      return ProfileShareView(bech32: id);
    }

    final hex = _toHexEventId(id);
    if (hex == null) {
      return const NotFoundView();
    }

    // Share-link entry point: folder context is unknown.
    _ensureEmailController(hex, null);
    return const EmailView();
  }

  /// Decode bech32 (nevent/note) to hex. Pass-through if already 64-char hex.
  /// Returns null if the input is neither.
  static String? _toHexEventId(String id) {
    if (id.length == 64 && RegExp(r'^[0-9a-f]+$').hasMatch(id)) {
      return id;
    }
    if (id.startsWith('nevent1')) {
      try {
        return Nip19.decodeNevent(id).eventId;
      } catch (_) {
        return null;
      }
    }
    if (id.startsWith('note1')) {
      try {
        return Nip19.decode(id);
      } catch (_) {
        return null;
      }
    }
    return null;
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
    const publicPaths = {AppRoutes.login, AppRoutes.onboarding};
    if (publicPaths.contains(loc)) {
      if (auth.isLoggedIn.value &&
          loc == AppRoutes.login &&
          !auth.showSyncCodeExplanation.value) {
        return AppRoutes.inbox;
      }
      return null;
    }

    // 3. Protected paths require auth.
    if (!auth.isLoggedIn.value) {
      return AppRoutes.login;
    }

    return null;
  }
}

/// Bridges GetX's `Rx` reactivity to go_router's `refreshListenable`.
/// When `isLoggedIn` flips, the router re-evaluates its redirect so
/// auth-protected routes immediately bounce.
class _AuthRefreshNotifier extends ChangeNotifier {
  late final Worker _loginWorker;

  _AuthRefreshNotifier() {
    _loginWorker = ever(
      Get.find<AuthController>().isLoggedIn,
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _loginWorker.dispose();
    super.dispose();
  }
}
