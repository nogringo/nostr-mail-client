import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:system_theme/system_theme.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../services/nostr_mail_service.dart';
import '../../utils/platform_helper.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/toast_helper.dart';
import 'widgets/dm_relays_section.dart';
import 'widgets/sync_status_section.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Appearance'),
              _buildThemeModeTile(context, settingsController),
              Obx(
                () => SwitchListTile(
                  title: const Text('Dynamic theme'),
                  subtitle: const Text('Generate colors from background image'),
                  value: settingsController.dynamicTheme.value,
                  onChanged: settingsController.setDynamicTheme,
                ),
              ),
              _buildBackgroundGallery(context, settingsController),
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Advanced options'),
              Obx(
                () => SwitchListTile(
                  title: const Text('Show email source code'),
                  subtitle: const Text(
                    'Adds a button to view raw RFC 2822 content',
                  ),
                  value: settingsController.showRawEmail.value,
                  onChanged: settingsController.setShowRawEmail,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  title: const Text('Always load images'),
                  subtitle: const Text(
                    'Images are blocked by default for privacy',
                  ),
                  value: settingsController.alwaysLoadImages.value,
                  onChanged: settingsController.setAlwaysLoadImages,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Compose'),
              Obx(() {
                final signature = settingsController.emailSignature.value;
                return ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('Email signature'),
                  subtitle: signature.isEmpty
                      ? const Text('No signature configured')
                      : Text(signature),
                  onTap: () =>
                      _showSignatureDialog(context, settingsController),
                );
              }),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Account'),
              Builder(
                builder: (context) {
                  final authController = Get.find<AuthController>();
                  final nsec = authController.getNsec();
                  if (nsec == null) return const SizedBox.shrink();
                  return ListTile(
                    leading: const Icon(Icons.key),
                    title: const Text('Copy my private key (nsec)'),
                    subtitle: const Text('Keep this key safe'),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: nsec));
                      if (context.mounted) {
                        ToastHelper.success(context, 'Private key copied');
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.find<AuthController>().logout();
                  Get.offAllNamed('/login');
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Synchronization'),
              const DmRelaysSection(),
              const SizedBox(height: 16),
              const SyncStatusSection(),
            ],
          ),
        ),
      ),
    );
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

  void _showSignatureDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final textController = TextEditingController(
      text: controller.emailSignature.value,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Email signature'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: textController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter your signature...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.setEmailSignature(textController.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    SettingsController controller,
  ) {
    return Obx(() {
      final mode = controller.themeMode.value;
      return ListTile(
        leading: Icon(
          mode == ThemeMode.dark
              ? Icons.dark_mode
              : mode == ThemeMode.light
              ? Icons.light_mode
              : Icons.brightness_auto,
        ),
        title: const Text('Theme'),
        trailing: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {mode},
          onSelectionChanged: (selected) {
            controller.setThemeMode(selected.first);
          },
        ),
      );
    });
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
    return MouseRegion(
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
              child: GestureDetector(
                onTap: () => controller.setBackgroundImage(null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultColorItem(
    BuildContext context,
    SettingsController controller,
  ) {
    final isSelected =
        controller.backgroundImage.value == null ||
        controller.backgroundImage.value!.isEmpty;

    // Use system accent color's tertiaryContainer for the default item preview
    final systemScheme = ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Theme.of(context).brightness,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.setBackgroundImage(null),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: systemScheme.tertiaryContainer,
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
    );
  }

  Widget _buildAddButton(BuildContext context, SettingsController controller) {
    return MouseRegion(
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
    );
  }

  Widget _buildGalleryItem(
    BuildContext context,
    SettingsController controller,
    File file,
    bool isSelected,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.setBackgroundImage(file.path),
        onLongPress: () =>
            _showDeleteBackgroundDialog(context, controller, file),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
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
              child: GestureDetector(
                onTap: () =>
                    _showDeleteBackgroundDialog(context, controller, file),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
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
    Get.dialog(
      AlertDialog(
        title: const Text('Delete background'),
        content: const Text('Remove this image from your saved backgrounds?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await file.delete();
                // Force rebuild
                controller.backgroundImage.refresh();
                if (context.mounted) {
                  ToastHelper.success(context, 'Image deleted');
                }
              } catch (e) {
                if (context.mounted) {
                  ToastHelper.error(context, 'Failed to delete image');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBackgroundImageOptions(
    BuildContext context,
    SettingsController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Background'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.image_outlined),
              title: const Text('Select file'),
              onTap: () {
                Get.back();
                _pickBackgroundImage(context, controller);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.link),
              title: const Text('Paste URL'),
              onTap: () {
                Get.back();
                _showBackgroundUrlDialog(context, controller);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
    final dir = Directory(p.join(appDir.path, 'backgrounds'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _pickAndCopyImageLocally(
    BuildContext context,
    SettingsController controller,
  ) async {
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
        ToastHelper.success(context, 'Image set');
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.error(context, 'Failed to copy image');
      }
    }
  }

  void _showBackgroundUrlDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final textController = TextEditingController(
      text: PlatformHelper.isNative
          ? ''
          : (controller.backgroundImage.value ?? ''),
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Background URL'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'https://example.com/image.jpg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
            child: const Text('Save'),
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
    // Show loading
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Validating...'),
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
        ToastHelper.success(context, 'Background set');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      if (context.mounted) {
        ToastHelper.error(
          context,
          'Image not accessible (CORS or network error)',
        );
      }
    }
  }

  Future<void> _downloadAndSaveImage(
    BuildContext context,
    SettingsController controller,
    String url,
  ) async {
    // Show loading
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Downloading...'),
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
        ToastHelper.success(context, 'Image downloaded');
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      if (context.mounted) {
        ToastHelper.error(context, 'Failed to download image');
      }
    }
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    SettingsController controller,
  ) async {
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
        title: const Text('Upload image'),
        content: const Text(
          'This image will be uploaded to Blossom servers. Server operators and anyone with the link can view it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final file = result.files.single;

    // Show loading
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Uploading...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final ndk = Get.find<NostrMailService>().ndk;
      final uploadResults = await ndk.blossom.uploadBlob(
        data: file.bytes!,
        contentType: file.extension != null ? 'image/${file.extension}' : null,
      );

      Get.back(); // Close loading dialog

      final successResult = uploadResults.firstWhere(
        (r) => r.success && r.descriptor != null,
        orElse: () => uploadResults.first,
      );

      if (successResult.success && successResult.descriptor != null) {
        controller.setBackgroundImage(successResult.descriptor!.url);
        if (context.mounted) {
          ToastHelper.success(context, 'Image uploaded');
        }
      } else {
        if (context.mounted) {
          ToastHelper.error(context, successResult.error ?? 'Upload failed');
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
