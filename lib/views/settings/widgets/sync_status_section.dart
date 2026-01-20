import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/nostr_mail_service.dart';
import '../../../utils/relay_utils.dart';

class SyncStatusSection extends StatefulWidget {
  const SyncStatusSection({super.key});

  @override
  State<SyncStatusSection> createState() => _SyncStatusSectionState();
}

class _SyncStatusSectionState extends State<SyncStatusSection> {
  List<EmailSyncStatus>? _syncStatus;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final nostrMailService = Get.find<NostrMailService>();
    final status = await nostrMailService.getEmailSyncStatus();
    if (mounted) {
      setState(() {
        _syncStatus = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _sync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      final nostrMailService = Get.find<NostrMailService>();
      await nostrMailService.client.sync();
      await _loadData();
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '-';
    if (timestamp == 0) return 'Beginning of time';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Loading...'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          title: Text(
            'Sync Status',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
        if (_syncStatus == null || _syncStatus!.isEmpty)
          const ListTile(
            leading: Icon(Icons.sync_disabled, size: 20),
            title: Text('No sync data available'),
            subtitle: Text('Sync your emails to see relay status'),
          )
        else
          ..._syncStatus!.map(
            (status) => ListTile(
              leading: const Icon(Icons.cloud_outlined, size: 20),
              title: Text(
                formatRelayUrl(status.relayUrl),
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                '${_formatTimestamp(status.oldestTimestamp)} → ${_formatTimestamp(status.newestTimestamp)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isSyncing ? null : _sync,
              child: _isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sync'),
            ),
          ),
        ),
      ],
    );
  }
}
