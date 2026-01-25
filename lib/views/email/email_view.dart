import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/inbox_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../services/nostr_mail_service.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/toast_helper.dart';

class EmailView extends StatefulWidget {
  const EmailView({super.key});

  @override
  State<EmailView> createState() => _EmailViewState();
}

class _EmailViewState extends State<EmailView> {
  Email? email;
  Metadata? _senderMetadata;
  Metadata? _bridgeMetadata;
  Metadata? _recipientMetadata;
  bool isLoading = true;
  bool _showRawContent = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  /// Check if this email was relayed through a bridge
  bool get _isViaBridge {
    if (email == null) return false;
    final from = email!.from;
    if (!from.contains('@')) return false;
    if (!from.endsWith('@nostr')) {
      return true; // Legacy email like bob@gmail.com
    }

    // Check if the pubkey in from matches senderPubkey
    final localPart = from.split('@').first;

    // Try npub format
    if (localPart.startsWith('npub1')) {
      try {
        final decodedPubkey = Nip19.decode(localPart);
        return decodedPubkey != email!.senderPubkey;
      } catch (_) {
        return true;
      }
    }

    // Try hex format (64 chars)
    if (localPart.length == 64 &&
        RegExp(r'^[a-fA-F0-9]+$').hasMatch(localPart)) {
      return localPart.toLowerCase() != email!.senderPubkey.toLowerCase();
    }

    return true;
  }

  Future<void> _loadEmail() async {
    final emailId = Get.arguments as String?;
    if (emailId == null) {
      Get.back();
      return;
    }

    final nostrMailService = Get.find<NostrMailService>();
    final loaded = await nostrMailService.client.getEmail(emailId);

    if (loaded != null) {
      _loadSenderMetadata(loaded);
      _loadRecipientMetadata(loaded.to);
    }

    setState(() {
      email = loaded;
      isLoading = false;
    });
  }

