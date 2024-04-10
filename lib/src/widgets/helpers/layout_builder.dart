import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../core/child_builder_delegate.dart';
import '../../model/state.dart';
import '../../model/status.dart';
import '../../pagination.dart';
import '../../utils/listenable_listener.dart';
import '../samples/initial_error.dart';
import '../samples/initial_indicator.dart';
import '../samples/nullable_error.dart';
import '../samples/ongoing_error.dart';
import '../samples/ongoing_indicator.dart';

typedef CompletedListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder? noMoreItemsIndicatorBuilder,
);

typedef ErrorListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder newPageErrorIndicatorBuilder,
);

typedef LoadingListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder newPageProgressIndicatorBuilder,
);

/// The Flutter layout protocols supported by [PaginationLayoutBuilder].
enum PaginationLayoutProtocol { sliver, box }

/// Facilitates creating infinitely scrolled paged layouts.
///
/// Combines a [PaginationController] with a
/// [PaginationBuilderDelegate] and calls the supplied
/// [ongoingBuilder], [errorListingBuilder] or
/// [completeBuilder] for filling in the gaps.
///
/// For ordinary cases, this widget shouldn't be used directly. Instead, take a
/// look at [PagedSliverList], [PagedSliverGrid], [PagedListView],
/// [PagedGridView], [PagedMasonryGridView], or [PagedPageView].
class PaginationLayoutBuilder<T extends Object> extends StatefulWidget {
  const PaginationLayoutBuilder({
    super.key,
    required this.pagination,
    required this.builderDelegate,
    required this.ongoingBuilder,
    required this.errorListingBuilder,
    required this.completeBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
  });

  /// The controller for paged listings.
  ///
  /// Informs the current state of the pagination and requests new items from
  /// its listeners.
  final Pagination<T> pagination;

  /// The delegate for building the UI pieces of scrolling paged listings.
  final PaginationBuilderDelegate<T> builderDelegate;

  /// The builder for an in-progress listing.
  final LoadingListingBuilder ongoingBuilder;

  /// The builder for an in-progress listing with a failed request.
  final ErrorListingBuilder errorListingBuilder;

  /// The builder for a completed listing.
  final CompletedListingBuilder completeBuilder;

  /// Whether the extent of the first page indicators should be determined by
  /// the contents being viewed.
  ///
  /// If the paged layout builder does not shrink wrap, then the first page
  /// indicators will expand to the maximum allowed size. If the paged layout
  /// builder has unbounded constraints, then [shrinkWrapFirstPageIndicators]
  /// must be true.
  ///
  /// Defaults to false.
  final bool shrinkWrapFirstPageIndicators;

  /// The layout protocol of the widget you're using this to build.
  ///
  /// For example, if [PaginationLayoutProtocol.sliver] is specified, then
  /// [ongoingBuilder], [errorListingBuilder], and
  /// [completeBuilder] have to return a Sliver widget.
  final PaginationLayoutProtocol layoutProtocol;

  @override
  State<PaginationLayoutBuilder<T>> createState() {
    return _PaginationLayoutBuilderState<T>();
  }
}

class _PaginationLayoutBuilderState<T extends Object>
    extends State<PaginationLayoutBuilder<T>> {
  Pagination<T> get _pagination => widget.pagination;

  PaginationBuilderDelegate<T> get _delegate => widget.builderDelegate;

  bool get _shrinkWrapFirstPageIndicators =>
      widget.shrinkWrapFirstPageIndicators;

  PaginationLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  WidgetBuilder get _initialError {
    return _delegate.initialError ??
        (_) => InitialError(onTryAgain: _pagination.retry);
  }

  WidgetBuilder get _ongoingError =>
      _delegate.ongoingError ?? (_) => OngoingError(onTap: _pagination.retry);

  WidgetBuilder get _initialIndicator =>
      _delegate.initialIndicator ?? (_) => const InitialIndicator();

  WidgetBuilder get _ongoingIndicator =>
      _delegate.ongoingIndicator ?? (_) => const OngoingIndicator();

  WidgetBuilder get _nullableError =>
      _delegate.nullableError ?? (_) => const NullableError();

  WidgetBuilder? get _completeBuilder => _delegate.completeBuilder;

  /// Avoids duplicate requests on rebuilds.
  bool _hasNext = false;

  @override
  Widget build(BuildContext context) {
    return PaginationListener(
      listenable: _pagination,
      listener: () {
        final status = _pagination.value.status;
        if (status.isInitial) {
          _pagination.fetch();
        } else if (status.isOngoing) {
          _hasNext = false;
        }
      },
      child: ValueListenableBuilder<PaginationState<T>>(
        valueListenable: _pagination,
        builder: (context, state, _) {
          Widget child;
          switch (state.status) {
            case PaginationStatus.ongoing:
              child = widget.ongoingBuilder(
                context,
                _buildItem,
                _pagination.itemCount,
                _ongoingIndicator,
              );
              break;
            case PaginationStatus.completed:
              child = widget.completeBuilder(
                context,
                _buildItem,
                _pagination.itemCount,
                _completeBuilder,
              );
              break;
            case PaginationStatus.initial:
              child = _InitialBuilder(
                builder: _initialIndicator,
                shrinkWrap: _shrinkWrapFirstPageIndicators,
                layoutProtocol: _layoutProtocol,
              );
              break;
            case PaginationStatus.failure:
              child = widget.errorListingBuilder(
                context,
                _buildItem,
                _pagination.itemCount,
                (context) => _ongoingError(context),
              );
              break;
            case PaginationStatus.nullable:
              child = _InitialBuilder(
                builder: _nullableError,
                shrinkWrap: _shrinkWrapFirstPageIndicators,
                layoutProtocol: _layoutProtocol,
              );
              break;
            default:
              child = _InitialBuilder(
                builder: _initialError,
                shrinkWrap: _shrinkWrapFirstPageIndicators,
                layoutProtocol: _layoutProtocol,
              );
          }

          if (_delegate.animateTransitions) {
            if (_layoutProtocol == PaginationLayoutProtocol.sliver) {
              return SliverAnimatedSwitcher(
                duration: _delegate.transitionDuration,
                child: child,
              );
            } else {
              return AnimatedSwitcher(
                duration: _delegate.transitionDuration,
                child: child,
              );
            }
          } else {
            return child;
          }
        },
      ),
    );
  }

  /// Connects the [_pagination] with the [_delegate] in order to
  /// create a list item widget and request more items if needed.
  Widget _buildItem(BuildContext context, int index) {
    if (!_hasNext) {
      final isTriggerMode = index == _pagination.triggerIndex;
      if (isTriggerMode) {
        _hasNext = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pagination.fetch();
        });
      }
    }
    return _delegate.itemBuilder(context, _pagination.getItem(index), index);
  }
}

class _InitialBuilder extends StatelessWidget {
  const _InitialBuilder({
    required this.builder,
    required this.layoutProtocol,
    this.shrinkWrap = false,
  });

  final WidgetBuilder builder;
  final bool shrinkWrap;
  final PaginationLayoutProtocol layoutProtocol;

  @override
  Widget build(BuildContext context) {
    if (layoutProtocol == PaginationLayoutProtocol.sliver) {
      if (shrinkWrap) {
        return SliverToBoxAdapter(
          child: builder(context),
        );
      } else {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: builder(context),
        );
      }
    } else {
      if (shrinkWrap) {
        return builder(context);
      } else {
        return Center(
          child: builder(context),
        );
      }
    }
  }
}
