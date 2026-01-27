import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/domain_layer/entities/read_write_marker.dart';

import '../../../services/nostr_mail_service.dart';
import '../../../utils/relay_utils.dart';

class Nip65RelaysSection extends StatefulWidget {
  const Nip65RelaysSection({super.key});

  @override
  State<Nip65RelaysSection> createState() => _Nip65RelaysSectionState();
}

class _Nip65RelaysSectionState extends State<Nip65RelaysSection> {
  Map<String, ReadWriteMarker>? _originalRelays;
  Map<String, ReadWriteMarker>? _relays;
  final Set<String> _markedForDeletion = {};
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _hasChanges {
    if (_originalRelays == null || _relays == null) return false;
    if (_markedForDeletion.isNotEmpty) return true;
    if (_originalRelays!.length != _relays!.length) return true;
    for (final entry in _originalRelays!.entries) {
      if (!_relays!.containsKey(entry.key)) return true;
      if (_relays![entry.key] != entry.value) return true;
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
    final relays = await nostrMailService.getNip65Relays();
    if (mounted) {
      setState(() {
        _originalRelays = Map.from(relays);
        _relays = Map.from(relays);
        _isLoading = false;
      });
    }
  }

  Future<void> _addRelay() async {
    final controller = TextEditingController();
    String? errorText;
    String? preview;
    ReadWriteMarker marker = ReadWriteMarker.readWrite;

    final result = await showDialog<MapEntry<String, ReadWriteMarker>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Relay'),
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
                onSubmitted: (value) {
                  final url = _normalizeRelayUrl(value.trim());
                  if (!_isValidRelayUrl(url)) {
                    setDialogState(() => errorText = 'Invalid relay URL');
                    return;
                  }
                  Navigator.pop(context, MapEntry(url, marker));
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
              const SizedBox(height: 16),
              Text(
                'Direction',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ReadWriteMarker>(
                segments: const [
                  ButtonSegment(
                    value: ReadWriteMarker.readWrite,
                    label: Text('Read & Write'),
                  ),
                  ButtonSegment(
                    value: ReadWriteMarker.readOnly,
                    label: Text('Read'),
                  ),
                  ButtonSegment(
                    value: ReadWriteMarker.writeOnly,
                    label: Text('Write'),
                  ),
                ],
                selected: {marker},
                onSelectionChanged: (selected) {
                  setDialogState(() => marker = selected.first);
                },
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
                Navigator.pop(context, MapEntry(url, marker));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null &&
        _relays != null &&
        !_relays!.containsKey(result.key)) {
      setState(() => _relays![result.key] = result.value);
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

  void _cycleMarker(String relayUrl) {
    if (_relays == null || !_relays!.containsKey(relayUrl)) return;
    setState(() {
      final current = _relays![relayUrl]!;
      _relays![relayUrl] = switch (current) {
        ReadWriteMarker.readWrite => ReadWriteMarker.readOnly,
        ReadWriteMarker.readOnly => ReadWriteMarker.writeOnly,
        ReadWriteMarker.writeOnly => ReadWriteMarker.readWrite,
      };
    });
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final nostrMailService = Get.find<NostrMailService>();
      final relaysToSave = Map<String, ReadWriteMarker>.from(_relays!)
        ..removeWhere((key, _) => _markedForDeletion.contains(key));
      await nostrMailService.saveNip65Relays(relaysToSave);
      setState(() {
        _relays = relaysToSave;
        _originalRelays = Map.from(relaysToSave);
        _markedForDeletion.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _markerLabel(ReadWriteMarker marker) {
    return switch (marker) {
      ReadWriteMarker.readWrite => 'read/write',
      ReadWriteMarker.readOnly => 'read',
      ReadWriteMarker.writeOnly => 'write',
    };
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
            'NIP-65 Relays',
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
        if (_relays == null || _relays!.isEmpty)
          const ListTile(
            leading: Icon(Icons.warning_outlined, size: 20),
            title: Text('No NIP-65 relays configured'),
            subtitle: Text('Tap + to add a relay'),
          )
        else
          ..._relays!.entries.map((entry) {
            final relay = entry.key;
            final marker = entry.value;
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
              subtitle: GestureDetector(
                onTap: isMarked ? null : () => _cycleMarker(relay),
                child: Text(
                  _markerLabel(marker),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMarked
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).colorScheme.primary,
                  ),
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
