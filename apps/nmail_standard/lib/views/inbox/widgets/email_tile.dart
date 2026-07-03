import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_standard/utils/format_date.dart';
import 'package:nmail_standard/views/inbox/widgets/attachments_chips_view.dart';
import 'package:nmail_standard/views/inbox/widgets/unread_indicator.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/inbox_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import '../../../utils/nostr_utils.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/email_avatar.dart';
import '../../../widgets/nostr_avatar.dart';

class EmailTile extends StatelessWidget {
  final Email email;
  final VoidCallback onTap;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;

  const EmailTile({
    super.key,
    required this.email,
    required this.onTap,
    this.isSelected = false,
    this.onToggleSelect,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onArchive,
    this.onRestore,
  });

  /// Check if I am the sender of this email
  bool get _isSentByMe {
    final myPubkey = Get.find<AuthController>().publicKey;
    return email.senderPubkey == myPubkey;
  }

  /// Get the address to display (to for sent emails, from for received).
  MailAddress get _displayAddress {
    if (_isSentByMe) {
      return email.mime.to?.firstOrNull ?? MailAddress(null, '');
    } else {
      return email.sender ?? MailAddress(null, '');
    }
  }

  /// Pubkey of the contact (other side of the conversation) when they
  /// are a nostr identity. Empty for legacy (SMTP) contacts.
  ///
  /// - Received: gift-wrap sender, only when not bridged. A bridged
  ///   received email has a legacy contact in the MIME From header.
  /// - Sent: derived from the To.first address itself (`<npub>@nostr`).
  ///   `isBridged` is ignored: delivery is per-recipient (one rumor per
  ///   target pubkey), so the displayed recipient's address is what
  ///   determines whether the avatar is nostr or legacy, not the
  ///   global flag.
  String get _otherSidePubkey {
    if (!_isSentByMe) {
      return email.isBridged ? '' : email.senderPubkey;
    }
    final to = email.mime.to?.firstOrNull;
    if (to == null) return '';
    return extractPubkeyFromAddress(to.email) ?? '';
  }

  /// Pubkey of the bridge that relayed this email, when known. Only
  /// available for received bridged emails (gift-wrap sender = bridge).
  /// Outgoing bridged emails don't persist the bridge locally.
  String get _bridgePubkey {
    if (_isSentByMe) return '';
    return email.isBridged ? email.senderPubkey : '';
  }

  /// Number of additional recipients beyond the one whose avatar is shown.
  /// Only meaningful for sent emails (in inbox, you are the sole recipient
  /// of your gift-wrap copy, even if cc/bcc were used).
  int get _extraRecipientCount {
    if (!_isSentByMe) return 0;
    final mime = email.mime;
    final total =
        (mime.to?.length ?? 0) +
        (mime.cc?.length ?? 0) +
        (mime.bcc?.length ?? 0);
    return total > 1 ? total - 1 : 0;
  }

  /// Check if this email is unread (only applies to inbox folder)
  bool get isUnread {
    final controller = Get.find<InboxController>();
    // Only show unread indicators for inbox folder
    if (controller.currentFolder.value != MailFolder.inbox) {
      return false;
    }
    return !controller.isEmailRead(email.id);
  }

