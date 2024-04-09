import 'dart:developer';

import 'package:andomie_pagination/pagination.dart';
import 'package:flutter/material.dart';

const kNumbersPagination = "numbers";

void main() {
  // Initialize a Pagination instance
  Pagination.init<String>(
    kNumbersPagination,
    initialSize: 5,
    fetchingSize: 5,
    limit: 1000,
    preload: 1000,
  );
  PaginationController.init<int, String>(kNumbersPagination, initialKey: 1);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pagination',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<PaginationResponse<String>> loadData(PaginationConfig config) {
    return Future.delayed(const Duration(seconds: 2)).then((_) {
      final page = config.snapshotAsPage;
      final fetchingSize = config.fetchingSize;
      final items = List.generate(fetchingSize, (i) {
        final number =
            Pagination.realIndexOf<String>(kNumbersPagination, i) + 1;
        return "Item number is $number";
      });
      return PaginationResponse.value(result: items, snapshot: page + 1);
    });
  }

  late PaginationController<int, String> _paginationController;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await loadData(PaginationConfig(
        initialSize: 10,
        fetchingSize: 10,
        snapshot: pageKey,
      ));
      final isLastPage = newItems.result.length < 10;
      if (isLastPage) {
        _paginationController.appendLast(newItems.result);
      } else {
        final nextPageKey = pageKey + 1;
        _paginationController.append(newItems.result, nextPageKey);
      }
    } catch (error) {
      _paginationController.error = error;
    }
  }

  @override
  void initState() {
    _paginationController = PaginationController.of(kNumbersPagination);
    _paginationController.addRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f1f1),
      appBar: AppBar(
        title: const Text(
          "FLUTTER PAGINATION",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _paginationController.refresh,
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text(
          "Reload",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      body: PaginationListView<int, String>.separated(
        pagingController: _paginationController,
        delegate: PaginationChildDelegate<String>(
          animateTransitions: true,
          itemBuilder: (context, item, index) {
            return NumberItem(item: item);
          },
        ),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();

  Future<PaginationResponse<String>> loadData(PaginationConfig config) {
    return Future.delayed(const Duration(seconds: 2)).then((_) {
      final page = config.snapshotAsPage;
      final fetchingSize = config.fetchingSize;
      final items = List.generate(fetchingSize, (i) {
        final number =
            Pagination.realIndexOf<String>(kNumbersPagination, i) + 1;
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
      kNumbersPagination,
      controller: _scrollController,
      callback: loadData,
      notifier: (data) {
        log('New data loaded: $data');
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f1f1),
      appBar: AppBar(
        title: const Text(
          "FLUTTER PAGINATION",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Pagination.reloadOf<String>(kNumbersPagination),
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text(
          "Reload",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        controller: _scrollController,
        itemCount: Pagination.itemCountOf<String>(kNumbersPagination),
        itemBuilder: (context, index) {
          final item = Pagination.itemOf<String>(kNumbersPagination, index);
          if (item.isPlaceholder) {
            return const NumberItemPlaceholder();
          } else {
            return NumberItem(item: item.data!);
          }
        },
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        item,
        style: const TextStyle(
          color: Colors.black,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}
