import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/nostr_mail_service.dart';
import '../../../utils/relay_utils.dart';

class DmRelaysSection extends StatefulWidget {
  const DmRelaysSection({super.key});

  @override
  State<DmRelaysSection> createState() => _DmRelaysSectionState();
}

class _DmRelaysSectionState extends State<DmRelaysSection> {
  List<String>? _originalDmRelays;
  List<String>? _dmRelays;
  final Set<String> _markedForDeletion = {};
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _hasChanges {
    if (_originalDmRelays == null || _dmRelays == null) return false;
    if (_markedForDeletion.isNotEmpty) return true;
    if (_originalDmRelays!.length != _dmRelays!.length) return true;
    for (int i = 0; i < _originalDmRelays!.length; i++) {
      if (!_dmRelays!.contains(_originalDmRelays![i])) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final nostrMailService = Get.find<NostrMailService>();
    final dmRelays = await nostrMailService.getDmRelays();
    if (mounted) {
      setState(() {
        _originalDmRelays = List.from(dmRelays);
        _dmRelays = List.from(dmRelays);
        _isLoading = false;
      });
    }
  }

  Future<void> _addRelay() async {
    final controller = TextEditingController();
    String? errorText;
    String? preview;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add DM Relay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'wss://relay.example.com',
                  labelText: 'Relay URL',
                  errorText: errorText,
                ),
                autofocus: true,
                onChanged: (value) {
                  setDialogState(() {
                    errorText = null;
                    final normalized = _normalizeRelayUrl(value.trim());
                    preview = (normalized != value.trim()) ? normalized : null;
                  });
                },
              ),
              if (preview != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Will be added as: $preview',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final url = _normalizeRelayUrl(controller.text.trim());
                if (!_isValidRelayUrl(url)) {
                  setDialogState(() => errorText = 'Invalid relay URL');
                  return;
                }
                Navigator.pop(context, url);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null && _dmRelays != null && !_dmRelays!.contains(result)) {
      setState(() => _dmRelays!.add(result));
    }
  }

  String _normalizeRelayUrl(String url) {
    if (url.isEmpty) return url;
    if (!url.startsWith('wss://') && !url.startsWith('ws://')) {
      return 'wss://$url';
    }
    return url;
  }

  bool _isValidRelayUrl(String url) {
    if (url.isEmpty || url.contains(' ')) return false;
    if (!url.startsWith('wss://') && !url.startsWith('ws://')) {
      return false;
    }
    final uri = Uri.tryParse(url);
    return uri != null && uri.host.isNotEmpty;
  }

  void _toggleRelayDeletion(String relayUrl) {
    setState(() {
      if (_markedForDeletion.contains(relayUrl)) {
        _markedForDeletion.remove(relayUrl);
      } else {
        _markedForDeletion.add(relayUrl);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final nostrMailService = Get.find<NostrMailService>();
      final relaysToSave = _dmRelays!
          .where((r) => !_markedForDeletion.contains(r))
          .toList();
      await nostrMailService.saveDmRelays(relaysToSave);
      setState(() {
        _dmRelays = relaysToSave;
        _originalDmRelays = List.from(relaysToSave);
        _markedForDeletion.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
            'DM Relays',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _addRelay,
            tooltip: 'Add relay',
          ),
        ),
        if (_dmRelays == null || _dmRelays!.isEmpty)
          const ListTile(
            leading: Icon(Icons.warning_outlined, size: 20),
            title: Text('No DM relays configured'),
            subtitle: Text('Tap + to add a relay'),
          )
        else
          ..._dmRelays!.map((relay) {
            final isMarked = _markedForDeletion.contains(relay);
            return ListTile(
              leading: Icon(
                Icons.dns_outlined,
                size: 20,
                color: isMarked ? Theme.of(context).disabledColor : null,
              ),
              title: Text(
                formatRelayUrl(relay),
                style: TextStyle(
                  fontSize: 14,
                  decoration: isMarked ? TextDecoration.lineThrough : null,
                  color: isMarked ? Theme.of(context).disabledColor : null,
                ),
              ),
              trailing: IconButton(
                icon: Icon(isMarked ? Icons.undo : Icons.close, size: 18),
                onPressed: () => _toggleRelayDeletion(relay),
                tooltip: isMarked ? 'Undo' : 'Remove relay',
              ),
            );
          }),
        if (_hasChanges)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ),
      ],
    );
  }
}
