import 'package:andomie_pagination/pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../remote/beer_summary.dart';
import '../remote/remote_api.dart';

class BeerPageView extends StatefulWidget {
  const BeerPageView({super.key});

  @override
  State<BeerPageView> createState() => _BeerPageViewState();
}

class _BeerPageViewState extends State<BeerPageView> {
  static const _pageSize = 20;

  final PaginationController<int, BeerSummary> _pagingController = PaginationController(
    initialKey: 1,
  );

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
    return PaginationPageView<int, BeerSummary>(
      pagingController: _pagingController,
      builderDelegate: PaginationChildDelegate<BeerSummary>(
        itemBuilder: (context, item, index) => CachedNetworkImage(
          imageUrl: item.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
