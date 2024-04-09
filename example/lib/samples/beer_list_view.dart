import 'package:andomie_pagination/pagination.dart';
import 'package:flutter/material.dart';

import '../remote/beer_summary.dart';
import '../remote/remote_api.dart';
import 'common/beer_list_item.dart';

class BeerListView extends StatefulWidget {
  const BeerListView({super.key});

  @override
  State<BeerListView> createState() => _BeerListViewState();
}

class _BeerListViewState extends State<BeerListView> {
  static const _pageSize = 20;

  final PaginationController<int, BeerSummary> _pagingController =
      PaginationController(initialKey: 1);

  @override
  void initState() {
    _pagingController.addRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await RemoteApi.getBeerList(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLast(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.append(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: PaginationListView<int, BeerSummary>.separated(
        pagingController: _pagingController,
        delegate: PaginationChildDelegate<BeerSummary>(
          animateTransitions: true,
          itemBuilder: (context, item, index) => BeerListItem(beer: item),
        ),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
