import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_entity/flutter_entity.dart';

part 'config.dart';
part 'data.dart';
part 'extensions.dart';
part 'helper.dart';
part 'response.dart';
part 'typedefs.dart';

/// Manages pagination state and data retrieval.
class Pagination<T extends Object> {
  /// Number of items to fetch each time.
  final int fetchingSize;

  /// Maximum number of items to load.
  final int? _limit;

  /// Distance to preload more data.
  final double preload;

  /// Initial size of the pagination.
  final int? _initialSize;

  /// Initial state flag.
  bool _initial = true;

  /// Loading state flag.
  bool _loading = false;

  /// Finish state flag.
  bool _finish = false;

  /// Current snapshot of the pagination state.
  Object? _snapshot;

  /// List of items currently loaded.
  List<T> _items = [];

  /// Scroll controller used for pagination.
  ScrollController? _controller;

  /// Callback function to load more data.
  OnPaginationCallback<T>? _callback;

  /// Callback function to notify when new data is loaded.
  OnPaginationNotifier<T>? _notifier;

  /// Constructs a Pagination instance with the provided settings.
  ///
  /// [fetchingSize]: Number of items to fetch each time, defaults to 10.
  /// [preload]: Distance to preload more data, defaults to 1000.
  /// [limit]: Maximum number of items to load, defaults to null (unlimited).
  Pagination({
    this.fetchingSize = 10,
    this.preload = 1000,
    int? limit,
    int? initialSize,
  })  : _initialSize = initialSize,
        _limit = limit;

  static final _proxies = <String, Pagination>{};

  /// Retrieves a Pagination instance by name.
  ///
  /// Throws an UnimplementedError if the Pagination instance isn't initialized.
  static Pagination<T> of<T extends Object>(String name) {
    final i = _proxies[name];
    if (i is Pagination<T>) {
      return i;
    } else {
      throw UnimplementedError("Pagination didn't initialize for $name");
    }
  }

  /// Retrieves the item at the specified index.
  ///
  /// [name]: Name of the Pagination instance.
  /// [index]: Index of the item to retrieve.
  static PaginationData<T> itemOf<T extends Object>(String name, int index) {
    return of<T>(name).getItem(index);
  }

  /// Retrieves all items from the Pagination instance.
  ///
  /// [name]: Name of the Pagination instance.
  static List<T> itemsOf<T extends Object>(String name) {
    return of<T>(name)._items;
  }

  /// Retrieves the total item count from the Pagination instance.
  ///
  /// [name]: Name of the Pagination instance.
  static int itemCountOf<T extends Object>(String name) {
    return of<T>(name).itemCount;
  }

  /// Retrieves the item real index at the specified index.
  ///
  /// [name]: Name of the Pagination instance.
  /// [index]: Index of the item real index to retrieve.
  static int realIndexOf<T extends Object>(String name, int index) {
    return of<T>(name).getRealIndex(index);
  }

  static void reloadOf<T extends Object>(String name, [bool reload = true]) {
    return of<T>(name).reload(reload);
  }

  /// Initializes a new Pagination instance with the provided settings.
  ///
  /// [name]: Name to identify the Pagination instance.
  /// [fetchingSize]: Number of items to fetch each time.
  /// [limit]: Maximum number of items to load.
  /// [preload]: Distance to preload more data.
  static Pagination<T> init<T extends Object>(
    String name, {
    int fetchingSize = 10,
    int? limit,
    double preload = 1000,
    int? initialSize,
  }) {
    final value = Pagination<T>(
      initialSize: initialSize,
      fetchingSize: fetchingSize,
      limit: limit,
      preload: preload,
    );
    _proxies[name] = value;
    return value;
  }

  /// Applies pagination to a ScrollController with the specified callbacks.
  ///
  /// [name]: Name of the Pagination instance to apply.
  /// [controller]: ScrollController for the list view.
  /// [callback]: Callback function to load more data.
  /// [notifier]: Callback function to notify when new data is loaded.
  static void apply<T extends Object>(
    String name, {
    required ScrollController controller,
    required OnPaginationCallback<T> callback,
    required OnPaginationNotifier<T> notifier,
  }) {
    return of<T>(name).paginate(
      controller: controller,
      callback: callback,
      notifier: notifier,
    );
  }

  /// Indicates whether the pagination is in its initial state.
  bool get isInitial => _initial;

  /// Indicates whether data is currently being loaded.
  bool get isLoading => _loading;

  /// Indicates whether all available data has been loaded.
  bool get isFinish => _finish;

  /// Retrieves the current snapshot of the pagination state.
  Object? get snapshot => _snapshot;

  /// Retrieves the current snapshot interpreted as a page number.
  ///
  /// If the snapshot is not an integer, defaults to page 1.
  int get snapshotAsPage => snapshot is int ? snapshot as int : 1;

