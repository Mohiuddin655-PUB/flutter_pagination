import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../core/child_builder_delegate.dart';
import '../../core/controller.dart';
import 'sliver_list.dart';

/// A [ListView] with pagination capabilities.
///
/// To include separators, use [PagedListView.separated].
///
/// Wraps a [PaginationSliverList] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [ListView].
class PaginationListView<K, E> extends BoxScrollView {
  const PaginationListView({
    super.key,
    required this.pagingController,
    required this.delegate,
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
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent]
    double? cacheExtent,
    // Matches [ScrollView.dragStartBehavior]
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Matches [ScrollView.keyboardDismissBehavior]
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Matches [ScrollView.restorationId]
    String? restorationId,
    // Matches [ScrollView.clipBehavior]
    Clip clipBehavior = Clip.hardEdge,
  })  : assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both',
        ),
        _separatorBuilder = null,
        _shrinkWrapFirstPageIndicators = shrinkWrap,
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

  const PaginationListView.separated({
    super.key,
    required this.pagingController,
    required this.delegate,
    required IndexedWidgetBuilder separatorBuilder,
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
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    // Matches [ScrollView.cacheExtent]
    double? cacheExtent,
    // Matches [ScrollView.dragStartBehavior]
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    // Matches [ScrollView.keyboardDismissBehavior]
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    // Matches [ScrollView.restorationId]
    String? restorationId,
    // Matches [ScrollView.clipBehavior]
    Clip clipBehavior = Clip.hardEdge,
  })  : prototypeItem = null,
        _shrinkWrapFirstPageIndicators = shrinkWrap,
        _separatorBuilder = separatorBuilder,
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
  final PaginationChildDelegate<E> delegate;

  /// The builder for list item separators, just like in [ListView.separated].
  final IndexedWidgetBuilder? _separatorBuilder;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [SliverFixedExtentList.itemExtent].
  ///
  /// If this is not null, [prototypeItem] must be null, and vice versa.
  final double? itemExtent;

  /// Matches [SliverPrototypeExtentList.prototypeItem].
  ///
  /// If this is not null, [itemExtent] must be null, and vice versa.
  final Widget? prototypeItem;

  /// Matches [PaginationSliverList.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  @override
  Widget buildChildLayout(BuildContext context) {
    final separatorBuilder = _separatorBuilder;
    return separatorBuilder != null
        ? PaginationSliverList<K, E>.separated(
            builderDelegate: delegate,
            pagingController: pagingController,
            separatorBuilder: separatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            itemExtent: itemExtent,
            shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
          )
        : PaginationSliverList<K, E>(
            builderDelegate: delegate,
            pagingController: pagingController,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            itemExtent: itemExtent,
            shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
            prototypeItem: prototypeItem,
          );
  }
}
