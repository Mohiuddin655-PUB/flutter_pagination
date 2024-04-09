import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../core/child_builder_delegate.dart';
import '../../core/controller.dart';
import '../../model/state.dart';
import '../../model/status.dart';
import '../../utils/listenable_listener.dart';
import 'default_status_indicators/first_page_error_indicator.dart';
import 'default_status_indicators/first_page_progress_indicator.dart';
import 'default_status_indicators/new_page_error_indicator.dart';
import 'default_status_indicators/new_page_progress_indicator.dart';
import 'default_status_indicators/no_items_found_indicator.dart';

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
/// [PaginationChildDelegate] and calls the supplied
/// [loadingListingBuilder], [errorListingBuilder] or
/// [completedListingBuilder] for filling in the gaps.
///
/// For ordinary cases, this widget shouldn't be used directly. Instead, take a
/// look at [PagedSliverList], [PagedSliverGrid], [PagedListView],
/// [PagedGridView], [PagedMasonryGridView], or [PagedPageView].
class PaginationLayoutBuilder<K, E> extends StatefulWidget {
  const PaginationLayoutBuilder({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    required this.loadingListingBuilder,
    required this.errorListingBuilder,
    required this.completedListingBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
  });

  /// The controller for paged listings.
  ///
  /// Informs the current state of the pagination and requests new items from
  /// its listeners.
  final PaginationController<K, E> pagingController;

  /// The delegate for building the UI pieces of scrolling paged listings.
  final PaginationChildDelegate<E> builderDelegate;

  /// The builder for an in-progress listing.
  final LoadingListingBuilder loadingListingBuilder;

  /// The builder for an in-progress listing with a failed request.
  final ErrorListingBuilder errorListingBuilder;

  /// The builder for a completed listing.
  final CompletedListingBuilder completedListingBuilder;

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
  /// [loadingListingBuilder], [errorListingBuilder], and
  /// [completedListingBuilder] have to return a Sliver widget.
  final PaginationLayoutProtocol layoutProtocol;

  @override
  State<PaginationLayoutBuilder<K, E>> createState() {
    return _PaginationLayoutBuilderState<K, E>();
  }
}

