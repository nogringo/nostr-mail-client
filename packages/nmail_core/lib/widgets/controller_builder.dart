import 'package:flutter/widgets.dart';

/// Creates a controller once, rebuilds when it notifies, and disposes it when
/// removed from the tree.
class ControllerBuilder<T extends ChangeNotifier> extends StatefulWidget {
  const ControllerBuilder({
    super.key,
    required this.create,
    required this.builder,
  });

  final T Function() create;
  final Widget Function(BuildContext context, T controller) builder;

  @override
  State<ControllerBuilder<T>> createState() => _ControllerBuilderState<T>();
}

class _ControllerBuilderState<T extends ChangeNotifier>
    extends State<ControllerBuilder<T>> {
  late final T _controller = widget.create();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => widget.builder(context, _controller),
    );
  }
}
