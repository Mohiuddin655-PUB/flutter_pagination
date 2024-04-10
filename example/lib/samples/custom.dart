import 'package:andomie_pagination/pagination.dart';
import 'package:flutter/material.dart';

const kCustomKey = "CustomExample";

class CustomExample extends StatefulWidget {
  const CustomExample({super.key});

  @override
  State<CustomExample> createState() => _CustomExampleState();
}

class _CustomExampleState extends State<CustomExample> {
  final _scrollController = ScrollController();

  Future<PaginationResponse<String>> loadData(PaginationConfig config) {
    return Future.delayed(const Duration(seconds: 2)).then((_) {
      final page = config.snapshotAsPage;
      final fetchingSize = config.fetchingSize;
      final items = List.generate(fetchingSize, (i) {
        final number = Pagination.realIndexOf<String>(kCustomKey, i) + 1;
        return "Item number is $number";
      });
      return PaginationResponse.value(result: items, snapshot: page + 1);
    });
  }

  @override
  void initState() {
    super.initState();
    // Apply pagination to a ScrollController
    Pagination.apply<String>(
      kCustomKey,
      controller: _scrollController,
      callback: loadData,
      notifier: (data) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      controller: _scrollController,
      itemCount: Pagination.itemCountOf<String>(kCustomKey),
      itemBuilder: (context, index) {
        final item = Pagination.itemOf<String>(kCustomKey, index);
        if (item.isPlaceholder) {
          return const NumberItemPlaceholder();
        } else {
          return NumberItem(item: item.data!);
        }
      },
    );
  }
}

class NumberItem extends StatelessWidget {
  final String item;

  const NumberItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        item,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}

class NumberItemPlaceholder extends StatelessWidget {
  const NumberItemPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}
