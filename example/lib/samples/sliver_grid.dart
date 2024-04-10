import 'dart:async';

import 'package:andomie_pagination/pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../item.dart';

const _kPaginationKey = "SliverGridExample";

class SliverGridExample extends StatefulWidget {
  const SliverGridExample({super.key});

  @override
  State<SliverGridExample> createState() => _SliverGridExampleState();
}

class _SliverGridExampleState extends State<SliverGridExample> {
  Future<PaginationResponse<Item>> _load(PaginationConfig config) {
    return Future.delayed(const Duration(seconds: 5)).then((_) {
      final page = config.snapshotAsPage;
      final fetchingSize = config.fetchingSize;
      final items = List.generate(fetchingSize, (i) {
        final number = Pagination.realIndexOf<Item>(_kPaginationKey, i) + 1;
        return Item(
          name: "Item number is $number",
          image: i % 2 == 0
              ? "https://images.freeimages.com/365/images/previews/a7b/jumper-mockup-psd-56444.jpg?fmt=webp&w=500"
              : i % 3 == 0
                  ? "https://images.freeimages.com/variants/h5x75mMzcK26DrsoLKqg3AEi/f4a36f6589a0e50e702740b15352bc00e4bfaf6f58bd4db850e167794d05993d?fmt=webp&w=500"
                  : "https://images.freeimages.com/images/large-previews/aed/three-bees-on-sunflower-1337029.jpg?fmt=webp&w=500",
        );
      });
      return PaginationResponse.value(result: items, snapshot: page + 1);
    });
  }

  @override
  void initState() {
    super.initState();
    Pagination.init<Item>(
      _kPaginationKey,
      initialSize: 5,
      fetchingSize: 5,
    ).callback(
      callback: _load,
      notifier: (value) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => Pagination.reloadOf<Item>(_kPaginationKey),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              alignment: Alignment.center,
              child: const Text(
                "THIS IS SLIVER GRID",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: PaginationSliverGrid<Item>(
              pagination: Pagination.of(_kPaginationKey),
              builderDelegate: PaginationBuilderDelegate(
                animateTransitions: true,
                itemBuilder: (context, item, index) {
                  if (item.isPlaceholder) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: const Center(
                        child: Text(
                          "LOADING...",
                          style: TextStyle(
                            color: Colors.black26,
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: item.data!.image,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                },
                ongoingIndicator: (_) => const SizedBox(),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                crossAxisCount: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Pagination.disposeOf<Item>(_kPaginationKey);
    super.dispose();
  }
}
