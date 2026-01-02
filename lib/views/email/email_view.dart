import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../controllers/inbox_controller.dart';
import '../../services/nostr_mail_service.dart';
import '../../utils/toast_helper.dart';

class EmailView extends StatefulWidget {
  const EmailView({super.key});

  @override
  State<EmailView> createState() => _EmailViewState();
}

class _EmailViewState extends State<EmailView> {
  Email? email;
  Metadata? _senderMetadata;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmail();
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
      _loadSenderMetadata(loaded.senderPubkey);
    }

    setState(() {
      email = loaded;
      isLoading = false;
    });
  }

  Future<void> _loadSenderMetadata(String pubkey) async {
    try {
      final ndk = Get.find<NostrMailService>().ndk;
      final metadata = await ndk.metadata.loadMetadata(pubkey);
      if (mounted && metadata != null) {
        setState(() => _senderMetadata = metadata);
      }
    } catch (_) {}
  }

  Future<void> _deleteEmail() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete email?'),
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

    if (confirmed == true && email != null) {
      await Get.find<InboxController>().deleteEmail(email!.id);
      if (mounted) {
        ToastHelper.success(context, 'Email deleted');
      }
      Get.back();
    }
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
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteEmail,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 32),
            SelectableText(
              email!.body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // If I sent this email, reply to the recipient; otherwise reply to sender
          final myPubkey = Get.find<NostrMailService>().getPublicKey();
          final isSentByMe = email!.senderPubkey == myPubkey;

          Get.toNamed(
            '/compose',
            arguments: {
              'replyTo': isSentByMe ? email!.to : email!.from,
              'from': isSentByMe ? email!.from : email!.to,
              'subject': 'Re: ${email!.subject}',
            },
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.reply,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  String get _senderDisplayName {
    if (_senderMetadata?.name != null && _senderMetadata!.name!.isNotEmpty) {
      return _senderMetadata!.name!;
    }
    final pk = email!.senderPubkey;
    if (pk.length > 16) {
      return 'npub...${pk.substring(pk.length - 6)}';
    }
    return email!.from;
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
        _buildHeaderRow('To', email!.to),
      ],
    );
  }

  Widget _buildSenderAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
        : email!.senderPubkey.isNotEmpty
        ? email!.senderPubkey[0].toUpperCase()
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

  Widget _buildHeaderRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
