import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CopyMenuItem extends StatelessWidget {
  CopyMenuItem({super.key, required this.label, required this.value});

  final String label;

  /// Read inside [Obx], so it may depend on observables.
  final String? Function() value;

  final _copied = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final text = value();
      return MenuItemButton(
        leadingIcon: Icon(_copied.value ? Icons.check : Icons.copy),
        closeOnActivate: false,
        onPressed: text == null ? null : () => _copy(text),
        child: Text(label),
      );
    });
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _copied.value = true;
    Future.delayed(const Duration(seconds: 2), () => _copied.value = false);
  }
}
