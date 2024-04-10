import 'package:andomie_pagination/pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../item.dart';

const _kPaginationKey = "PageViewExample";

class PageViewExample extends StatefulWidget {
  const PageViewExample({super.key});

  @override
  State<PageViewExample> createState() => _PageViewExampleState();
}

class _PageViewExampleState extends State<PageViewExample> {
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
    Pagination.init<Item>(_kPaginationKey).callback(
      callback: _load,
      notifier: (value) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaginationPageView<Item>(
      pagination: Pagination.of(_kPaginationKey),
      builderDelegate: PaginationBuilderDelegate<Item>(
        itemBuilder: (context, item, index) {
          if (item.isPlaceholder) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: const Center(
                child: Text(
                  "LOADING...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          } else {
            return CachedNetworkImage(
              imageUrl: item.data!.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    Pagination.disposeOf(_kPaginationKey);
    super.dispose();
  }
}
