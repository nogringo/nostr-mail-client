import 'package:flutter/material.dart';

/// Stub view for shared nostr profiles (npub1*, nprofile1*).
/// Real implementation will fetch the profile metadata and offer
/// follow / message actions. For now we just render the bech32 id
/// so the route resolves without crashing.
class ProfileShareView extends StatelessWidget {
  final String bech32;

  const ProfileShareView({super.key, required this.bech32});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 64),
              const SizedBox(height: 16),
              Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              SelectableText(
                bech32,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
