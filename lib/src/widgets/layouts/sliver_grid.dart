import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../core/child_builder_delegate.dart';
import '../../core/controller.dart';
import '../../utils/sliver_child_delegate.dart';
import '../helpers/layout_builder.dart';

typedef SliverGridBuilder = SliverWithKeepAliveWidget Function(
  int childCount,
  SliverChildDelegate delegate,
);

/// Paged [SliverGrid] with progress and error indicators displayed as the last
/// item.
///
/// Similar to [PagedGridView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged grid.
class PaginationSliverGrid<K, E> extends StatelessWidget {
  const PaginationSliverGrid({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
  });

  /// Matches [PaginationLayoutBuilder.pagingController].
  final PaginationController<K, E> pagingController;

  /// Matches [PaginationLayoutBuilder.builderDelegate].
  final PaginationChildDelegate<E> builderDelegate;

  /// Matches [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Whether the new page progress indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Whether the new page error indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Whether the no more items indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PaginationLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  @override
  Widget build(BuildContext context) {
    return PaginationLayoutBuilder<K, E>(
      layoutProtocol: PaginationLayoutProtocol.sliver,
      pagingController: pagingController,
      builderDelegate: builderDelegate,
      completedListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        noMoreItemsIndicatorBuilder,
      ) {
        return _AppendedSliverGrid(
          sliverGridBuilder: (_, delegate) => SliverGrid(
            delegate: delegate,
            gridDelegate: gridDelegate,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: noMoreItemsIndicatorBuilder,
          showAppendixAsGridChild: showNoMoreItemsIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
        );
      },
      loadingListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        progressIndicatorBuilder,
      ) {
        return _AppendedSliverGrid(
          sliverGridBuilder: (_, delegate) => SliverGrid(
            delegate: delegate,
            gridDelegate: gridDelegate,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: progressIndicatorBuilder,
          showAppendixAsGridChild: showNewPageProgressIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
        );
      },
      errorListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        errorIndicatorBuilder,
      ) {
        return _AppendedSliverGrid(
          sliverGridBuilder: (_, delegate) => SliverGrid(
            delegate: delegate,
            gridDelegate: gridDelegate,
          ),
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          appendixBuilder: errorIndicatorBuilder,
          showAppendixAsGridChild: showNewPageErrorIndicatorAsGridChild,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
        );
      },
      shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
    );
  }
}

class _AppendedSliverGrid extends StatelessWidget {
  const _AppendedSliverGrid({
    required this.itemBuilder,
    required this.itemCount,
    required this.sliverGridBuilder,
    this.showAppendixAsGridChild = true,
    this.appendixBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    Key? key,
  }) : super(key: key);

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final SliverGridBuilder sliverGridBuilder;
  final bool showAppendixAsGridChild;
  final WidgetBuilder? appendixBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  @override
  Widget build(BuildContext context) {
    final appendixBuilder = this.appendixBuilder;

    if (showAppendixAsGridChild == true || appendixBuilder == null) {
      return sliverGridBuilder(
        itemCount + (appendixBuilder == null ? 0 : 1),
        _buildSliverDelegate(
          appendixBuilder: appendixBuilder,
        ),
      );
    } else {
      return MultiSliver(
        children: [
          sliverGridBuilder(
            itemCount,
            _buildSliverDelegate(),
          ),
          SliverToBoxAdapter(
            child: appendixBuilder(context),
          ),
        ],
      );
    }
  }

  SliverChildBuilderDelegate _buildSliverDelegate({
    WidgetBuilder? appendixBuilder,
  }) =>
      PaginationSliverChildDelegate(
        builder: itemBuilder,
        childCount: itemCount,
        appendixBuilder: appendixBuilder,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
}
