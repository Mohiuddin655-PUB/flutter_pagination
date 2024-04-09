import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../core/child_builder_delegate.dart';
import '../../core/controller.dart';
import 'sliver_grid.dart';

/// A [GridView] with pagination capabilities.
///
/// Wraps a [PaginationSliverGrid] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [GridView].
class PaginationGridView<K, E> extends BoxScrollView {
  const PaginationGridView({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegate,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    // Matches [ScrollView.scrollDirection].
    Axis scrollDirection = Axis.vertical,
    // Matches [ScrollView.reverse].
    bool reverse = false,
    // Matches [ScrollView.primary].
    bool? primary,
    // Matches [ScrollView.physics].
    ScrollPhysics? physics,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    // Matches [BoxScrollView.padding].
    EdgeInsetsGeometry? padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent].
    double? cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Matches [ScrollView.keyboardDismissBehavior].
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Matches [ScrollView.restorationId].
    String? restorationId,
    // Matches [ScrollView.clipBehavior].
    Clip clipBehavior = Clip.hardEdge,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
        );

  /// Matches [PagedLayoutBuilder.pagingController].
  final PaginationController<K, E> pagingController;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PaginationChildDelegate<E> builderDelegate;

  /// Matches [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PaginationSliverGrid.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Matches [PaginationSliverGrid.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Matches [PaginationSliverGrid.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PaginationSliverGrid.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  @override
  Widget buildChildLayout(BuildContext context) {
    return PaginationSliverGrid<K, E>(
      builderDelegate: builderDelegate,
      pagingController: pagingController,
      gridDelegate: gridDelegate,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      showNewPageProgressIndicatorAsGridChild:
          showNewPageProgressIndicatorAsGridChild,
      showNewPageErrorIndicatorAsGridChild:
          showNewPageErrorIndicatorAsGridChild,
      showNoMoreItemsIndicatorAsGridChild: showNoMoreItemsIndicatorAsGridChild,
      shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
    );
  }
}
