import 'package:andomie_pagination/flutter_pagination.dart';
import 'package:flutter/widgets.dart';

typedef ItemWidgetBuilder<T extends Object> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

/// Supplies builders for the visual components of paged views.
///
/// The generic type [T] must be specified in order to properly identify
/// the list item’s type.
class PaginationBuilderDelegate<T extends Object> {
  const PaginationBuilderDelegate({
    required this.itemBuilder,
    this.completeBuilder,
    this.initialError,
    this.initialIndicator,
    this.nullableError,
    this.ongoingError,
    this.ongoingIndicator,
    this.animateTransitions = false,
    this.transitionDuration = const Duration(milliseconds: 250),
  });

  /// The builder for list items.
  final ItemWidgetBuilder<PaginationData<T>> itemBuilder;

  /// Whether status transitions should be animated.
  final bool animateTransitions;

  /// The duration of animated transitions when [animateTransitions] is `true`.
  final Duration transitionDuration;

  /// The builder for an indicator that all items have been fetched.
  final WidgetBuilder? completeBuilder;

  /// The builder for the first page's error indicator.
  final WidgetBuilder? initialError;

  /// The builder for the first page's progress indicator.
  final WidgetBuilder? initialIndicator;

  /// The builder for a no items list indicator.
  final WidgetBuilder? nullableError;

  /// The builder for a new page's error indicator.
  final WidgetBuilder? ongoingError;

  /// The builder for a new page's progress indicator.
  final WidgetBuilder? ongoingIndicator;
}
