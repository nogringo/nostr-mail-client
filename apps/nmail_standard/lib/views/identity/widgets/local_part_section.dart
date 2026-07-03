import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/create_identity_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/local_part_format.dart';

class LocalPartSection extends StatelessWidget {
  final CreateIdentityController controller;

  const LocalPartSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.createIdentityAddress,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildLocalPartChips(context),
        const SizedBox(height: 8),
        TextField(
          controller: controller.localPartController,
          decoration: InputDecoration(hintText: l.createIdentityCustomUsername),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.@-]')),
          ],
          onChanged: (_) => controller.checkLocalPartFormat(),
        ),
      ],
    );
  }

  Widget _buildLocalPartChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GetBuilder<CreateIdentityController>(
      builder: (_) => Wrap(
        spacing: 8,
        children: [
          _buildFormatChip(
            context,
            label: 'npub',
            format: LocalPartFormat.npub,
            colorScheme: colorScheme,
          ),
          _buildFormatChip(
            context,
            label: 'hex',
            format: LocalPartFormat.hex,
            colorScheme: colorScheme,
          ),
          _buildFormatChip(
            context,
            label: 'base36',
            format: LocalPartFormat.base36,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(
    BuildContext context, {
    required String label,
    required LocalPartFormat format,
    required ColorScheme colorScheme,
  }) {
    final isSelected = controller.selectedFormat == format;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSelected ? 0 : 1),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          switch (format) {
            case LocalPartFormat.npub:
              controller.useNpub();
              break;
            case LocalPartFormat.hex:
              controller.useHex();
              break;
            case LocalPartFormat.base36:
              controller.useBase36();
              break;
          }
        },
        backgroundColor: isSelected ? colorScheme.primaryContainer : null,
        labelStyle: TextStyle(
          color: isSelected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface,
          // fontWeight: isSelected ? FontWeight.w600 : null,
        ),
        shape: StadiumBorder(
          side: isSelected
              ? BorderSide(color: colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }
}
