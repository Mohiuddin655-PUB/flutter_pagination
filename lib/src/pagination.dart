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
  final int? _initialSize;
  final int fetchingSize;
  final int? _limit;
  final double preload;

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

  bool _initial = true;
  bool _loading = false;
  bool _finish = false;
  Object? _snapshot;
  List<T> _items = [];
  ScrollController? _controller;
  OnPaginationCallback<T>? _callback;
  OnPaginationNotifier<T>? _notifier;

  bool get isInitial => _initial;

  bool get isLoading => _loading;

  bool get isFinish => _finish;

  Object? get snapshot => _snapshot;

  int get snapshotAsPage => snapshot is int ? snapshot as int : 1;

  List<T> get items => _items;

  int get initialSize => _initialSize ?? fetchingSize;

  int get loadingSize => size > 0 ? fetchingSize : initialSize;

  int? get limit => _limit;

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

  int get size => _items.length;

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
  int getRealIndex(int index) {
    final page = snapshotAsPage - 1;
    if (page > 0) {
      return (loadingSize * page) + index;
    } else {
      return index;
    }
  }

  void _puts(List<T> value) {
    _items.addAll(value);
    if (limit != null && size >= limit!) {
      _finish = true;
    }
  }

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

  void reload([bool reload = true]) {
    _initial = true;
    _loading = false;
    _finish = false;
    _snapshot = null;
    _items = [];
    if (reload) _fetch();
  }
}
