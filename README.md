The Pagination class provides functionality for managing pagination state and data retrieval in
Flutter apps. It allows for easy loading of data in chunks, handling of scroll events, and notifying
when new data is available. With features like preloading and error handling, it simplifies the
implementation of paginated lists or grids.

## Features

- Paginate by scrolling

## Usage

### Short Example:

```dart
import 'package:andomie_pagination/pagination.dart';

void main() {
  final pagination = Pagination<int>.init('example');
  pagination.paginate(
    controller: ScrollController(),
    callback: (config) async {
      // Your data fetching logic here
      return PaginationResponse.value(result: [1, 2, 3], snapshot: 1);
    },
    notifier: (value) {
      // Handle the fetched data
      print(value);
    },
  );
}
```

### Longer Example:

```dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:andomie_pagination/pagination.dart';

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
      home: const MyHomePage(),
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
        backgroundColor: Theme
            .of(context)
            .primaryColor,
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
```

## Preview

- ![Record_2024-03-16-02-19-58-ezgif com-video-to-gif-converter](https://github.com/Mohiuddin655-PUB/flutter_pagination/assets/71176567/1f9db897-5a52-4cc1-98e0-ed57896acb68)