class _PaginationLayoutBuilderState<K, E>
    extends State<PaginationLayoutBuilder<K, E>> {
  PaginationController<K, E> get _controller => widget.pagingController;

  PaginationChildDelegate<E> get _builderDelegate =>
      widget.builderDelegate;

  bool get _shrinkWrapFirstPageIndicators =>
      widget.shrinkWrapFirstPageIndicators;

  PaginationLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  WidgetBuilder get _firstPageErrorIndicatorBuilder =>
      _builderDelegate.firstPageErrorIndicatorBuilder ??
      (_) => FirstPageErrorIndicator(
            onTryAgain: _controller.retryLastFailedRequest,
          );

  WidgetBuilder get _newPageErrorIndicatorBuilder =>
      _builderDelegate.newPageErrorIndicatorBuilder ??
      (_) => NewPageErrorIndicator(
            onTap: _controller.retryLastFailedRequest,
          );

  WidgetBuilder get _firstPageProgressIndicatorBuilder =>
      _builderDelegate.firstPageProgressIndicatorBuilder ??
      (_) => FirstPageProgressIndicator();

  WidgetBuilder get _newPageProgressIndicatorBuilder =>
      _builderDelegate.newPageProgressIndicatorBuilder ??
      (_) => const NewPageProgressIndicator();

  WidgetBuilder get _noItemsFoundIndicatorBuilder =>
      _builderDelegate.noItemsFoundIndicatorBuilder ??
      (_) => const NoItemsFoundIndicator();

  WidgetBuilder? get _noMoreItemsIndicatorBuilder =>
      _builderDelegate.noMoreItemsIndicatorBuilder;

  int get _invisibleItemsThreshold => _controller.invisibleItemsThreshold ?? 3;

  int get _itemCount => _controller.itemCount;

  bool get _hasNextPage => _controller.hasNextPage;

  K? get _nextKey => _controller.nextKey;

  /// Avoids duplicate requests on rebuilds.
  bool _hasRequestedNextPage = false;

  @override
  Widget build(BuildContext context) {
    return PaginationListener(
      listenable: _controller,
      listener: () {
        final status = _controller.value.status;

        if (status == PaginationStatus.loadingFirstPage) {
          _controller.notifyPageRequestListeners(
            _controller.initialKey,
          );
        }

        if (status == PaginationStatus.ongoing) {
          _hasRequestedNextPage = false;
        }
      },
      child: ValueListenableBuilder<PaginationState<K, E>>(
        valueListenable: _controller,
        builder: (context, pagingState, _) {
          Widget child;
          final items = _controller.items;
          switch (pagingState.status) {
            case PaginationStatus.ongoing:
              child = widget.loadingListingBuilder(
                context,
                // We must create this closure to close over the [items]
                // value. That way, we are safe if [items] value changes
                // while Flutter rebuilds the widget (due to animations, for
                // example.)
                (c, i) => _buildListItemWidget(c, i, items!),
                _itemCount,
                _newPageProgressIndicatorBuilder,
              );
              break;
            case PaginationStatus.completed:
              child = widget.completedListingBuilder(
                context,
                (c, i) => _buildListItemWidget(c, i, items!),
                _itemCount,
                _noMoreItemsIndicatorBuilder,
              );
              break;
            case PaginationStatus.loadingFirstPage:
              child = _FirstPageStatusIndicatorBuilder(
                builder: _firstPageProgressIndicatorBuilder,
                shrinkWrap: _shrinkWrapFirstPageIndicators,
                layoutProtocol: _layoutProtocol,
              );
              break;
            case PaginationStatus.subsequentPageError:
              child = widget.errorListingBuilder(
                context,
                (c, i) => _buildListItemWidget(c, i, items!),
                _itemCount,
                (context) => _newPageErrorIndicatorBuilder(context),
              );
              break;
            case PaginationStatus.noItemsFound:
              child = _FirstPageStatusIndicatorBuilder(
                builder: _noItemsFoundIndicatorBuilder,
                shrinkWrap: _shrinkWrapFirstPageIndicators,
                layoutProtocol: _layoutProtocol,
              );
              break;
            default:
              child = _FirstPageStatusIndicatorBuilder(
                builder: _firstPageErrorIndicatorBuilder,
                shrinkWrap: _shrinkWrapFirstPageIndicators,
                layoutProtocol: _layoutProtocol,
              );
          }

          if (_builderDelegate.animateTransitions) {
            if (_layoutProtocol == PaginationLayoutProtocol.sliver) {
              return SliverAnimatedSwitcher(
                duration: _builderDelegate.transitionDuration,
                child: child,
              );
            } else {
              return AnimatedSwitcher(
                duration: _builderDelegate.transitionDuration,
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

  /// Connects the [_controller] with the [_builderDelegate] in order to
  /// create a list item widget and request more items if needed.
  Widget _buildListItemWidget(BuildContext context, int index, List<E> items) {
    if (!_hasRequestedNextPage) {
      final newPageRequestTriggerIndex =
          max(0, _itemCount - _invisibleItemsThreshold);

      final isBuildingTriggerIndexItem = index == newPageRequestTriggerIndex;

      if (_hasNextPage && isBuildingTriggerIndexItem) {
        // Schedules the request for the end of this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.notifyPageRequestListeners(_nextKey as K);
        });
        _hasRequestedNextPage = true;
      }
    }

    final item = items[index];
    return _builderDelegate.itemBuilder(context, item, index);
  }
}

extension on PaginationController {
  /// The loaded items count.
  int get itemCount => items?.length ?? 0;

  /// Tells whether there's a next page to request.
  bool get hasNextPage => nextKey != null;
}

class _FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const _FirstPageStatusIndicatorBuilder({
    required this.builder,
    required this.layoutProtocol,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key);

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
