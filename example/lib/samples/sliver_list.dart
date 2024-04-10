import 'dart:async';

import 'package:andomie_pagination/pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../item.dart';

const _kPaginationKey = "SliverListExample";

class SliverListExample extends StatefulWidget {
  const SliverListExample({super.key});

  @override
  State<SliverListExample> createState() => _SliverListExampleState();
}

class _SliverListExampleState extends State<SliverListExample> {
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
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            alignment: Alignment.center,
            child: const Text(
              "THIS IS SLIVER LIST",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        PaginationSliverList<Item>.separated(
          pagination: Pagination.of<Item>(_kPaginationKey),
          builderDelegate: PaginationBuilderDelegate<Item>(
            animateTransitions: true,
            itemBuilder: (context, item, index) {
              if (item.isPlaceholder) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "LOADING...",
                    style: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                    ),
                  ),
                );
              } else {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                        item.data!.image,
                      ),
                    ),
                    title: Text(item.data!.name),
                  ),
                );
              }
            },
            ongoingIndicator: (_) => const SizedBox(),
          ),
          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    Pagination.disposeOf<Item>(_kPaginationKey);
    super.dispose();
  }
}
