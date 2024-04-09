import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../core/child_builder_delegate.dart';
import '../../core/controller.dart';
import '../../utils/sliver_child_delegate.dart';
import '../helpers/layout_builder.dart';

/// A [SliverList] with pagination capabilities.
///
/// To include separators, use [PagedSliverList.separated].
///
/// Similar to [PagedListView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged list.
class PaginationSliverList<K, E> extends StatelessWidget {
  const PaginationSliverList({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.semanticIndexCallback,
    this.shrinkWrapFirstPageIndicators = false,
  })  : assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both',
        ),
        _separatorBuilder = null;

  const PaginationSliverList.separated({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    required IndexedWidgetBuilder separatorBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.semanticIndexCallback,
    this.shrinkWrapFirstPageIndicators = false,
  })  : prototypeItem = null,
        _separatorBuilder = separatorBuilder;

  /// Matches [PaginationLayoutBuilder.pagingController].
  final PaginationController<K, E> pagingController;

  /// Matches [PaginationLayoutBuilder.builderDelegate].
  final PaginationChildDelegate<E> builderDelegate;

  /// The builder for list item separators, just like in [ListView.separated].
  final IndexedWidgetBuilder? _separatorBuilder;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [SliverChildBuilderDelegate.semanticIndexCallback].
  final SemanticIndexCallback? semanticIndexCallback;

  /// Matches [SliverFixedExtentList.itemExtent].
  ///
  /// If this is not null, [prototypeItem] must be null, and vice versa.
  final double? itemExtent;

  /// Matches [SliverPrototypeExtentList.prototypeItem].
  ///
  /// If this is not null, [itemExtent] must be null, and vice versa.
  final Widget? prototypeItem;

  /// Matches [PaginationLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) {
    return PaginationLayoutBuilder<K, E>(
      layoutProtocol: PaginationLayoutProtocol.sliver,
      pagingController: pagingController,
      builderDelegate: builderDelegate,
      shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      completedListingBuilder: _buildSliverList,
      loadingListingBuilder: _buildSliverList,
      errorListingBuilder: _buildSliverList,
    );
  }

  SliverMultiBoxAdaptorWidget _buildSliverList(
    BuildContext context,
    IndexedWidgetBuilder itemBuilder,
    int itemCount,
    WidgetBuilder? statusIndicatorBuilder,
  ) {
    final delegate = _separatorBuilder == null
        ? PaginationSliverChildDelegate(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: statusIndicatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            semanticIndexCallback: semanticIndexCallback,
          )
        : PaginationSliverChildDelegate.separated(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: statusIndicatorBuilder,
            separatorBuilder: _separatorBuilder!,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          );

    final itemExtent = this.itemExtent;
    return ((itemExtent == null && prototypeItem == null) ||
            _separatorBuilder != null)
        ? SliverList(delegate: delegate)
        : (itemExtent != null)
            ? SliverFixedExtentList(delegate: delegate, itemExtent: itemExtent)
            : SliverPrototypeExtentList(
                delegate: delegate,
                prototypeItem: prototypeItem!,
              );
  }
}
