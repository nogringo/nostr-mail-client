import 'package:flutter/widgets.dart';

/// A click inside, on a formatting toolbar for one, leaves the focused text
/// field focused instead of unfocusing it.
class KeepsTextFieldFocus extends StatelessWidget {
  const KeepsTextFieldFocus({super.key, required this.child});

  /// Marks the region in the DOM of Flutter web.
  static const semanticsIdentifier = 'keeps-text-field-focus';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      identifier: semanticsIdentifier,
      child: TextFieldTapRegion(child: child),
    );
  }
}
