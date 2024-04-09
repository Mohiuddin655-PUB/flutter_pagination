import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/child_builder_delegate.dart';
import '../../core/controller.dart';
import '../../utils/sliver_child_delegate.dart';
import '../helpers/layout_builder.dart';

typedef SliverSimpleGridDelegateBuilder = SliverSimpleGridDelegate Function(
  int childCount,
);

/// A [MasonryGridView] with pagination capabilities.
///
/// You can also see this as a [PagedGridView] that supports rows of varying
/// sizes.
///
/// This is a wrapper around the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)
/// package. For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PaginationMasonryGridView<K, E> extends StatelessWidget {
  const PaginationMasonryGridView({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.padding,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  }) : _shrinkWrapFirstPageIndicators = shrinkWrap;

  /// Equivalent to [MasonryGridView.count].
  PaginationMasonryGridView.count({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    required int crossAxisCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.padding,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder = ((childCount) {
          return SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          );
        });

  /// Equivalent to [MasonryGridView.extent].
  PaginationMasonryGridView.extent({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.padding,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    // Matches [ScrollView.shrinkWrap].
    bool shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder = ((childCount) {
          return SliverSimpleGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
          );
        });

  /// Matches [PaginationLayoutBuilder.pagingController].
  final PaginationController<K, E> pagingController;

  /// Matches [PaginationLayoutBuilder.builderDelegate].
  final PaginationChildDelegate<E> builderDelegate;

  /// Provides the adjusted child count (based on the pagination status) so
  /// that a [SliverSimpleGridDelegate] can be returned.
  final SliverSimpleGridDelegateBuilder gridDelegateBuilder;

  /// Matches [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// Matches [ScrollView.reverse]
  final bool reverse;

  /// Matches [ScrollView.controller]
  final ScrollController? scrollController;

  /// Matches [ScrollView.primary].
  final bool? primary;

  /// Matches [ScrollView.physics].
  final ScrollPhysics? physics;

  /// Matches [BoxScrollView.padding].
  final EdgeInsetsGeometry? padding;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  /// Matches [ScrollView.cacheExtent].
  final double? cacheExtent;

  /// Matches [ScrollView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// Matches [ScrollView.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Matches [ScrollView.restorationId].
  final String? restorationId;

  /// Matches [ScrollView.clipBehavior].
  final Clip clipBehavior;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PagedSliverGrid.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) {
    return PaginationLayoutBuilder<K, E>(
      layoutProtocol: PaginationLayoutProtocol.box,
      pagingController: pagingController,
      builderDelegate: builderDelegate,
      shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
      completedListingBuilder: (_, itemBuilder, itemCount, indicatorBuilder) {
        return MasonryGridView.custom(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          gridDelegate: gridDelegateBuilder(
            itemCount + (indicatorBuilder == null ? 0 : 1),
          ),
          childrenDelegate: PaginationSliverChildDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: indicatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        );
      },
      loadingListingBuilder: (_, itemBuilder, itemCount, indicatorBuilder) {
        return MasonryGridView.custom(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          gridDelegate: gridDelegateBuilder(
            itemCount + 1,
          ),
          childrenDelegate: PaginationSliverChildDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: indicatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        );
      },
      errorListingBuilder: (_, itemBuilder, itemCount, indicatorBuilder) {
        return MasonryGridView.custom(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          primary: primary,
          physics: physics,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          cacheExtent: cacheExtent,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          gridDelegate: gridDelegateBuilder(
            itemCount + 1,
          ),
          childrenDelegate: PaginationSliverChildDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: indicatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          ),
        );
      },
    );
  }
}
