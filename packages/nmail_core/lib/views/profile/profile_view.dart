import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/widgets/controller_builder.dart';
import '../../widgets/nostr_avatar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ControllerBuilder(
      create: ProfileController.new,
      builder: (context, controller) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(
            // Reached via `context.go` from inbox/drawer/rail, so there is
            // typically nothing to pop. Fall back to the inbox.
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(AppRoutes.inbox),
          ),
          title: Text(l.profileEditTitle),
          actionsPadding: .only(right: 8),
          actions: [
            if (!controller.isLoading)
              FilledButton(
                onPressed: (controller.isSaving || !controller.hasChanges)
                    ? null
                    : controller.saveProfile,
                child: Text(l.actionSave),
              ),
          ],
        ),
        body: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: ResponsiveCenter(
                  maxWidth: 500,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _buildAvatarPreview(context, controller)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: controller.displayNameController,
                        decoration: InputDecoration(
                          labelText: l.profileDisplayNameLabel,
                          hintText: l.profileDisplayNameHint,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          labelText: l.profileUsernameLabel,
                          hintText: l.profileUsernameHint,
                          prefixText: '@',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-z0-9_.-]'),
                          ),
                        ],
                        textCapitalization: TextCapitalization.none,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller.aboutController,
                        decoration: InputDecoration(
                          labelText: l.profileAboutLabel,
                          hintText: l.profileAboutHint,
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: controller.toggleMoreOptions,
                            icon: AnimatedRotation(
                              turns: controller.showMoreOptions ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.expand_more),
                            ),
                            label: Text(l.profileAdvanced),
                          ),
                          if (controller.showMoreOptions)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TextField(
                                controller: controller.pictureController,
                                decoration: InputDecoration(
                                  labelText: l.profilePictureUrlLabel,
                                  hintText: l.profilePictureUrlHint,
                                ),
                                keyboardType: TextInputType.url,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarPreview(
    BuildContext context,
    ProfileController controller,
  ) {
    final l = AppLocalizations.of(context);
    final pictureUrl = controller.pictureController.text.trim();
    final displayName = controller.displayNameController.text.trim();
    final name = controller.nameController.text.trim();
    final pubkey = Get.find<AuthController>().publicKey;

    final previewMetadata = Metadata(
      pubKey: pubkey ?? '',
      picture: pictureUrl,
      displayName: displayName,
      name: name,
    );

    return Semantics(
      label: l.profileChangePicture,
      button: true,
      enabled: !controller.isUploadingPicture,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: controller.isUploadingPicture
              ? null
              : () => controller.pickAndUploadPicture(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              NostrAvatar(
                pubkey: pubkey ?? '',
                metadata: previewMetadata,
                radius: 60,
              ),
              if (controller.isUploadingPicture)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
