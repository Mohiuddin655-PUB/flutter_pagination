import 'dart:math';

import 'package:andomie_pagination/flutter_pagination.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_entity/flutter_entity.dart';

typedef PageRequestListener<K> = void Function(K key);

typedef PagingStatusListener = void Function(PaginationStatus status);

/// A controller for a paged widget.
///
/// If you modify the [items], [error] or [nextKey] properties, the
/// paged widget will be notified and will update itself appropriately.
///
/// The [items], [error] or [nextKey] properties can be set from within
/// a listener added to this controller. If more than one property need to be
/// changed then the controller's [value] should be set instead.
///
/// This object should generally have a lifetime longer than the widgets
/// itself; it should be reused each time a paged widget constructor is called.
class PaginationController<K, E extends Object>
    extends ValueNotifier<PaginationState<K, E>> {
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

  /// Callback function to load more data.
  OnPaginationCallback<E>? _callback;

  /// Callback function to notify when new data is loaded.
  OnPaginationNotifier<E>? _notifier;

  /// Constructs a Pagination instance with the provided settings.
  ///
  /// [fetchingSize]: Number of items to fetch each time, defaults to 10.
  /// [preload]: Distance to preload more data, defaults to 1000.
  /// [limit]: Maximum number of items to load, defaults to null (unlimited).
  PaginationController(
    this.initialKey, {
    this.fetchingSize = 10,
    this.preload = 1000,
    this.invisibleItemsThreshold,
    int? limit,
    int? initialSize,
  })  : _initialSize = initialSize,
        _limit = limit,
        super(PaginationState<K, E>(key: initialKey));

  static final _proxies = <String, PaginationController>{};

  /// Retrieves a Pagination instance by name.
  ///
  /// Throws an UnimplementedError if the Pagination instance isn't initialized.
  static PaginationController<K, E> of<K, E extends Object>(String name) {
    final i = _proxies[name];
    if (i is PaginationController<K, E>) {
      return i;
    } else {
      throw UnimplementedError(
        "Pagination Controller didn't initialize for $name",
      );
    }
  }

  /// Initializes a new Pagination instance with the provided settings.
  ///
  /// [name]: Name to identify the Pagination instance.
  /// [fetchingSize]: Number of items to fetch each time.
  /// [limit]: Maximum number of items to load.
  /// [preload]: Distance to preload more data.
  static PaginationController<K, E> init<K, E extends Object>(
    String name, {
    required K initialKey,
    int fetchingSize = 10,
    int? limit,
    double preload = 1000,
    int? initialSize,
  }) {
    final value = PaginationController<K, E>(
      initialKey,
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
  static void apply<K, E extends Object>(
    String name, {
    required OnPaginationCallback<E> callback,
    required OnPaginationNotifier<E> notifier,
  }) {
    return of<K, E>(name).paginate(callback: callback, notifier: notifier);
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
  List<E> get items => value.items??[];

  set items(List<E>? newItems) {
    value = PaginationState<K, E>(
      error: error,
      items: newItems,
      key: nextKey,
    );
  }

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
  int get size => items.length;

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
  PaginationData<E> getItem(int index) {
    final value = items.elementAtOrNull(index);
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
  void _puts(List<E> value) {
    items = value;
    if (limit != null && size >= limit!) {
      _finish = true;
    }
  }

  /// Initializes the pagination process.
  ///
  /// This function is called when the pagination helper is first set up.
  void _initialize() {
    // final controller = _controller;
    // if (controller != null) {
    //   final x = controller.position.maxScrollExtent;
    //   final y = controller.position.atEdge && controller.position.pixels != 0;
    //   if (x == 0 || y) {
    //     _fetch();
    //   }
    // }
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
              return !items.contains(e);
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
    required OnPaginationCallback<E> callback,
    required OnPaginationNotifier<E> notifier,
  }) {
    _initial = true;
    _callback = callback;
    _notifier = notifier;
    _fetch();
    addRequestListener((key) {
      _fetch();
    });
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
    items = [];
    if (reload) _fetch();
  }

  ///
  ///
  ///
  ///
  ///
  ///

  ObserverList<PagingStatusListener>? _statusListeners =
      ObserverList<PagingStatusListener>();

  ObserverList<PageRequestListener<K>>? _pageRequestListeners =
      ObserverList<PageRequestListener<K>>();

  /// The number of remaining invisible items that should trigger a new fetch.
  final int? invisibleItemsThreshold;

  /// The key for the first page to be fetched.
  final K initialKey;

  /// The current error, if any. Initially `null`.
  dynamic get error => value.error;

  set error(dynamic newError) {
    value = PaginationState<K, E>(
      error: newError,
      items: items,
      key: nextKey,
    );
  }

  /// The key for the next page to be fetched.
  ///
  /// Initialized with the same value as [initialKey], received in the
  /// constructor.
  K? get nextKey => value.key;

  set nextKey(K? nextKey) {
    value = PaginationState<K, E>(
      error: error,
      items: items,
      key: nextKey,
    );
  }

  /// Corresponding to [ValueNotifier.value].
  @override
  set value(PaginationState<K, E> newValue) {
    if (value.status != newValue.status) {
      notifyStatusListeners(newValue.status);
    }
    super.value = newValue;
  }

  /// Appends [newItems] to the previously loaded ones and replaces
  /// the next page's key.
  void append(List<E> newItems, K? nextKey) {
    final previousItems = value.items ?? [];
    final itemList = previousItems + newItems;
    value = PaginationState<K, E>(
      items: itemList,
      error: null,
      key: nextKey,
    );
  }

  /// Appends [newItems] to the previously loaded ones and sets the next page
  /// key to `null`.
  void appendLast(List<E> newItems) {
    append(newItems, null);
  }

  /// Erases the current error.
  void retryLastFailedRequest() {
    error = null;
  }

  /// Resets [value] to its initial state.
  void refresh() {
    value = PaginationState<K, E>(
      key: initialKey,
      error: null,
      items: null,
    );
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_pageRequestListeners == null || _statusListeners == null) {
        throw Exception(
          'A PagingController was used after being disposed.\nOnce you have '
          'called dispose() on a PagingController, it can no longer be '
          'used.\nIf you’re using a Future, it probably completed after '
          'the disposal of the owning widget.\nMake sure dispose() has not '
          'been called yet before using the PagingController.',
        );
      }
      return true;
    }());
    return true;
  }

  /// Calls listener every time the status of the pagination changes.
  ///
  /// Listeners can be removed with [removeStatusListener].
  void addStatusListener(PagingStatusListener listener) {
    assert(_debugAssertNotDisposed());
    _statusListeners!.add(listener);
  }

  /// Stops calling the listener every time the status of the pagination
  /// changes.
  ///
  /// Listeners can be added with [addStatusListener].
  void removeStatusListener(PagingStatusListener listener) {
    assert(_debugAssertNotDisposed());
    _statusListeners!.remove(listener);
  }

  /// Calls all the status listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyStatusListeners(PaginationStatus status) {
    assert(_debugAssertNotDisposed());

    if (_statusListeners!.isEmpty) {
      return;
    }

    final localListeners = List<PagingStatusListener>.from(_statusListeners!);
    for (var listener in localListeners) {
      if (_statusListeners!.contains(listener)) {
        listener(status);
      }
    }
  }

  /// Calls listener every time new items are needed.
  ///
  /// Listeners can be removed with [removePageRequestListener].
  void addRequestListener(PageRequestListener<K> listener) {
    assert(_debugAssertNotDisposed());
    _pageRequestListeners!.add(listener);
  }

  /// Stops calling the listener every time new items are needed.
  ///
  /// Listeners can be added with [addRequestListener].
  void removePageRequestListener(PageRequestListener<K> listener) {
    assert(_debugAssertNotDisposed());
    _pageRequestListeners!.remove(listener);
  }

  /// Calls all the page request listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyPageRequestListeners(K pageKey) {
    assert(_debugAssertNotDisposed());

    if (_pageRequestListeners?.isEmpty ?? true) {
      return;
    }

    final localListeners =
        List<PageRequestListener<K>>.from(_pageRequestListeners!);

    for (var listener in localListeners) {
      if (_pageRequestListeners!.contains(listener)) {
        listener(pageKey);
      }
    }
  }

  @override
  void dispose() {
    assert(_debugAssertNotDisposed());
    _statusListeners = null;
    _pageRequestListeners = null;
    super.dispose();
  }
}
