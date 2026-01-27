import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/inbox_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../services/nostr_mail_service.dart';
import '../../utils/nostr_utils.dart';
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
  Metadata? _bridgeMetadata; // Bridge for sender
  Metadata? _recipientMetadata;
  Metadata? _recipientBridgeMetadata; // Bridge for recipient
  bool isLoading = true;
  bool _showRawContent = false;
  late bool _showImages;

  @override
  void initState() {
    super.initState();
    _showImages = Get.find<SettingsController>().alwaysLoadImages.value;
    _loadEmail();
  }

  /// Get contact pubkey for sender (from address)
  String? get _senderContactPubkey =>
      email != null ? extractPubkeyFromAddress(email!.from) : null;

  /// Get contact pubkey for recipient (to address)
  String? get _recipientContactPubkey =>
      email != null ? extractPubkeyFromAddress(email!.to) : null;

  /// Check if sender has a bridge (for received emails)
  bool get _senderHasBridge {
    if (email == null) return false;
    final contact = _senderContactPubkey;
    if (contact == null) return true; // Legacy email
    return contact != email!.senderPubkey;
  }

  /// Check if recipient has a bridge (for sent emails)
  bool get _recipientHasBridge {
    if (email == null) return false;
    final contact = _recipientContactPubkey;
    if (contact == null) return true; // Legacy email
    return contact != email!.recipientPubkey;
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
      _loadRecipientMetadata(loaded);
    }

    setState(() {
      email = loaded;
      isLoading = false;
    });
  }

  Future<void> _loadSenderMetadata(Email loadedEmail) async {
    try {
      final ndk = Get.find<Ndk>();
      final contactPubkey = extractPubkeyFromAddress(loadedEmail.from);
      final hasBridge =
          contactPubkey == null || contactPubkey != loadedEmail.senderPubkey;

      // Always load senderPubkey metadata
      final senderMeta = await ndk.metadata.loadMetadata(
        loadedEmail.senderPubkey,
      );
      if (mounted && senderMeta != null) {
        setState(() {
          if (hasBridge) {
            _bridgeMetadata = senderMeta;
          } else {
            _senderMetadata = senderMeta;
          }
        });
      }

      // If there's a bridge and we can extract contact pubkey, load it too
      if (hasBridge && contactPubkey != null) {
        final contactMeta = await ndk.metadata.loadMetadata(contactPubkey);
        if (mounted && contactMeta != null) {
          setState(() => _senderMetadata = contactMeta);
        }
      }
    } catch (_) {}
  }

  Future<void> _loadRecipientMetadata(Email loadedEmail) async {
    try {
      final ndk = Get.find<Ndk>();
      final contactPubkey = extractPubkeyFromAddress(loadedEmail.to);
      final hasBridge =
          contactPubkey == null || contactPubkey != loadedEmail.recipientPubkey;

      // Always load recipientPubkey metadata
      final recipientMeta = await ndk.metadata.loadMetadata(
        loadedEmail.recipientPubkey,
      );
      if (mounted && recipientMeta != null) {
        setState(() {
          if (hasBridge) {
            _recipientBridgeMetadata = recipientMeta;
          } else {
            _recipientMetadata = recipientMeta;
          }
        });
      }

      // If there's a bridge and we can extract contact pubkey, load it too
      if (hasBridge && contactPubkey != null) {
        final contactMeta = await ndk.metadata.loadMetadata(contactPubkey);
        if (mounted && contactMeta != null) {
          setState(() => _recipientMetadata = contactMeta);
        }
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
        Text(
          email!.subject.isEmpty ? '(No subject)' : email!.subject,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 16),
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
    final mainAvatar = _buildMainRecipientAvatar(colorScheme);

    if (!_recipientHasBridge) {
      return mainAvatar;
    }

    // Show bridge badge on avatar
    return Stack(
      clipBehavior: Clip.none,
      children: [
        mainAvatar,
        Positioned(
          right: -3,
          bottom: -3,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 1.5),
            ),
            child: _buildRecipientBridgeBadge(colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildMainRecipientAvatar(ColorScheme colorScheme) {
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

  Widget _buildRecipientBridgeBadge(ColorScheme colorScheme) {
    if (_recipientBridgeMetadata?.picture != null &&
        _recipientBridgeMetadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 7,
        backgroundImage: NetworkImage(_recipientBridgeMetadata!.picture!),
        backgroundColor: colorScheme.secondaryContainer,
      );
    }
    // Fallback: show last character of npub
    final npub = Nip19.encodePubKey(email!.recipientPubkey);
    final lastChar = npub[npub.length - 1].toUpperCase();
    return CircleAvatar(
      radius: 7,
      backgroundColor: colorScheme.secondaryContainer,
      child: Text(
        lastChar,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 6,
        ),
      ),
    );
  }

  Widget _buildSenderAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mainAvatar = _buildMainSenderAvatar(colorScheme);

    if (!_senderHasBridge) {
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
            child: _buildSenderBridgeBadge(colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildSenderBridgeBadge(ColorScheme colorScheme) {
    if (_bridgeMetadata?.picture != null &&
        _bridgeMetadata!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(_bridgeMetadata!.picture!),
        backgroundColor: colorScheme.secondaryContainer,
      );
    }
    // Fallback: show last character of npub
    final npub = Nip19.encodePubKey(email!.senderPubkey);
    final lastChar = npub[npub.length - 1].toUpperCase();
    return CircleAvatar(
      radius: 12,
      backgroundColor: colorScheme.secondaryContainer,
      child: Text(
        lastChar,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
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

  bool _htmlHasImages(String html) {
    return RegExp(r'<img[\s>/]', caseSensitive: false).hasMatch(html);
  }

  Widget _buildEmailBody() {
    final htmlBody = email!.htmlBody;
    if (htmlBody != null && htmlBody.isNotEmpty) {
      final hasImages = _htmlHasImages(htmlBody);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImages && !_showImages)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Images are hidden for privacy',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showImages = true),
                    child: const Text('Load images'),
                  ),
                ],
              ),
            ),
          SelectionArea(
            child: HtmlWidget(
              htmlBody,
              key: ValueKey(_showImages),
              customWidgetBuilder: _showImages
                  ? null
                  : (element) {
                      if (element.localName == 'img') {
                        return const SizedBox.shrink();
                      }
                      return null;
                    },
              onTapUrl: (url) {
                _confirmOpenLink(url);
                return true;
              },
            ),
          ),
        ],
      );
    }
    return SelectableText(
      email!.body,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }
}
