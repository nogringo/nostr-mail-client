import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/recipient_autocomplete_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/contact.dart';
import 'contact_suggestion_tile.dart';

class RecipientAutocomplete extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final Set<String> excludeIds;
  final void Function(Contact contact) onContactSelected;
  final Future<bool> Function(String input) onManualInput;
  final void Function(String value) onSubmitted;

  const RecipientAutocomplete({
    super.key,
    required this.textController,
    required this.hintText,
    required this.excludeIds,
    required this.onContactSelected,
    required this.onManualInput,
    required this.onSubmitted,
  });

  String get _controllerTag =>
      'recipient-autocomplete-${identityHashCode(textController)}';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecipientAutocompleteController>(
      tag: _controllerTag,
      init: RecipientAutocompleteController(
        textController: textController,
        excludeIds: excludeIds,
        onContactSelected: onContactSelected,
        onManualInput: onManualInput,
      ),
      builder: (controller) {
        controller
          ..updateConfig(
            excludeIds: excludeIds,
            onContactSelected: onContactSelected,
            onManualInput: onManualInput,
          )
          ..bindOverlay(
            context,
            (overlayContext) => _buildOverlay(overlayContext, controller),
          );

        return TapRegion(
          groupId: controller.tapRegionGroup,
          onTapOutside: controller.onTapOutside,
          child: Focus(
            onKeyEvent: controller.handleKeyEvent,
            child: CompositedTransformTarget(
              key: controller.textFieldKey,
              link: controller.layerLink,
              child: TextField(
                controller: textController,
                focusNode: controller.focusNode,
                groupId: controller.tapRegionGroup,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16),
                keyboardType: TextInputType.emailAddress,
                onSubmitted: controller.handleSubmitted,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    RecipientAutocompleteController controller,
  ) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final renderBox =
        controller.textFieldKey.currentContext?.findRenderObject()
            as RenderBox?;
    final width = renderBox?.size.width ?? 350;

    return Positioned(
      width: width,
      child: CompositedTransformFollower(
        link: controller.layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 40),
        child: TapRegion(
          groupId: controller.tapRegionGroup,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isSearching)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l.composeResolvingNip05,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (controller.suggestions.isNotEmpty)
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: controller.suggestions.length,
                          itemBuilder: (context, index) {
                            return ContactSuggestionTile(
                              contact: controller.suggestions[index],
                              isHighlighted:
                                  index == controller.highlightedIndex,
                              onTap: () => controller.selectContact(
                                controller.suggestions[index],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
