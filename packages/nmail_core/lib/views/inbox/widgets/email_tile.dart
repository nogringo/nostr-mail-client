import 'package:enough_mail_plus/enough_mail.dart' hide Mailbox;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/utils/format_date.dart';
import 'package:nmail_core/views/inbox/widgets/attachments_chips_view.dart';
import 'package:nmail_core/views/inbox/widgets/unread_indicator.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/views/email/widgets/bridged_person_avatar.dart';
import 'package:nmail_core/views/shared/show_context_menu.dart';
import '../../../widgets/selectable_avatar.dart';
import '../../../widgets/tag_chips.dart';

class EmailTile extends StatelessWidget {
  final EmailSummary email;
  final VoidCallback onTap;
  final bool isSelected;
  final VoidCallback? onToggleSelect;

  /// Selects everything between the last toggled row and this one. Wired to
  /// shift-click on wide layouts.
  final VoidCallback? onExtendSelect;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onMoveTo;
  final VoidCallback? onTag;
  final ValueChanged<SenderVerdict>? onSenderVerdict;

  const EmailTile({
    super.key,
    required this.email,
    required this.onTap,
    this.isSelected = false,
    this.onToggleSelect,
    this.onExtendSelect,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onArchive,
    this.onRestore,
    this.onMoveTo,
    this.onTag,
    this.onSenderVerdict,
  });

  bool get _extendRequested =>
      onExtendSelect != null && HardwareKeyboard.instance.isShiftPressed;

  VoidCallback? get _onSelectTap {
    if (onToggleSelect == null) return null;
    return () => _extendRequested ? onExtendSelect!() : onToggleSelect!();
  }

  /// Check if I am the sender of this email
  bool get _isSentByMe {
    final myPubkey = Get.find<AuthController>().publicKey;
    return email.senderPubkey == myPubkey;
  }

  /// Get the address to display (to for sent emails, from for received).
  MailAddress get _displayAddress {
    if (_isSentByMe) {
      return email.to.firstOrNull ?? MailAddress(null, '');
    } else {
      return MailAddress(email.fromName, email.from);
    }
  }

  /// Addresses shown in the tile. Sent emails show recipients, received emails
  /// show the sender.
  List<MailAddress> get _displayAddresses {
    if (!_isSentByMe) return [_displayAddress];

    return [...email.to, ...email.cc, ...email.bcc];
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
    final to = email.to.firstOrNull;
    if (to == null) return '';
    return extractPubkeyFromAddress(to.email) ?? '';
  }

