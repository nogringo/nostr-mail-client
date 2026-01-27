import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';

import '../../../services/nostr_mail_service.dart';
import '../../../utils/relay_utils.dart';

class RelayConnectivitySection extends StatefulWidget {
  const RelayConnectivitySection({super.key});

  @override
  State<RelayConnectivitySection> createState() =>
      _RelayConnectivitySectionState();
}

class _RelayConnectivitySectionState extends State<RelayConnectivitySection> {
  StreamSubscription<Map<String, RelayConnectivity>>? _subscription;
  Map<String, RelayConnectivity> _connectivityMap = {};
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _subscribeToConnectivity();
  }

  void _subscribeToConnectivity() {
    final nostrMailService = Get.find<NostrMailService>();
    _subscription = nostrMailService.relayConnectivityChanges.listen((map) {
      if (mounted) {
        setState(() => _connectivityMap = map);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  int get _connectedCount =>
      _connectivityMap.values.where((c) => c.isConnected).length;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final connected = _connectedCount;
    final total = _connectivityMap.length;

    return ExpansionTile(
      onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
      leading: Icon(
        connected > 0 ? Icons.wifi : Icons.wifi_off,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        'Relay Connectivity',
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$connected / $total',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.expand_more, size: 20),
          ),
        ],
      ),
      children: _connectivityMap.entries.map((entry) {
        final url = entry.key;
        final connectivity = entry.value;
        final isConnected = connectivity.isConnected;

        return ListTile(
          dense: true,
          leading: Icon(
            isConnected ? Icons.power : Icons.power_off,
            color: isConnected ? colorScheme.primary : colorScheme.outline,
            size: 16,
          ),
          title: Text(
            formatRelayUrl(url),
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }
}
