import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/inbox_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/compose_mode.dart';
import '../../utils/toast_helper.dart';
import '../../utils/metadata_extensions.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/nostr_avatar.dart';
import 'widgets/app_drawer.dart';
import 'widgets/email_tile.dart';
import 'widgets/old_emails_banner.dart';
import 'widgets/search_field.dart';
import 'widgets/selection_actions_bar.dart';

class InboxView extends GetView<InboxController> {
  /// Folder this route represents (driven by the URL: /inbox, /sent, ...).
  /// Synced to `InboxController.currentFolder` on build so the rest of the
  /// view (toolbar title, email list source, action behaviors) stays
  /// driven by the controller.
  final MailFolder folder;

  const InboxView({super.key, required this.folder});

  String _folderTitle(AppLocalizations l, MailFolder folder) {
    return switch (folder) {
      MailFolder.inbox => l.folderInbox,
      MailFolder.sent => l.folderSent,
      MailFolder.trash => l.folderTrash,
      MailFolder.archive => l.folderArchive,
    };
  }

  Widget _buildAccountHeader(BuildContext context) {
    final authController = Get.find<AuthController>();
    final metadata = authController.userMetadata.value;
    final npub = authController.npub ?? '';
    final shortNpub = npub.length >= 20
        ? '${npub.substring(0, 10)}...${npub.substring(npub.length - 6)}'
        : npub;
    final colorScheme = Theme.of(context).colorScheme;

    final displayName =
        metadata?.getBestName() ?? getAnonName(authController.publicKey!);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          NostrAvatar(
            pubkey: authController.publicKey!,
            metadata: metadata,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  shortNpub,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Obx(() {
            if (controller.hasSelection) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l.inboxClearSelection,
                    onPressed: controller.clearSelection,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.inboxSelectedCount(controller.selectedIds.length),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            }

            if (controller.isSearchMode.value) {
              // No leading icon for search mode anymore, it's on the right
              return const SizedBox.shrink();
            }

            return Text(
              _folderTitle(l, controller.currentFolder.value),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            );
          }),
          Obx(() {
            if (controller.isSearchMode.value) {
              return Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SearchField(),
                ),
              );
            }
            return const Spacer();
          }),
          Obx(() {
            if (controller.hasSelection) {
              return const SelectionActionsBar();
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!controller.isSearchMode.value)
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: l.inboxSearch,
                    onPressed: controller.enterSearchMode,
                  ),
                IconButton(
                  icon: controller.isSyncing.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  tooltip: l.inboxSync,
                  onPressed: controller.isSyncing.value
                      ? null
                      : controller.sync,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmailList(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (controller.emails.isEmpty) {
        final (icon, message) = switch (controller.currentFolder.value) {
          MailFolder.inbox => (Icons.inbox, l.inboxEmptyInbox),
          MailFolder.sent => (Icons.send, l.inboxEmptySent),
          MailFolder.trash => (Icons.delete_outline, l.inboxEmptyTrash),
          MailFolder.archive => (Icons.archive_outlined, l.inboxEmptyArchive),
        };
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: controller.sync,
                child: Text(l.inboxSyncFromRelays),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          OldEmailsBanner(onDelete: () => _confirmDeleteOldEmails(context)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.sync,
              child: GetBuilder<InboxController>(
                builder: (controller) => ListView.builder(
                  itemCount: controller.emails.length,
                  itemBuilder: (context, index) {
                    final email = controller.emails[index];
                    return Obx(
                      () => EmailTile(
                        key: ValueKey(email.id),
                        email: email,
                        onTap: () =>
                            context.go(AppRoutes.emailPath(folder, email.id)),
                        isSelected: controller.isSelected(email.id),
                        onToggleSelect: () =>
                            controller.toggleSelection(email.id),
                        onReply: () => _replyTo(context, email),
                        onForward: () => _forward(context, email),
                        onDelete: () => _deleteEmail(context, email),
                        onArchive: () => _archiveEmail(context, email),
                        onRestore: () => _restoreEmail(context, email),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = ResponsiveHelper.isNotMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Sync URL-driven folder to the shared controller after build settles.
    // Skipping when already aligned avoids redundant notifications.
    if (controller.currentFolder.value != folder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setFolder(folder);
      });
    }

    if (isWide) {
      // Desktop: 3-column layout (DesktopShell is provided by AuthShell)
      return Column(
        children: [
          _buildToolbar(context),
          Expanded(child: _buildEmailList(context)),
        ],
      );
    }

    // Mobile: Traditional scaffold with AppBar and drawer
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final isSearching =
              controller.isSearchMode.value && !controller.hasSelection;
          return AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: colorScheme.surface,
            automaticallyImplyLeading: false,
            titleSpacing: isSearching ? 8 : null,
            title: Builder(
              builder: (context) {
                if (controller.hasSelection) {
                  return Text('${controller.selectedIds.length}');
                }
                if (controller.isSearchMode.value) {
                  return SearchField();
                }
                return Text(_folderTitle(l, controller.currentFolder.value));
              },
            ),
            leading: () {
              if (isSearching) {
                return null;
              }
              if (controller.hasSelection) {
                return IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l.inboxClearSelection,
                  onPressed: controller.clearSelection,
                );
              }
              return Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: l.inboxMenu,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              );
            }(),
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [
              if (controller.isSearchMode.value)
                const SizedBox.shrink()
              else if (controller.hasSelection)
                const SelectionActionsBar()
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: l.inboxSearch,
                      onPressed: () => controller.enterSearchMode(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: l.inboxSettings,
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                    const SizedBox(width: 8),
                    Builder(
                      builder: (context) => MenuAnchor(
                        // TODO: Refactor account popup into a reusable widget to avoid duplication with left_rail.dart
                        alignmentOffset: const Offset(-204, 8),
                        style: MenuStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                width: 2,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                        menuChildren: [
                          Obx(() => _buildAccountHeader(context)),
                          const Divider(height: 1),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.person_outline),
                            onPressed: () => context.go(AppRoutes.profile),
                            child: Text(l.inboxProfile),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.copy),
                            onPressed: () {
                              final npub = Get.find<AuthController>().npub;
                              if (npub != null) {
                                Clipboard.setData(ClipboardData(text: npub));
                              }
                            },
                            child: Text(l.inboxCopyNpub),
                          ),
                          MenuItemButton(
                            leadingIcon: Icon(
                              Icons.logout,
                              color: colorScheme.error,
                            ),
                            onPressed: () {
                              Get.find<AuthController>().logout();
                              context.go(AppRoutes.login);
                            },
                            child: Text(
                              l.inboxLogout,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
                        builder: (context, menuController, child) {
                          return Semantics(
                            label: l.inboxAccount,
                            button: true,
                            child: GestureDetector(
                              onTap: () {
                                if (menuController.isOpen) {
                                  menuController.close();
                                } else {
                                  menuController.open();
                                }
                              },
                              child: Obx(() {
                                final authController =
                                    Get.find<AuthController>();
                                return NostrAvatar(
                                  pubkey: authController.publicKey!,
                                  metadata: authController.userMetadata.value,
                                  radius: 18,
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        }),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.compose),
        tooltip: l.inboxCompose,
        child: const Icon(Icons.edit),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 4,
            child: Obx(
              () => controller.isSyncing.value
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(child: _buildEmailList(context)),
        ],
      ),
    );
  }

  void _replyTo(BuildContext context, Email email) {
    context.push(
      AppRoutes.compose,
      extra: {'email': email, 'mode': ComposeMode.reply},
    );
  }

  void _forward(BuildContext context, Email email) {
    context.push(
      AppRoutes.compose,
      extra: {'email': email, 'mode': ComposeMode.forward},
    );
  }

  void _deleteEmail(BuildContext context, Email email) {
    controller.deleteEmail(email.id);
  }

  void _archiveEmail(BuildContext context, Email email) {
    controller.moveToArchive(email.id);
  }

  void _restoreEmail(BuildContext context, Email email) {
    if (controller.currentFolder.value == MailFolder.archive) {
      controller.restoreFromArchive(email.id);
    } else {
      controller.restoreFromTrash(email.id);
    }
  }

  void _confirmDeleteOldEmails(BuildContext context) {
    final l = AppLocalizations.of(context);
    final oldCount = controller.oldEmailsCount.value;

    Get.dialog(
      AlertDialog(
        title: Text(l.inboxDeleteOldEmailsTitle),
        content: Text(l.inboxDeleteOldEmailsMessage(oldCount)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () async {
              Get.back(); // Close confirmation dialog

              try {
                await controller.deleteOldEmails();
              } catch (e) {
                if (context.mounted) {
                  ToastHelper.error(
                    context,
                    l.inboxDeleteFailed,
                    description: l.inboxDeleteFailedDescription(e.toString()),
                  );
                }
              }
            },
            child: Text(
              l.actionDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