  /// Retrieves the list of items currently loaded.
  List<T> get items => _items;

  /// Retrieves the size of the initial loading batch.
  int get initialSize => _initialSize ?? fetchingSize;

  /// Retrieves the total number of items to load.
  ///
  /// If [limit] is set, returns the remaining items to reach the limit.
  ///
  /// Returns [loadingSize] if the initial load is in progress.
  ///
  /// Retrieves the size of the loading batch.
  int get loadingSize => size > 0 ? fetchingSize : initialSize;

  /// Retrieves the maximum number of items to load.
  int? get limit => _limit;

  /// Calculates the remaining number of items that can be loaded.
  int get remainingSize {
    if (limit != null && limit! > 0) {
      if (size < limit!) {
        return min(loadingSize, limit! - size);
      } else {
        return 0;
      }
    } else {
      return loadingSize;
    }
  }

  /// Retrieves the total number of items loaded.
  int get size => _items.length;

  /// Retrieves the total number of items to display.
  ///
  /// This takes into account the current pagination state and limits.
  int get itemCount {
    if (_initial) {
      return initialSize;
    } else {
      if (limit != null && size >= limit!) {
        return limit!;
      } else {
        if (_loading) {
          return size + remainingSize;
        } else {
          return size;
        }
      }
    }
  }

  /// Retrieves the item at the specified index.
  PaginationData<T> getItem(int index) {
    final value = _items.elementAtOrNull(index);
    if (value != null) {
      return PaginationData.value(value);
    } else {
      return const PaginationData.empty();
    }
  }

  /// Retrieves the item real index at the specified index.
  ///
  /// This method calculates the real index of the item in the entire dataset.
  ///
  /// [index]: The index of the item to retrieve.
  ///
  /// Retrieves the item real index at the specified index.
  int getRealIndex(int index) {
    final page = snapshotAsPage - 1;
    if (page > 0) {
      return (loadingSize * page) + index;
    } else {
      return index;
    }
  }

  /// Adds the fetched data to the list of items and updates pagination state.
  ///
  /// [value]: The list of items to add.
  void _puts(List<T> value) {
    _items.addAll(value);
    if (limit != null && size >= limit!) {
      _finish = true;
    }
  }

  /// Initializes the pagination process.
  ///
  /// This function is called when the pagination helper is first set up.
  void _initialize() {
    final controller = _controller;
    if (controller != null) {
      final x = controller.position.maxScrollExtent;
      final y = controller.position.atEdge && controller.position.pixels != 0;
      if (x == 0 || y) {
        _fetch();
      }
    }
  }

  /// Fetches more data based on the current pagination state.
  ///
  /// This function is called whenever more data needs to be loaded.
  void _fetch() {
    final callback = _callback;
    final notifier = _notifier;
    if (callback != null && notifier != null) {
      if (!_finish && !_loading) {
        _loading = true;
        notifier([]);
        callback(PaginationConfig(
          initialSize: initialSize,
          fetchingSize: remainingSize,
          snapshot: _snapshot,
        )).then((value) {
          _initial = false;
          _loading = false;
          if (!(value.status.isError || value.status.isResultNotFound)) {
            _snapshot = value.snapshot;
            if (value.status.isInvalid) _fetch();
            if (value.isSuccessful) {
              _puts(value.result);
              notifier(value.result);
              if (size < initialSize) {
                _fetch();
              } else {
                _initialize();
              }
            }
          } else {
            final data = value.result.where((e) {
              return !_items.contains(e);
            }).toList();
            _puts(data);
            _finish = true;
            notifier(value.result);
          }
        });
      }
    }
  }

  /// Initializes pagination for the associated [ScrollController].
  ///
  /// [controller]: The [ScrollController] for the list view.
  /// [callback]: The callback function to load more data.
  /// [notifier]: The callback function to notify when new data is loaded.
  ///
  /// Sets up pagination for the associated ScrollController.
  /// Support only two responses [PaginationResponse] or [Response]
  void paginate({
    required ScrollController controller,
    required OnPaginationCallback<T> callback,
    required OnPaginationNotifier<T> notifier,
  }) {
    _initial = true;
    _controller = controller;
    _callback = callback;
    _notifier = notifier;
    _fetch();
    _controller?.paginate(
      preload: preload,
      onLoad: _fetch,
      onLoading: () async {
        return _loading || _finish;
      },
    );
  }

  /// Initializes pagination state and data retrieval.
  ///
  /// If [reload] is `true`, it resets the pagination state and reloads the data.
  ///
  /// [reload]: Whether to reload the data, defaults to `true`.
  void reload([bool reload = true]) {
    _initial = true;
    _loading = false;
    _finish = false;
    _snapshot = null;
    _items = [];
    if (reload) _fetch();
  }
}
