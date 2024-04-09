import 'dart:async';

import 'package:andomie_pagination/pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../remote/beer_summary.dart';
import 'common/beer_listing_bloc.dart';
import 'common/beer_search_input_sliver.dart';

class BeerSliverGrid extends StatefulWidget {
  const BeerSliverGrid({super.key});

  @override
  State<BeerSliverGrid> createState() => _BeerSliverGridState();
}

class _BeerSliverGridState extends State<BeerSliverGrid> {
  final BeerListingBloc _bloc = BeerListingBloc();
  final PaginationController<int, BeerSummary> _pagingController =
      PaginationController(initialKey: 1);
  late StreamSubscription _blocListingStateSubscription;

  @override
  void initState() {
    _pagingController.addRequestListener((pageKey) {
      _bloc.onPageRequestSink.add(pageKey);
    });

    // We could've used StreamBuilder, but that would unnecessarily recreate
    // the entire [PagedSliverGrid] every time the state changes.
    // Instead, handling the subscription ourselves and updating only the
    // _pagingController is more efficient.
    _blocListingStateSubscription =
        _bloc.onNewListingState.listen((listingState) {
      _pagingController.value = PaginationState(
        key: listingState.nextPageKey,
        error: listingState.error,
        items: listingState.itemList,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        BeerSearchInputSliver(
          onChanged: (searchTerm) => _bloc.onSearchInputChangedSink.add(
            searchTerm,
          ),
        ),
        PaginationSliverGrid<int, BeerSummary>(
          pagingController: _pagingController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 100 / 150,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
          ),
          builderDelegate: PaginationChildDelegate<BeerSummary>(
            itemBuilder: (context, item, index) => CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _blocListingStateSubscription.cancel();
    _bloc.dispose();
    super.dispose();
  }
}
