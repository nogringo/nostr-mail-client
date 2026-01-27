import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/toast_helper.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _pictureController = TextEditingController();
  final _aboutController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pictureController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    final pubkey = Get.find<AuthController>().publicKey;
    if (pubkey == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final ndk = Get.find<Ndk>();
      final metadata = await ndk.metadata.loadMetadata(pubkey);

      if (mounted) {
        setState(() {
          _nameController.text = metadata?.name ?? '';
          _pictureController.text = metadata?.picture ?? '';
          _aboutController.text = metadata?.about ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final ndk = Get.find<Ndk>();

      final metadata = Metadata(
        pubKey: Get.find<AuthController>().publicKey!,
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        picture: _pictureController.text.trim().isEmpty
            ? null
            : _pictureController.text.trim(),
        about: _aboutController.text.trim().isEmpty
            ? null
            : _aboutController.text.trim(),
      );

      await ndk.metadata.broadcastMetadata(metadata);

      // Refresh metadata in AuthController
      Get.find<AuthController>().userMetadata.value = metadata;

      if (mounted) {
        ToastHelper.success(context, 'Profile updated');
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.error(context, 'Failed to update profile');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ResponsiveCenter(
                maxWidth: 500,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildAvatarPreview(context)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Your display name',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pictureController,
                      decoration: const InputDecoration(
                        labelText: 'Picture URL',
                        hintText: 'https://example.com/avatar.png',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _aboutController,
                      decoration: const InputDecoration(
                        labelText: 'About',
                        hintText: 'A short bio about yourself',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarPreview(BuildContext context) {
    final pictureUrl = _pictureController.text.trim();
    final name = _nameController.text.trim();
    final pubkey = Get.find<AuthController>().publicKey;
    final colorScheme = Theme.of(context).colorScheme;

    if (pictureUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(pictureUrl),
        backgroundColor: colorScheme.primaryContainer,
        onBackgroundImageError: (e, s) {},
      );
    }

    final initial = name.isNotEmpty
        ? name[0].toUpperCase()
        : pubkey != null && pubkey.isNotEmpty
        ? pubkey.substring(0, 2).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 50,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }
}
