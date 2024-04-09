import 'package:andomie_pagination/pagination.dart';
import 'package:flutter/material.dart';

import '../remote/beer_summary.dart';
import '../remote/remote_api.dart';
import 'common/beer_list_item.dart';
import 'common/beer_search_input_sliver.dart';

class BeerSliverList extends StatefulWidget {
  const BeerSliverList({super.key});

  @override
  State<BeerSliverList> createState() => _BeerSliverListState();
}

class _BeerSliverListState extends State<BeerSliverList> {
  static const _pageSize = 17;

  final PaginationController<int, BeerSummary> _pagingController =
      PaginationController(initialKey: 1);

  String? _searchTerm;

  @override
  void initState() {
    _pagingController.addRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _pagingController.addStatusListener((status) {
      if (status == PaginationStatus.subsequentPageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Something went wrong while fetching a new page.',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _pagingController.retryLastFailedRequest(),
            ),
          ),
        );
      }
    });

    super.initState();
  }

  Future<void> _fetchPage(pageKey) async {
    try {
      final newItems = await RemoteApi.getBeerList(
        pageKey,
        _pageSize,
        searchTerm: _searchTerm,
      );

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
    return CustomScrollView(
      slivers: <Widget>[
        BeerSearchInputSliver(
          onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
        ),
        PaginationSliverList<int, BeerSummary>(
          pagingController: _pagingController,
          builderDelegate: PaginationChildDelegate<BeerSummary>(
            animateTransitions: true,
            itemBuilder: (context, item, index) => BeerListItem(
              beer: item,
            ),
          ),
        ),
      ],
    );
  }

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
