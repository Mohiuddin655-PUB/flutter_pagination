import 'package:example/samples/custom.dart';
import 'package:flutter/material.dart';

import 'samples/grid_view.dart';
import 'samples/list_view.dart';
import 'samples/masonry_grid.dart';
import 'samples/page_view.dart';
import 'samples/sliver_grid.dart';
import 'samples/sliver_list.dart';

class Examples extends StatefulWidget {
  const Examples({super.key});

  @override
  State<Examples> createState() => _ExamplesState();
}

class _ExamplesState extends State<Examples> {
  int _selectedBottomNavigationIndex = 0;

  final List<_BottomNavigationItem> _bottomNavigationItems = [
    _BottomNavigationItem(
      label: 'List',
      iconData: Icons.list,
      widgetBuilder: (context) => const ListViewExample(),
    ),
    _BottomNavigationItem(
      label: 'Sliver List',
      iconData: Icons.list,
      widgetBuilder: (context) => const SliverListExample(),
    ),
    _BottomNavigationItem(
      label: 'Grid',
      iconData: Icons.grid_on,
      widgetBuilder: (context) => const GridViewExample(),
    ),
    _BottomNavigationItem(
      label: 'Grid',
      iconData: Icons.grid_on,
      widgetBuilder: (context) => const SliverGridExample(),
    ),
    _BottomNavigationItem(
      label: 'Masonry',
      iconData: Icons.view_quilt,
      widgetBuilder: (context) => const MasonryGridExample(),
    ),
    _BottomNavigationItem(
      label: 'Page',
      iconData: Icons.fullscreen,
      widgetBuilder: (context) => const PageViewExample(),
    ),
    _BottomNavigationItem(
      label: 'Custom',
      iconData: Icons.add_circle_outline,
      widgetBuilder: (context) => const CustomExample(),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('ANDOMIE PAGINATION'),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedBottomNavigationIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: _bottomNavigationItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.iconData),
                  label: item.label,
                ),
              )
              .toList(),
          onTap: (newIndex) => setState(
            () => _selectedBottomNavigationIndex = newIndex,
          ),
        ),
        body: IndexedStack(
          index: _selectedBottomNavigationIndex,
          children: _bottomNavigationItems
              .map(
                (item) => item.widgetBuilder(context),
              )
              .toList(),
        ),
      );
}

class _BottomNavigationItem {
  const _BottomNavigationItem({
    required this.label,
    required this.iconData,
    required this.widgetBuilder,
  });

  final String label;
  final IconData iconData;
  final WidgetBuilder widgetBuilder;
}
