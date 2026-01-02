import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    setState(() {
      email = loaded;
      isLoading = false;
    });
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
            _buildHeader(),
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.reply, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow('From', email!.from),
        const SizedBox(height: 8),
        _buildHeaderRow('To', email!.to),
        const SizedBox(height: 8),
        _buildHeaderRow('Date', _formatDateTime(email!.date)),
      ],
    );
  }

  Widget _buildHeaderRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
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
