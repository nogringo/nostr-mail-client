// TODO: this file is too long - extract _buildX helpers into widgets/ (one widget per file)
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';
import 'package:system_theme/system_theme.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/sensitive_clipboard.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'widgets/about_section.dart';
import 'widgets/language_tile.dart';
import 'widgets/unified_push_distributor_help_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsController = Get.find<SettingsController>();

    Widget content = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          // Reached via `context.go` from inbox/drawer/rail, so there is
          // typically nothing to pop. Fall back to the inbox.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.inbox),
        ),
        title: Text(l.settingsTitle),
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionHeader(context, l.settingsAppearance),
              _buildThemeModeTile(context, settingsController),
              Obx(
                () => SwitchListTile(
                  title: Text(l.settingsDynamicTheme),
                  subtitle: Text(l.settingsDynamicThemeSubtitle),
                  value: settingsController.dynamicTheme.value,
                  onChanged: settingsController.setDynamicTheme,
                ),
              ),
              _buildBackgroundGallery(context, settingsController),
              const LanguageTile(),
              const SizedBox(height: 16),
              _buildSectionHeader(context, l.settingsNotifications),
              Obx(
                () => SwitchListTile(
                  title: Text(l.settingsEnableNotifications),
                  subtitle: Text(l.settingsEnableNotificationsSubtitle),
                  value: settingsController.notificationsEnabled.value,
                  onChanged: settingsController.setNotificationsEnabled,
                ),
              ),
              const UnifiedPushDistributorHelpTile(),
              const SizedBox(height: 16),
              _buildSectionHeader(context, l.settingsAdvancedOptions),
              Obx(
                () => SwitchListTile(
                  title: Text(l.settingsShowEmailSource),
                  subtitle: Text(l.settingsShowEmailSourceSubtitle),
                  value: settingsController.showRawEmail.value,
                  onChanged: settingsController.setShowRawEmail,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  title: Text(l.settingsAlwaysLoadImages),
                  subtitle: Text(l.settingsAlwaysLoadImagesSubtitle),
                  value: settingsController.alwaysLoadImages.value,
                  onChanged: settingsController.setAlwaysLoadImages,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l.settingsIdentities),
              ListTile(
                leading: const Icon(Icons.alternate_email),
                title: Text(l.settingsManageIdentities),
                subtitle: Text(l.settingsManageIdentitiesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.settingsIdentities),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l.settingsCompose),
              Obx(() {
                final signature = settingsController.emailSignature.value;
                return ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: Text(l.settingsEmailSignature),
                  subtitle: signature.isEmpty
                      ? Text(l.settingsEmailSignatureEmpty)
                      : Text(signature),
                  onTap: () =>
                      _showSignatureDialog(context, settingsController),
                );
              }),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l.settingsSynchronization),
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: Text(l.settingsHosting),
                subtitle: Text(l.settingsHostingSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.settingsHosting),
              ),
              if (kDebugMode)
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(l.settingsDebugTools),
                  subtitle: Text(l.settingsDebugToolsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRoutes.settingsDebugTools),
                ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l.settingsAccount),
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: Text(l.accountsManage),
                subtitle: Text(l.accountsManageSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.accounts),
              ),
              Builder(
                builder: (context) {
                  final authController = Get.find<AuthController>();
                  final nsec = authController.getNsec();
                  if (nsec == null) return const SizedBox.shrink();
                  return ListTile(
                    leading: const Icon(Icons.key),
                    title: Text(l.settingsCopySyncCode),
                    subtitle: Text(l.settingsCopySyncCodeSubtitle),
                    onTap: () async {
                      await SensitiveClipboard.copy(nsec, label: 'sync code');
                      if (!PlatformHelper.isAndroid && context.mounted) {
                        ToastHelper.success(context, l.settingsSyncCodeCopied);
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l.settingsLogOut,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Get.find<AuthController>().logout();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l.settingsResetApplication,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: Text(l.settingsResetApplicationSubtitle),
                onTap: () => _showResetConfirmationDialog(context),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l.settingsAbout),
              const AboutSection(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );

    return content;
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    final l = AppLocalizations.of(context);
    Get.dialog(
      AlertDialog(
        title: Text(l.settingsResetApplication),
        content: Text(l.settingsResetConfirmMessage),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () async {
              Get.back();
              Get.dialog(
                AlertDialog(
                  content: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Text(l.stateResetting),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );
              await Get.find<SettingsController>().resetApplication();
            },
            child: Text(
              l.actionReset,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignatureDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final l = AppLocalizations.of(context);
    final textController = TextEditingController(
      text: controller.emailSignature.value,
    );

    Get.dialog(
      AlertDialog(
        title: Text(l.settingsEmailSignature),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: textController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: l.settingsEmailSignatureHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () {
              controller.setEmailSignature(textController.text);
              Get.back();
            },
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    SettingsController controller,
  ) {
    final l = AppLocalizations.of(context);
    return Obx(() {
      final mode = controller.themeMode.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Icon(
                    mode == ThemeMode.dark
                        ? Icons.dark_mode
                        : mode == ThemeMode.light
                        ? Icons.light_mode
                        : Icons.brightness_auto,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l.settingsTheme,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: _buildThemeModeLabel(l.settingsThemeAuto),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: _buildThemeModeLabel(l.settingsThemeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: _buildThemeModeLabel(l.settingsThemeDark),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selected) {
                        controller.setThemeMode(selected.first);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildThemeModeLabel(String label) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBackgroundGallery(
    BuildContext context,
    SettingsController controller,
  ) {
    // On web, just show a simple add button
    if (!PlatformHelper.isNative) {
      return _buildWebBackgroundGallery(context, controller);
    }

    return Obx(() {
      // Trigger rebuild when background changes
      final currentImage = controller.backgroundImage.value;

      return FutureBuilder<List<File>>(
        future: _listBackgroundFiles(),
        builder: (context, snapshot) {
          final files = snapshot.data ?? [];

          // Items: default color + all saved images + add button
          // itemCount = 1 (default) + files.length + 1 (add button)
          final itemCount = files.length + 2;

          return _buildHorizontalScrollable(
            builder: (scrollController) => ListView.separated(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                // First item is the default theme color
                if (index == 0) {
                  return _buildDefaultColorItem(context, controller);
                }
                // Last item is the add button
                if (index == itemCount - 1) {
                  return _buildAddButton(context, controller);
                }
                // Middle items are saved images
                final file = files[index - 1];
                final isSelected = file.path == currentImage;
                return _buildGalleryItem(context, controller, file, isSelected);
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildHorizontalScrollable({
    required Widget Function(ScrollController) builder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 80,
        child: StatefulBuilder(
          builder: (context, setState) {
            final controller = ScrollController();
            return Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  GestureBinding.instance.pointerSignalResolver.register(
                    event,
                    (event) {
                      final e = event as PointerScrollEvent;
                      final offset = controller.offset + e.scrollDelta.dy;
                      controller.jumpTo(
                        offset.clamp(0.0, controller.position.maxScrollExtent),
                      );
                    },
                  );
                }
              },
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: builder(controller),
              ),
            );
          },
        ),
      ),
    );
  }

  // TODO: Add URL history for web (store previous URLs in settings)
  Widget _buildWebBackgroundGallery(
    BuildContext context,
    SettingsController controller,
  ) {
    return Obx(() {
      final currentImage = controller.backgroundImage.value;
      final hasImage = currentImage != null && currentImage.isNotEmpty;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              _buildDefaultColorItem(context, controller),
              if (hasImage) ...[
                const SizedBox(width: 8),
                _buildWebImageItem(context, controller, currentImage),
              ],
              const SizedBox(width: 8),
              _buildAddButton(context, controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWebImageItem(
    BuildContext context,
    SettingsController controller,
    String url,
  ) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.settingsBackgroundRemoveLabel,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.setBackgroundImage(null),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: () => controller.setBackgroundImage(null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultColorItem(
    BuildContext context,
    SettingsController controller,
  ) {
    final l = AppLocalizations.of(context);
    final isSelected =
        controller.backgroundImage.value == null ||
        controller.backgroundImage.value!.isEmpty;

    final systemScheme = ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Theme.of(context).brightness,
    );

    return Semantics(
      label: l.settingsBackgroundDefaultLabel,
      button: true,
      selected: isSelected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.setBackgroundImage(null),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: systemScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, SettingsController controller) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.settingsBackgroundAddLabel,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showBackgroundImageOptions(context, controller),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(
    BuildContext context,
    SettingsController controller,
    File file,
    bool isSelected,
  ) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.settingsBackgroundSelectLabel,
      button: true,
      selected: isSelected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.setBackgroundImage(file.path),
          onLongPress: () =>
              _showDeleteBackgroundDialog(context, controller, file),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  file,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              if (isSelected)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: Semantics(
                  label: l.settingsBackgroundDeleteLabel,
                  button: true,
                  child: GestureDetector(
                    onTap: () =>
                        _showDeleteBackgroundDialog(context, controller, file),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<File>> _listBackgroundFiles() async {
    try {
      final dir = await _getBackgroundDir();
      if (!await dir.exists()) return [];

      final files = await dir
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();

      // Sort by modification time, newest first
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      return files;
    } catch (e) {
      return [];
    }
  }

  void _showDeleteBackgroundDialog(
    BuildContext context,
    SettingsController controller,
    File file,
  ) {
    final l = AppLocalizations.of(context);
    Get.dialog(
      AlertDialog(
        title: Text(l.settingsBackgroundDeleteTitle),
        content: Text(l.settingsBackgroundDeleteMessage),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await file.delete();
                // Force rebuild
                controller.backgroundImage.refresh();
                if (context.mounted) {
                  ToastHelper.success(
                    context,
                    l.settingsBackgroundImageDeleted,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ToastHelper.error(context, l.settingsBackgroundDeleteFailed);
                }
              }
            },
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
  }

  void _showBackgroundImageOptions(
    BuildContext context,
    SettingsController controller,
  ) {
    final l = AppLocalizations.of(context);
    Get.dialog(
      AlertDialog(
        title: Text(l.settingsBackgroundDialogTitle),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.image_outlined),
              title: Text(l.settingsBackgroundSelectFile),
              onTap: () {
                Get.back();
                _pickBackgroundImage(context, controller);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.link),
              title: Text(l.settingsBackgroundPasteUrl),
              onTap: () {
                Get.back();
                _showBackgroundUrlDialog(context, controller);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
        ],
      ),
    );
  }

  Future<void> _pickBackgroundImage(
    BuildContext context,
    SettingsController controller,
  ) async {
    if (PlatformHelper.isNative) {
      await _pickAndCopyImageLocally(context, controller);
    } else {
      await _pickAndUploadImage(context, controller);
    }
  }

  Future<Directory> _getBackgroundDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(
      p.join(appDir.path, SettingsController.backgroundsDirName),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _pickAndCopyImageLocally(
    BuildContext context,
    SettingsController controller,
  ) async {
    final l = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final sourcePath = result.files.single.path!;
    final sourceFile = File(sourcePath);
    final fileName = result.files.single.name;

    try {
      final backgroundDir = await _getBackgroundDir();
      final destPath = p.join(backgroundDir.path, fileName);
      await sourceFile.copy(destPath);

      controller.setBackgroundImage(destPath);
      if (context.mounted) {
        ToastHelper.success(context, l.settingsBackgroundImageSet);
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundCopyFailed);
      }
    }
  }

  void _showBackgroundUrlDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final l = AppLocalizations.of(context);
    final textController = TextEditingController(
      text: PlatformHelper.isNative
          ? ''
          : (controller.backgroundImage.value ?? ''),
    );

    Get.dialog(
      AlertDialog(
        title: Text(l.settingsBackgroundUrlTitle),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: l.settingsBackgroundUrlHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () {
              final url = textController.text.trim();
              Get.back();
              if (url.isEmpty) {
                controller.setBackgroundImage(null);
              } else if (PlatformHelper.isNative) {
                _downloadAndSaveImage(context, controller, url);
              } else {
                _validateAndSetWebImage(context, controller, url);
              }
            },
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndSetWebImage(
    BuildContext context,
    SettingsController controller,
    String url,
  ) async {
    final l = AppLocalizations.of(context);
    // Show loading
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l.stateValidating),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Try to load the image to validate it's accessible
      final image = NetworkImage(url);
      final completer = Completer<void>();

      final stream = image.resolve(const ImageConfiguration());
      stream.addListener(
        ImageStreamListener(
          (_, _) => completer.complete(),
          onError: (error, _) => completer.completeError(error),
        ),
      );

      await completer.future.timeout(const Duration(seconds: 10));

      Get.back(); // Close loading dialog

      controller.setBackgroundImage(url);
      if (context.mounted) {
        ToastHelper.success(context, l.settingsBackgroundSet);
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundUrlError);
      }
    }
  }

  Future<void> _downloadAndSaveImage(
    BuildContext context,
    SettingsController controller,
    String url,
  ) async {
    final l = AppLocalizations.of(context);
    // Show loading
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l.stateDownloading),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Get file extension from URL or content-type
      var extension = url.split('.').last.split('?').first;
      if (extension.length > 4) {
        final contentType = response.headers['content-type'];
        extension = contentType?.split('/').last ?? 'jpg';
      }

      final backgroundDir = await _getBackgroundDir();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final destPath = p.join(backgroundDir.path, fileName);
      await File(destPath).writeAsBytes(response.bodyBytes);

      Get.back(); // Close loading dialog

      controller.setBackgroundImage(destPath);
      if (context.mounted) {
        ToastHelper.success(context, l.settingsBackgroundDownloaded);
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundDownloadFailed);
      }
    }
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    SettingsController controller,
  ) async {
    final l = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    // TODO: Implement encrypted upload for privacy (encrypt image before upload, decrypt on display)
    // Warning about upload
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l.settingsBackgroundUploadTitle),
        content: Text(l.settingsBackgroundUploadWarning),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(l.actionUpload),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final file = result.files.single;

    // Show loading
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l.stateUploading),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final ndk = Get.find<Ndk>();
      final nostrMailService = Get.find<NostrMailService>();

      // Check if user has configured servers, otherwise use defaults
      final userServers = await nostrMailService.getBlossomServers();
      final serverUrls = userServers.isNotEmpty
          ? userServers
          : NostrConfig.recommendedBlossomServers;

      final uploadResults = await ndk.blossom.uploadBlob(
        data: file.bytes!,
        contentType: file.extension != null ? 'image/${file.extension}' : null,
        serverUrls: serverUrls,
      );

      Get.back(); // Close loading dialog

      final successResult = uploadResults.firstWhere(
        (r) => r.success && r.descriptor != null,
        orElse: () => uploadResults.first,
      );

      if (successResult.success && successResult.descriptor != null) {
        controller.setBackgroundImage(successResult.descriptor!.url);
      } else {
        if (context.mounted) {
          ToastHelper.error(
            context,
            successResult.error ?? l.profileUploadFailed,
          );
        }
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      if (context.mounted) {
        ToastHelper.error(context, e.toString());
      }
    }
  }
}
