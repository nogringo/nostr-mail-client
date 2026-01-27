import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/nostr_mail_service.dart';

class BlossomServersSection extends StatefulWidget {
  const BlossomServersSection({super.key});

  @override
  State<BlossomServersSection> createState() => _BlossomServersSectionState();
}

class _BlossomServersSectionState extends State<BlossomServersSection> {
  List<String>? _originalServers;
  List<String>? _servers;
  final Set<String> _markedForDeletion = {};
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _hasChanges {
    if (_originalServers == null || _servers == null) return false;
    if (_markedForDeletion.isNotEmpty) return true;
    if (_originalServers!.length != _servers!.length) return true;
    for (int i = 0; i < _originalServers!.length; i++) {
      if (!_servers!.contains(_originalServers![i])) return true;
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
    final servers = await nostrMailService.getBlossomServers();
    if (mounted) {
      setState(() {
        _originalServers = List.from(servers);
        _servers = List.from(servers);
        _isLoading = false;
      });
    }
  }

  Future<void> _addServer() async {
    final controller = TextEditingController();
    String? errorText;
    String? preview;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Blossom Server'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'https://blossom.example.com',
                  labelText: 'Server URL',
                  errorText: errorText,
                ),
                autofocus: true,
                onChanged: (value) {
                  setDialogState(() {
                    errorText = null;
                    final normalized = _normalizeServerUrl(value.trim());
                    preview = (normalized != value.trim()) ? normalized : null;
                  });
                },
                onSubmitted: (value) {
                  final url = _normalizeServerUrl(value.trim());
                  if (!_isValidServerUrl(url)) {
                    setDialogState(() => errorText = 'Invalid server URL');
                    return;
                  }
                  Navigator.pop(context, url);
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
                final url = _normalizeServerUrl(controller.text.trim());
                if (!_isValidServerUrl(url)) {
                  setDialogState(() => errorText = 'Invalid server URL');
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

    if (result != null && _servers != null && !_servers!.contains(result)) {
      setState(() => _servers!.add(result));
    }
  }

  String _normalizeServerUrl(String url) {
    if (url.isEmpty) return url;
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      return 'https://$url';
    }
    return url;
  }

  bool _isValidServerUrl(String url) {
    if (url.isEmpty || url.contains(' ')) return false;
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      return false;
    }
    final uri = Uri.tryParse(url);
    return uri != null && uri.host.isNotEmpty;
  }

  String _formatServerUrl(String url) {
    return url
        .replaceFirst('https://', '')
        .replaceFirst('http://', '')
        .replaceFirst(RegExp(r'/$'), '');
  }

  void _toggleServerDeletion(String serverUrl) {
    setState(() {
      if (_markedForDeletion.contains(serverUrl)) {
        _markedForDeletion.remove(serverUrl);
      } else {
        _markedForDeletion.add(serverUrl);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final nostrMailService = Get.find<NostrMailService>();
      final serversToSave = _servers!
          .where((s) => !_markedForDeletion.contains(s))
          .toList();
      await nostrMailService.saveBlossomServers(serversToSave);
      setState(() {
        _servers = serversToSave;
        _originalServers = List.from(serversToSave);
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
            'Blossom Servers',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _addServer,
            tooltip: 'Add server',
          ),
        ),
        if (_servers == null || _servers!.isEmpty)
          const ListTile(
            leading: Icon(Icons.cloud_off_outlined, size: 20),
            title: Text('No Blossom servers configured'),
            subtitle: Text('Tap + to add a server'),
          )
        else
          ..._servers!.map((server) {
            final isMarked = _markedForDeletion.contains(server);
            return ListTile(
              leading: Icon(
                Icons.cloud_outlined,
                size: 20,
                color: isMarked ? Theme.of(context).disabledColor : null,
              ),
              title: Text(
                _formatServerUrl(server),
                style: TextStyle(
                  fontSize: 14,
                  decoration: isMarked ? TextDecoration.lineThrough : null,
                  color: isMarked ? Theme.of(context).disabledColor : null,
                ),
              ),
              trailing: IconButton(
                icon: Icon(isMarked ? Icons.undo : Icons.close, size: 18),
                onPressed: () => _toggleServerDeletion(server),
                tooltip: isMarked ? 'Undo' : 'Remove server',
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
