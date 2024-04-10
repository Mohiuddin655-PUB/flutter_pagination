import 'package:andomie_pagination/pagination.dart';
import 'package:example/example.dart';
import 'package:flutter/material.dart';

import 'samples/custom.dart';

void main() {
  // Initialize a Pagination instance
  Pagination.init<String>(
    kCustomKey,
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
      title: 'ANDOMIE Pagination',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Examples(),
    );
  }
}