  EmailPerson get _otherSidePerson => _otherSidePubkey.isNotEmpty
      ? EmailPerson.nostr(_otherSidePubkey)
      : EmailPerson.email(_displayAddress, bridgePubkey: _bridgePubkey);

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
    final total = _displayAddresses.length;
    return total > 1 ? total - 1 : 0;
  }

  /// Unread only shows where it means something: not in sent, trash or
  /// archive.
  bool get isUnread {
    final controller = Get.find<InboxController>();
    if (!controller.currentMailbox.value.showsUnread) return false;
    return !controller.isEmailRead(email.id);
  }

  /// The tag being browsed goes without saying on its own rows.
  String? get _browsedTagId =>
      switch (Get.find<InboxController>().currentMailbox.value) {
        TagMailbox(:final id) => id,
        _ => null,
      };

  List<String> get _visibleTagIds {
    final browsed = _browsedTagId;
    return [
      for (final id in email.tags)
        if (id != browsed) id,
    ];
  }

  String _displayNameForAddress(MailAddress address) {
    final pubkey = extractPubkeyFromAddress(address.email);
    return emailPersonName(
      pubkey != null ? EmailPerson.nostr(pubkey) : EmailPerson.email(address),
    );
  }

  String get _displayName {
    if (_isSentByMe) {
      return _displayAddresses.map(_displayNameForAddress).join(', ');
    }

    // Read inside the Obx that wraps the tile, so the name updates in place
    // once metadata loads or the contact changes.
    return emailPersonName(_otherSidePerson);
  }

  Widget _buildDisplayNameText(TextStyle style) {
    return Tooltip(
      message: _displayName,
      child: Text(
        _displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }

  /// The row as one sentence, for screen readers. The visual tile spreads the
  /// same facts over an avatar, a dot, four text runs and a chip, none of
  /// which announce their role on their own.
  String _semanticsLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    final attachmentCount = email.attachmentRefs.length;

    return [
      if (isUnread) l.emailUnread,
      _displayName,
      email.subject.isEmpty ? l.emailNoSubject : email.subject,
      email.preview,
      formatDate(context, email.date),
      if (attachmentCount > 0) l.emailAttachmentCount(attachmentCount),
    ].where((part) => part.isNotEmpty).join(', ');
  }

  VoidCallback? _verdict(SenderVerdict verdict) {
    final onSenderVerdict = this.onSenderVerdict;
    if (onSenderVerdict == null) return null;
    return () => onSenderVerdict(verdict);
  }

  /// The account's own mail is never routed by a verdict.
  bool get _canBlockSender => onSenderVerdict != null && !_isSentByMe;

  /// What a swipe to the right does in [mailbox]. Trash only swipes to
  /// delete.
  ({IconData icon, Color color, String label, VoidCallback? action})?
  _swipeRight(AppLocalizations l, Mailbox mailbox) {
    if (mailbox.isTrash) return null;
    if (mailbox.isRequests || mailbox.isSpam) {
      return (
        icon: Icons.how_to_reg,
        color: Colors.green,
        label: mailbox.isRequests ? l.senderAccept : l.senderUnblock,
        action: _verdict(SenderVerdict.allow),
      );
    }
    if (mailbox.isArchive) {
      return (
        icon: Icons.inbox,
        color: Colors.blue,
        label: l.emailUnarchive,
        action: onRestore,
      );
    }
    return (
      icon: Icons.archive,
      color: Colors.green,
      label: l.emailArchive,
      action: onArchive,
    );
  }

  /// Screen-reader equivalents of the swipe gestures and of the avatar's
  /// selection tap, which [Semantics.excludeSemantics] would otherwise leave
  /// unreachable. Trash, which has no swipe to the right, offers restore.
  Map<CustomSemanticsAction, VoidCallback> _semanticsActions(
    AppLocalizations l,
    Mailbox mailbox,
  ) {
    final swipeRight = _swipeRight(l, mailbox);
    return {
      CustomSemanticsAction(label: l.emailSelectRow): ?onToggleSelect,
      if (swipeRight == null)
        CustomSemanticsAction(label: l.emailRestore): ?onRestore
      else
        CustomSemanticsAction(label: swipeRight.label): ?swipeRight.action,
      CustomSemanticsAction(
        label: mailbox.isTrash ? l.emailDeletePermanently : l.emailMoveToTrash,
      ): ?onDelete,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = ResponsiveHelper.isDesktop(context);
    final mailbox = Get.find<InboxController>().currentMailbox.value;
    final swipeRight = _swipeRight(l, mailbox);
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(
      () => Semantics(
        label: _semanticsLabel(context),
        button: true,
        selected: isSelected,
        excludeSemantics: true,
        onTap: onTap,
        onLongPress: onToggleSelect,
        customSemanticsActions: _semanticsActions(l, mailbox),
        child: Dismissible(
          key: ValueKey(email.id),
          direction: swipeRight == null
              ? DismissDirection.endToStart
              : DismissDirection.horizontal,
          background: Container(
            color: swipeRight?.color,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: swipeRight == null
                ? null
                : Icon(swipeRight.icon, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: colorScheme.onError),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              swipeRight?.action?.call();
            } else if (direction == DismissDirection.endToStart) {
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
      ),
    );
  }

  /// The context menu of a row in [mailbox], grouped as dividers show them.
  List<_MenuAction> _menuActions(AppLocalizations l, Mailbox mailbox) {
    final inbox = Get.find<InboxController>();
    final readToggle = !mailbox.showsUnread
        ? null
        : isUnread
        ? _MenuAction(
            Icons.mark_email_read,
            l.emailMarkAsRead,
            () => inbox.markAsRead(email.id),
            startsGroup: true,
          )
        : _MenuAction(
            Icons.mark_email_unread,
            l.emailMarkAsUnread,
            () => inbox.markAsUnread(email.id),
            startsGroup: true,
          );
    final block = _canBlockSender
        ? _MenuAction(Icons.block, l.senderBlock, _verdict(SenderVerdict.block))
        : null;
    final moveToTrash = _MenuAction(
      Icons.delete_outline,
      l.emailMoveToTrash,
      onDelete,
    );

    if (mailbox.isTrash) {
      return [
        _MenuAction(Icons.restore_from_trash, l.emailRestore, onRestore),
        ?block,
        _MenuAction(
          Icons.delete_forever,
          l.emailDeletePermanently,
          onDelete,
          isDestructive: true,
        ),
      ];
    }
    if (mailbox.isRequests) {
      return [
        _MenuAction(
          Icons.how_to_reg,
          l.senderAccept,
          _verdict(SenderVerdict.allow),
        ),
        _MenuAction(Icons.block, l.senderBlock, _verdict(SenderVerdict.block)),
        _MenuAction(Icons.reply, l.emailReply, onReply, startsGroup: true),
        _MenuAction(Icons.forward, l.emailForward, onForward),
        ?readToggle,
        moveToTrash,
      ];
    }
    if (mailbox.isSpam) {
      return [
        _MenuAction(
          Icons.how_to_reg,
          l.senderUnblock,
          _verdict(SenderVerdict.allow),
        ),
        moveToTrash,
      ];
    }
    return [
      _MenuAction(Icons.reply, l.emailReply, onReply),
      _MenuAction(Icons.forward, l.emailForward, onForward),
      if (mailbox.isArchive)
        _MenuAction(
          Icons.unarchive,
          l.emailUnarchive,
          onRestore,
          startsGroup: true,
        )
      else
        _MenuAction(
          Icons.archive,
          l.emailArchive,
          onArchive,
          startsGroup: true,
        ),
      _MenuAction(Icons.drive_file_move_outlined, l.mailboxMoveTo, onMoveTo),
      // TODO: open the labels as a hover submenu of checkboxes that apply
      // on click, which needs this menu to become a MenuAnchor.
      _MenuAction(Icons.label_outline, l.mailboxTags, onTag),
      ?readToggle,
      ?block,
      moveToTrash,
    ];
  }

  /// Right-click (desktop) opens a menu at the cursor, a long press (mobile)
  /// a bottom sheet.
  void _showContextMenu(BuildContext context, {Offset? position}) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final actions = _menuActions(
      l,
      Get.find<InboxController>().currentMailbox.value,
    );
    Color? colorOf(_MenuAction action) =>
        action.isDestructive ? colorScheme.error : null;

    if (position != null) {
      showContextMenu<void>(
        context,
        position: position,
        children: (menuContext) => [
          for (final action in actions) ...[
            if (action.startsGroup) const Divider(height: 1),
            MenuItemButton(
              leadingIcon: Icon(action.icon, color: colorOf(action)),
              onPressed: () {
                Navigator.of(menuContext).pop();
                action.onPressed?.call();
              },
              child: Text(
                action.label,
                style: TextStyle(color: colorOf(action)),
              ),
            ),
          ],
        ],
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            for (final action in actions) ...[
              if (action.startsGroup) const Divider(height: 1),
              ListTile(
                leading: Icon(action.icon, color: colorOf(action)),
                title: Text(
                  action.label,
                  style: TextStyle(color: colorOf(action)),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  action.onPressed?.call();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTile(BuildContext context, ColorScheme colorScheme) {
    final l = AppLocalizations.of(context);
    return Obx(() {
      final isUnread = this.isUnread;
      final subject = email.subject.isEmpty ? l.emailNoSubject : email.subject;
      final attachments = email.attachmentRefs;
      final tagIds = _visibleTagIds;

      return InkWell(
        // InkWell defaults to adaptiveClickable, an arrow off the web, while
        // ListTile always resolves to the hand: without this the cursor would
        // change with the layout.
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: () {
          if (_extendRequested) {
            onExtendSelect!();
            return;
          }
          onTap();
        },
        child: Container(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          // The separator belongs to the row: as its own widget it left a strip
          // the row's cursor and taps never reached. Painted in the foreground
          // so it costs no height.
          foregroundDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Row(
                  children: [
                    SelectableAvatar(
                      id: email.id,
                      hoveredId: Get.find<InboxController>().hoveredEmailId,
                      avatar: _buildAvatar(context, compact: true),
                      radius: 14,
                      isSelected: isSelected,
                      onToggle: _onSelectTap,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDisplayNameText(
                        const TextStyle(fontWeight: FontWeight.w500),
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
                        if (tagIds.isNotEmpty) ...[
                          TagChips(tagIds: tagIds, maxVisible: 2),
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
                        if (email.preview.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '—',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 3,
                            child: Text(
                              email.preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
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
      final subject = email.subject.isEmpty ? l.emailNoSubject : email.subject;
      final hasPreview = email.preview.isNotEmpty;
      final tagIds = _visibleTagIds;

      return Container(
        // See the compact tile: the separator is painted over the row's own
        // bottom edge so it leaves no strip outside it.
        foregroundDecoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: ListTile(
          selected: isSelected,
          selectedColor: colorScheme.onSurface,
          selectedTileColor: colorScheme.primaryContainer.withValues(
            alpha: 0.3,
          ),
          onTap: () {
            if (_extendRequested) {
              onExtendSelect!();
            } else if (isSelectionMode) {
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
          leading: SelectableAvatar(
            id: email.id,
            hoveredId: controller.hoveredEmailId,
            avatar: _buildAvatar(context),
            isSelected: isSelected,
            onToggle: _onSelectTap,
          ),
          title: Row(
            children: [
              if (isUnread) ...[UnreadIndicator(), const SizedBox(width: 8)],
              Expanded(
                child: _buildDisplayNameText(
                  TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatDate(context, email.date),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (hasPreview) ...[
                const SizedBox(height: 2),
                Text(
                  email.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
              if (tagIds.isNotEmpty) ...[
                const SizedBox(height: 6),
                TagChips(tagIds: tagIds, maxVisible: 3),
              ],
              if (attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                AttachmentsChipsView(attachments: attachments),
              ],
            ],
          ),
          isThreeLine:
              hasPreview || attachments.isNotEmpty || tagIds.isNotEmpty,
        ),
      );
    });
  }

  Widget _buildAvatar(BuildContext context, {bool compact = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final radius = compact ? 14.0 : 20.0;

    // Main avatar: nostr identity if the contact is one, else the
    // legacy MIME address. Decided per-address, not from isBridged.
    final baseAvatar = BridgedPersonAvatar(
      person: _otherSidePerson,
      radius: radius,
    );

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
}

class _MenuAction {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  /// Draws a divider above, opening a new group.
  final bool startsGroup;

  const _MenuAction(
    this.icon,
    this.label,
    this.onPressed, {
    this.isDestructive = false,
    this.startsGroup = false,
  });
}
