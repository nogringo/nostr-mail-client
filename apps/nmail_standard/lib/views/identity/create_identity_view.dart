import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/create_identity_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import 'widgets/display_name_field.dart';
import 'widgets/local_part_section.dart';
import 'widgets/bridge_section.dart';
import 'widgets/preview_section.dart';

class CreateIdentityView extends StatelessWidget {
  const CreateIdentityView({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<CreateIdentityController>(
      init: CreateIdentityController(),
      builder: (controller) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(l.createIdentityTitle),
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [
              FilledButton(
                onPressed:
                    (controller.isSaving.value || !controller.isFormValid)
                    ? null
                    : controller.saveIdentity,
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.actionSave),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 500,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DisplayNameField(controller: controller),
                  const SizedBox(height: 24),
                  LocalPartSection(controller: controller),
                  const SizedBox(height: 24),
                  BridgeSection(controller: controller),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  PreviewSection(controller: controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