  Future<void> _loadSenderMetadata(Email loadedEmail) async {
    try {
      final ndk = Get.find<NostrMailService>().ndk;
      final from = loadedEmail.from;

      // Check if via bridge
      bool isViaBridge = false;
      if (from.contains('@') && !from.endsWith('@nostr')) {
        isViaBridge = true;
      } else if (from.endsWith('@nostr')) {
        final localPart = from.split('@').first;
        if (localPart.startsWith('npub1')) {
          try {
            isViaBridge = Nip19.decode(localPart) != loadedEmail.senderPubkey;
          } catch (_) {
            isViaBridge = true;
          }
        } else if (localPart.length == 64 &&
            RegExp(r'^[a-fA-F0-9]+$').hasMatch(localPart)) {
          isViaBridge =
              localPart.toLowerCase() != loadedEmail.senderPubkey.toLowerCase();
        } else {
          isViaBridge = true;
        }
      }

      // Load bridge/sender metadata
      final senderMeta = await ndk.metadata.loadMetadata(
        loadedEmail.senderPubkey,
      );
      if (mounted && senderMeta != null) {
        setState(() {
          if (isViaBridge) {
            _bridgeMetadata = senderMeta;
          } else {
            _senderMetadata = senderMeta;
          }
        });
      }

      // If from contains a pubkey (npub or hex), load its metadata too
      if (isViaBridge && from.endsWith('@nostr')) {
        final localPart = from.split('@').first;
        String? pubkey;

        if (localPart.startsWith('npub1')) {
          try {
            pubkey = Nip19.decode(localPart);
          } catch (_) {}
        } else if (localPart.length == 64 &&
            RegExp(r'^[a-fA-F0-9]+$').hasMatch(localPart)) {
          pubkey = localPart.toLowerCase();
        }

        if (pubkey != null) {
          final fromMeta = await ndk.metadata.loadMetadata(pubkey);
          if (mounted && fromMeta != null) {
            setState(() => _senderMetadata = fromMeta);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadRecipientMetadata(String toAddress) async {
    try {
      // Extract npub from address (format: npub1...@nostr or just npub1...)
      String npub = toAddress;
      if (toAddress.contains('@')) {
        npub = toAddress.split('@').first;
      }

      // Only load if it's an npub
      if (!npub.startsWith('npub1')) return;

      final ndk = Get.find<NostrMailService>().ndk;
      final pubkey = Nip19.decode(npub);
      final metadata = await ndk.metadata.loadMetadata(pubkey);
      if (mounted && metadata != null) {
        setState(() => _recipientMetadata = metadata);
      }
    } catch (_) {}
  }

  Future<void> _deleteEmail() async {
    if (email == null) return;

    final inboxController = Get.find<InboxController>();
    final isInTrash = inboxController.currentFolder.value == MailFolder.trash;

    if (isInTrash) {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete permanently?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await inboxController.deleteEmail(email!.id);
      if (mounted) {
        ToastHelper.success(context, 'Email deleted permanently');
      }
    } else {
      inboxController.deleteEmail(email!.id);
      if (mounted) {
        ToastHelper.success(context, 'Email moved to trash');
      }
    }
    Get.back();
  }

  void _restoreEmail() {
    if (email == null) return;

    Get.find<InboxController>().restoreFromTrash(email!.id);
    ToastHelper.success(context, 'Email restored');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (email == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Email not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          email!.subject.isEmpty ? '(No subject)' : email!.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Obx(() {
            if (!Get.find<SettingsController>().showRawEmail.value) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: Icon(_showRawContent ? Icons.article : Icons.code),
              tooltip: _showRawContent ? 'Show formatted' : 'Show raw',
              onPressed: () =>
                  setState(() => _showRawContent = !_showRawContent),
            );
          }),
          Obx(() {
            final isInTrash =
                Get.find<InboxController>().currentFolder.value ==
                MailFolder.trash;
            if (isInTrash) {
              return IconButton(
                icon: const Icon(Icons.restore_from_trash_outlined),
                tooltip: 'Restore',
                onPressed: _restoreEmail,
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteEmail,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: 800,
          padding: const EdgeInsets.all(16),
          child: _showRawContent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'Sender npub: ${Nip19.encodePubKey(email!.senderPubkey)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 24),
                    SelectableText(
                      email!.rawContent,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const Divider(height: 32),
                    _buildEmailBody(),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(
          '/compose',
          arguments: {'email': email, 'mode': 'reply'},
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.reply,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  String get _senderDisplayName {
    // Always show the from address/name
    if (_senderMetadata?.name != null && _senderMetadata!.name!.isNotEmpty) {
      return _senderMetadata!.name!;
    }
    return email!.from;
  }

  String get _recipientDisplayName {
    if (_recipientMetadata?.name != null &&
        _recipientMetadata!.name!.isNotEmpty) {
      return _recipientMetadata!.name!;
    }
    // Fallback to shortened address
    final to = email!.to;
    if (to.contains('@nostr')) {
      final npub = to.split('@').first;
      if (npub.length > 16) {
        return 'npub...${npub.substring(npub.length - 6)}';
      }
    }
    return to;
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSenderAvatar(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _senderDisplayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(email!.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecipientRow(context),
      ],
    );
  }

  Widget _buildRecipientRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            'To',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildRecipientAvatar(context),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _recipientDisplayName,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_recipientMetadata?.picture != null &&
        _recipientMetadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(_recipientMetadata!.picture!),
        backgroundColor: colorScheme.primaryContainer,
      );
    }
    final initial = _recipientMetadata?.name?.isNotEmpty == true
        ? _recipientMetadata!.name![0].toUpperCase()
        : email!.to.isNotEmpty
        ? email!.to[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 12,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSenderAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mainAvatar = _buildMainSenderAvatar(colorScheme);

    if (!_isViaBridge || _bridgeMetadata?.picture == null) {
      return mainAvatar;
    }

    // Show bridge badge on avatar
    return Stack(
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
            child: CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(_bridgeMetadata!.picture!),
              backgroundColor: colorScheme.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainSenderAvatar(ColorScheme colorScheme) {
    if (_senderMetadata?.picture != null &&
        _senderMetadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(_senderMetadata!.picture!),
        backgroundColor: colorScheme.primaryContainer,
      );
    }
    final initial = _senderMetadata?.name?.isNotEmpty == true
        ? _senderMetadata!.name![0].toUpperCase()
        : email!.from.isNotEmpty
        ? email!.from[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // TODO: Add option to trust domain and skip confirmation for trusted domains (maybe at nostr level)
  // TODO: Block images by default for privacy (tracking pixels), add "Load images" button
  // TODO: Show warning when link text differs from actual URL (phishing detection)
  Future<void> _confirmOpenLink(String url) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Open link?'),
        content: SelectableText(
          url,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Get.back(result: false);
              ToastHelper.success(context, 'Link copied');
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildEmailBody() {
    final htmlBody = email!.htmlBody;
    if (htmlBody != null && htmlBody.isNotEmpty) {
      return SelectionArea(
        child: Html(
          data: htmlBody,
          style: {
            'body': Style(
              fontSize: FontSize(16),
              lineHeight: const LineHeight(1.5),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
          onLinkTap: (url, _, _) {
            if (url != null) {
              _confirmOpenLink(url);
            }
          },
        ),
      );
    }
    return SelectableText(
      email!.body,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }
}
