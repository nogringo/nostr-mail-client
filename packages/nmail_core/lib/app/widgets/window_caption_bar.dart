import 'package:flutter/material.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/views/shared/layout_constants.dart';
import 'package:window_manager/window_manager.dart';

/// Stands in for the title bar the desktop window hides. macOS keeps its own
/// traffic lights, so only the drag strip is drawn there.
class WindowCaptionBar extends StatelessWidget {
  const WindowCaptionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LayoutConstants.windowCaptionHeight,
      child: Row(
        children: [
          Expanded(child: DragToMoveArea(child: Container())),
          if (!PlatformHelper.isMacOS)
            SizedBox(
              width: 154,
              child: WindowCaption(
                brightness: Theme.of(context).brightness,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }
}
