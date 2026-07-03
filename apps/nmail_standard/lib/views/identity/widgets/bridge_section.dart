import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/create_identity_controller.dart';
import '../../../app/config/nostr_config.dart';
import '../../../l10n/generated/app_localizations.dart';

class BridgeSection extends StatelessWidget {
  final CreateIdentityController controller;

  const BridgeSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.createIdentityBridge,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GetBuilder<CreateIdentityController>(
          builder: (_) => _buildBridgeChips(context),
        ),
        const SizedBox(height: 8),
        _buildBridgeTextField(context),
      ],
    );
  }

  Widget _buildBridgeChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final availableBridges = controller.availableBridges;

    final allBridges = {
      ...availableBridges,
      ...NostrConfig.recommendedBridges,
    }.toSet().toList()..sort();

    if (allBridges.isEmpty) {
      final l = AppLocalizations.of(context);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l.createIdentityNoBridges),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...allBridges.map((bridge) {
          final isSelected = controller.selectedBridge == bridge;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isSelected ? 0 : 1),
            child: ActionChip(
              label: Text(bridge),
              onPressed: () => controller.selectBridge(bridge),
              backgroundColor: isSelected ? colorScheme.primaryContainer : null,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
              shape: StadiumBorder(
                side: isSelected
                    ? BorderSide(color: colorScheme.primary, width: 2)
                    : BorderSide.none,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBridgeTextField(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextField(
      controller: controller.bridgeController,
      decoration: InputDecoration(hintText: l.createIdentityBridgeHint),
      keyboardType: TextInputType.url,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s'), replacementString: ''),
      ],
      onChanged: (_) => controller.checkBridgeFormat(),
    );
  }
}
