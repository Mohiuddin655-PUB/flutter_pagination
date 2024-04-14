import 'dart:async';
import 'dart:math';

import 'package:andomie_pagination/flutter_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_entity/flutter_entity.dart';

part 'config.dart';
part 'data.dart';
part 'extensions.dart';
part 'helper.dart';
part 'response.dart';
part 'typedefs.dart';

typedef PagingStatusListener = void Function(PaginationStatus status);

/// Manages pagination state and data retrieval.
class Pagination<T extends Object> extends ValueNotifier<PaginationState<T>> {
  /// Number of items to fetch each time.
  final int fetchingSize;

  /// Maximum number of items to load.
  final int? _limit;

  /// Distance to preload more data.
  final double preload;

  /// Distance to preload more data.
  final int? threshold;

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
  List<T> get _items => value.items ?? [];

  /// Scroll controller used for pagination.
  ScrollController? _controller;

  bool get isControllerMode => _controller != null;

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
    this.threshold = 3,
    int? limit,
    int? initialSize,
    Object? snapshot,
  })  : _initialSize = initialSize,
        _limit = limit,
        super(PaginationState(snapshot: snapshot));

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

  /// Remove the item at the specified index.
  ///
  /// [name]: Name of the Pagination instance.
  /// [index]: Index of the item to retrieve.
  static T removeItemOf<T extends Object>(String name, int index) {
    return of<T>(name).removeItem(index);
  }

  /// Update the item at the specified index.
  ///
  /// [name]: Name of the Pagination instance.
  /// [index]: Index of the item to retrieve.
  static void updateItemOf<T extends Object>(
    String name,
    int index,
    T Function(T old) callback,
  ) {
    return of<T>(name).update(index, callback);
  }

  /// Clear all items.
  ///
  /// [name]: Name of the Pagination instance.
  /// [index]: Index of the item to retrieve.
  static List<T> clearOf<T extends Object>(String name) {
    return of<T>(name).clear();
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

  static void disposeOf<T extends Object>(String name) {
    return of<T>(name).dispose();
  }

  static void closeOf(String name) => _proxies.remove(name);

  static void notify<T extends Object>(String name) {
    return of<T>(name).notifyListeners();
  }

  static void setOf<T extends Object>(
    String name,
    List<T> value, {
    bool notify = true,
  }) {
    return of<T>(name).set(value, notify);
  }

  static PaginationConfig configOf<T extends Object>(String name) {
    return of<T>(name).config;
  }

  static void pushOf<T extends Object>(
    String name,
    PaginationResponse<T> value,
  ) {
    return of<T>(name).push(value);
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
    int? threshold,
    double preload = 1000,
    int? initialSize,
    Object? snapshot,
  }) {
    final value = Pagination<T>(
      snapshot: snapshot,
      threshold: threshold,
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

  static void attach<T extends Object>(
    String name, {
    required OnPaginationCallback<T> request,
    OnPaginationNotifier<T>? response,
  }) {
    return of<T>(name).callback(callback: request, notifier: response);
  }

  /// Indicates whether the pagination is in its initial state.
  bool get isInitial => _initial;

  /// Indicates whether data is currently being loaded.
  bool get isLoading => _loading;

  /// Indicates whether all available data has been loaded.
  bool get isFinish => _finish;

  /// The key for the next page to be fetched.
  ///
  /// Initialized with the same value as [initialKey], received in the
  /// constructor.
  /// Retrieves the current snapshot of the pagination state.

  Object? get snapshot => value.snapshot ?? _snapshot;

  set snapshot(Object? value) {
    this.value = PaginationState<T>(
      error: error,
      items: items,
      snapshot: value,
    );
  }

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

  int get triggerIndex => max(0, size - (threshold ?? 3));

  PaginationConfig get config {
    return PaginationConfig(
      initialSize: initialSize,
      fetchingSize: remainingSize,
      snapshot: snapshot,
    );
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

  /// Update the item at the specified index.
  void update(int index, T Function(T old) callback) {
    final x = _items.removeAt(index);
    final y = callback(x);
    _items.insert(index, y);
  }

  /// Remove the item at the specified index.
  T removeItem(int index) => _items.removeAt(index);

  /// Clear all items
  List<T> clear() {
    final x = _items;
    _items.clear();
    return x;
  }

  /// Clear all items
  void set(List<T> value, [bool notify = true]) {
    _items.clear();
    _items.addAll(value);
    if (notify) notifyListeners();
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
    this.value = PaginationState<T>(
      items: items..addAll(value),
      error: null,
      snapshot: _snapshot,
    );
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
        fetch();
      }
    }
  }

  /// Fetches more data based on the current pagination state.
  ///
  /// This function is called whenever more data needs to be loaded.
  void fetch() {
    final callback = _callback;
    if (callback != null) {
      if (!_finish && !_loading) {
        _loading = true;
        final notifier = _notifier;
        if (notifier != null) notifier([]);
        callback(PaginationConfig(
          initialSize: initialSize,
          fetchingSize: remainingSize,
          snapshot: _snapshot,
        )).then((value) {
          _initial = false;
          _loading = false;
          if (!(value.status.isError || value.status.isResultNotFound)) {
            _snapshot = value.snapshot;
            if (value.status.isInvalid) fetch();
            if (value.isSuccessful) {
              _puts(value.result);
              if (notifier != null) notifier(value.result);
              if (size < initialSize) {
                fetch();
              } else {
                _initialize();
              }
            }
          } else {
            if (!isControllerMode) error = value.exception;
            final data = value.result.where((e) {
              return !_items.contains(e);
            }).toList();
            _puts(data);
            _finish = true;
            if (notifier != null) notifier(value.result);
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
    fetch();
    _controller?.paginate(
      preload: preload,
      onLoad: fetch,
      onLoading: () async {
        return _loading || _finish;
      },
    );
  }

  void callback({
    required OnPaginationCallback<T> callback,
    OnPaginationNotifier<T>? notifier,
  }) {
    _initial = true;
    _callback = callback;
    _notifier = notifier;
    fetch();
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
    value = PaginationState<T>(
      snapshot: null,
      error: null,
      items: null,
    );
    if (reload && isControllerMode) fetch();
  }

  void push(PaginationResponse<T> value) {
    if (!isControllerMode && !_finish && !_loading) {
      _initial = false;
      _loading = false;
      if (!(value.status.isError || value.status.isResultNotFound)) {
        _snapshot = value.snapshot;
        if (value.isSuccessful) _puts(value.result);
      } else {
        if (!isControllerMode) error = value.exception;
        final data = value.result.where((e) {
          return !_items.contains(e);
        }).toList();
        _puts(data);
        _finish = true;
      }
    }
  }

  /// The current error, if any. Initially `null`.
  dynamic get error => value.error;

  set error(dynamic error) {
    value = PaginationState<T>(
      error: error,
      items: items,
      snapshot: _snapshot,
    );
  }

  /// Erases the current error.
  void retry() {
    error = null;
  }
}
