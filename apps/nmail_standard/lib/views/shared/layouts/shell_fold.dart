import 'package:flutter/material.dart';
import 'package:nmail_standard/views/shared/layouts/wide_layout.dart';

import '../layout_constants.dart';

class ShellFold extends StatelessWidget {
  final Widget body;

  const ShellFold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final hasTopPadding = MediaQuery.of(context).padding.top > 0;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: hasTopPadding ? 0 : LayoutConstants.shellPadding,
          right: LayoutConstants.shellPadding,
          bottom: LayoutConstants.shellPadding,
        ),
        child: WideLayout(body: body),
      ),
    );
  }
}