  String get _displayName {
    // Other side is a nostr identity: prefer the nostr profile name,
    // resolved reactively from the in-RAM cache. Read inside the Obx that
    // wraps the tile, so the name updates in place once metadata loads.
    if (_otherSidePubkey.isNotEmpty) {
      final metadata = Get.find<MetadataService>().of(_otherSidePubkey).value;
      if (metadata != null) return metadata.getBestName();
    }
    // Legacy contact (or nostr metadata not yet loaded): rely on the
    // email headers, which carry the actual contact.
    if (_displayAddress.hasPersonalName) {
      return _displayAddress.personalName!;
    }
    return _displayAddress.email;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveHelper.isDesktop(context);
    final currentFolder = Get.find<InboxController>().currentFolder.value;
    final isInTrash = currentFolder == MailFolder.trash;
    final isInArchive = currentFolder == MailFolder.archive;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Dismissible(
          key: ValueKey(email.id),
          direction: isInTrash
              ? DismissDirection.endToStart
              : DismissDirection.horizontal,
          background: Container(
            color: isInArchive ? Colors.blue : Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              isInArchive ? Icons.inbox : Icons.archive,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            color: colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: colorScheme.onError),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // Swipe right - archive (or restore from archive)
              if (isInArchive) {
                onRestore?.call();
              } else {
                onArchive?.call();
              }
            } else if (direction == DismissDirection.endToStart) {
              // Swipe left - delete
              onDelete?.call();
            }
          },
          child: GestureDetector(
            onSecondaryTapUp: (details) =>
                _showContextMenu(context, position: details.globalPosition),
            onLongPress: () => _showContextMenu(context),
            child: isWide
                ? _buildCompactTile(context, colorScheme)
                : _buildDefaultTile(context),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _showContextMenu(BuildContext context, {Offset? position}) {
    final l = AppLocalizations.of(context);
    final currentFolder = Get.find<InboxController>().currentFolder.value;
    final isInTrash = currentFolder == MailFolder.trash;
    final isInArchive = currentFolder == MailFolder.archive;
    final colorScheme = Theme.of(context).colorScheme;

    // Right-click (desktop) → popup menu at cursor position
    // Long-press (mobile) → bottom sheet
    if (position != null) {
      // Desktop: popup menu
      final menuChildren = <Widget>[
        if (!isInTrash) ...[
          MenuItemButton(
            leadingIcon: const Icon(Icons.reply),
            onPressed: () {
              Navigator.of(context).pop();
              onReply?.call();
            },
            child: Text(l.emailReply),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.forward),
            onPressed: () {
              Navigator.of(context).pop();
              onForward?.call();
            },
            child: Text(l.emailForward),
          ),
          const Divider(height: 1),
          if (!isInArchive)
            MenuItemButton(
              leadingIcon: const Icon(Icons.archive),
              onPressed: () {
                Navigator.of(context).pop();
                onArchive?.call();
              },
              child: Text(l.emailArchive),
            )
          else
            MenuItemButton(
              leadingIcon: const Icon(Icons.unarchive),
              onPressed: () {
                Navigator.of(context).pop();
                onRestore?.call();
              },
              child: Text(l.emailUnarchive),
            ),
          if (currentFolder == MailFolder.inbox) ...[
            const Divider(height: 1),
            if (isUnread)
              MenuItemButton(
                leadingIcon: const Icon(Icons.mark_email_read),
                onPressed: () {
                  Navigator.of(context).pop();
                  final inboxController = Get.find<InboxController>();
                  inboxController.markAsRead(email.id);
                },
                child: Text(l.emailMarkAsRead),
              )
            else
              MenuItemButton(
                leadingIcon: const Icon(Icons.mark_email_unread),
                onPressed: () {
                  Navigator.of(context).pop();
                  final inboxController = Get.find<InboxController>();
                  inboxController.markAsUnread(email.id);
                },
                child: Text(l.emailMarkAsUnread),
              ),
          ],
          MenuItemButton(
            leadingIcon: const Icon(Icons.delete_outline),
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            child: Text(l.emailMoveToTrash),
          ),
        ] else ...[
          MenuItemButton(
            leadingIcon: const Icon(Icons.restore_from_trash),
            onPressed: () {
              Navigator.of(context).pop();
              onRestore?.call();
            },
            child: Text(l.emailRestore),
          ),
          MenuItemButton(
            leadingIcon: Icon(Icons.delete_forever, color: colorScheme.error),
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            child: Text(
              l.emailDeletePermanently,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ];

      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(onTap: () => Navigator.of(context).pop()),
            ),
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                surfaceTintColor: colorScheme.surfaceTint,
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: menuChildren,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile: bottom sheet
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              if (!isInTrash) ...[
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: Text(l.emailReply),
                  onTap: () {
                    Navigator.pop(context);
                    onReply?.call();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forward),
                  title: Text(l.emailForward),
                  onTap: () {
                    Navigator.pop(context);
                    onForward?.call();
                  },
                ),
                const Divider(height: 1),
                if (!isInArchive)
                  ListTile(
                    leading: const Icon(Icons.archive),
                    title: Text(l.emailArchive),
                    onTap: () {
                      Navigator.pop(context);
                      onArchive?.call();
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.unarchive),
                    title: Text(l.emailUnarchive),
                    onTap: () {
                      Navigator.pop(context);
                      onRestore?.call();
                    },
                  ),
                if (currentFolder == MailFolder.inbox) ...[
                  const Divider(height: 1),
                  if (isUnread)
                    ListTile(
                      leading: const Icon(Icons.mark_email_read),
                      title: Text(l.emailMarkAsRead),
                      onTap: () {
                        Navigator.pop(context);
                        final inboxController = Get.find<InboxController>();
                        inboxController.markAsRead(email.id);
                      },
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.mark_email_unread),
                      title: Text(l.emailMarkAsUnread),
                      onTap: () {
                        Navigator.pop(context);
                        final inboxController = Get.find<InboxController>();
                        inboxController.markAsUnread(email.id);
                      },
                    ),
                ],
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l.emailMoveToTrash),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete?.call();
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.restore_from_trash),
                  title: Text(l.emailRestore),
                  onTap: () {
                    Navigator.pop(context);
                    onRestore?.call();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: colorScheme.error),
                  title: Text(
                    l.emailDeletePermanently,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete?.call();
                  },
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCompactTile(BuildContext context, ColorScheme colorScheme) {
    final l = AppLocalizations.of(context);
    return Obx(() {
      final isUnread = this.isUnread;
      final subject = (email.subject?.isEmpty ?? true)
          ? l.emailNoSubject
          : email.subject!;
      final attachments = email.attachmentRefs;

      return InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onToggleSelect != null
                      ? (_) => onToggleSelect!()
                      : null,
                ),
              ),
              SizedBox(
                width: 160,
                child: Row(
                  children: [
                    _buildAvatar(context, compact: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isUnread) ...[
                          UnreadIndicator(),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          flex: 2,
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '—',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 3,
                          child: Text(
                            email.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (attachments.isNotEmpty) ...[
                      AttachmentsChipsView(attachments: attachments),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formatDate(context, email.date),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDefaultTile(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isUnread = this.isUnread;
      final attachments = email.attachmentRefs;
      final controller = Get.find<InboxController>();
      final isSelectionMode = controller.hasSelection;

      return Column(
        children: [
          ListTile(
            onTap: () {
              if (isSelectionMode) {
                // In selection mode, toggle selection instead of opening email
                onToggleSelect?.call();
              } else {
                // Normal mode, open email
                onTap();
              }
            },
            onLongPress: () {
              // Long press to enter selection mode
              onToggleSelect?.call();
            },
            leading: _buildAvatarWithSelection(context),
            title: Row(
              children: [
                if (isUnread) ...[UnreadIndicator(), const SizedBox(width: 8)],
                Expanded(
                  child: Text(
                    (email.subject?.isEmpty ?? true)
                        ? l.emailNoSubject
                        : email.subject!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: Text(
              formatDate(context, email.date),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            isThreeLine: true,
          ),
          if (attachments.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AttachmentsChipsView(attachments: attachments),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildAvatar(BuildContext context, {bool compact = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final radius = compact ? 14.0 : 20.0;

    // Main avatar: nostr identity if the contact is one, else the
    // legacy MIME address. Decided per-address, not from isBridged.
    final mainAvatar = _otherSidePubkey.isEmpty
        ? EmailAvatar(mailAddress: _displayAddress, radius: radius)
        : NostrAvatar(pubkey: _otherSidePubkey, radius: radius);

    // Bridge badge: provenance marker, only when the bridge pubkey is
    // known (received bridged emails).
    Widget baseAvatar;
    if (_bridgePubkey.isEmpty) {
      baseAvatar = mainAvatar;
    } else {
      final badgeRadius = compact ? 7.0 : 10.0;
      baseAvatar = Stack(
        clipBehavior: Clip.none,
        children: [
          mainAvatar,
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: NostrAvatar(pubkey: _bridgePubkey, radius: badgeRadius),
            ),
          ),
        ],
      );
    }

    final extra = _extraRecipientCount;
    if (extra == 0) return baseAvatar;

    return Semantics(
      label: l.emailExtraRecipients(extra),
      container: true,
      child: Badge(
        label: ExcludeSemantics(child: Text('+$extra')),
        backgroundColor: colorScheme.primaryContainer,
        textColor: colorScheme.onPrimaryContainer,
        child: baseAvatar,
      ),
    );
  }

  Widget _buildAvatarWithSelection(BuildContext context) {
    final mainAvatar = _buildAvatar(context);

    if (!isSelected) {
      return mainAvatar;
    }

    return CircleAvatar(child: Icon(Icons.check));
  }
}
