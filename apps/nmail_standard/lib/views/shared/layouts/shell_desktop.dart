import 'package:flutter/material.dart';
import 'package:nmail_standard/views/shared/layouts/wide_layout.dart';

import '../layout_constants.dart';

class ShellDesktop extends StatelessWidget {
  final Widget body;

  const ShellDesktop({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: LayoutConstants.windowCaptionHeight,
        right: LayoutConstants.shellPadding,
        bottom: LayoutConstants.shellPadding,
      ),
      child: WideLayout(body: body),
    );
  }
}
