import 'package:flutter/widgets.dart';

/// A widget that calls [listener] when the given [Listenable] changes value.
class PaginationListener extends StatefulWidget {
  const PaginationListener({
    super.key,
    required this.listenable,
    required this.child,
    this.listener,
  });

  /// The [Listenable] to which this widget is listening.
  ///
  /// Commonly an [Animation] or a [ChangeNotifier].
  final Listenable listenable;

  /// Called every time the [listenable] changes value.
  final VoidCallback? listener;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<PaginationListener> createState() => _PaginationListenerState();
}

class _PaginationListenerState extends State<PaginationListener> {
  Listenable get _listenable => widget.listenable;

  @override
  void initState() {
    super.initState();
    _listenable.addListener(_handleChange);
    _handleChange();
  }

  @override
  void didUpdateWidget(PaginationListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_handleChange);
      _listenable.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    _listenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    widget.listener?.call();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
