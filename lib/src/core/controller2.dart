import 'package:flutter/foundation.dart';

import '../model/state.dart';
import '../model/status.dart';

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
class PaginationController<K, E> extends ValueNotifier<PaginationState<K, E>> {
  static final _proxies = <String, PaginationController>{};

  /// Retrieves a Pagination instance by name.
  ///
  /// Throws an UnimplementedError if the Pagination instance isn't initialized.
  static PaginationController<K, E> of<K, E>(String name) {
    final i = _proxies[name];
    if (i is PaginationController<K, E>) {
      return i;
    } else {
      throw UnimplementedError(
        "Pagination Controller didn't initialize for $name",
      );
    }
  }

  static void reloadOf<K, E>(String name) {
    return of<K,E>(name).refresh();
  }

  /// Initializes a new Pagination instance with the provided settings.
  ///
  /// [name]: Name to identify the Pagination instance.
  /// [fetchingSize]: Number of items to fetch each time.
  /// [limit]: Maximum number of items to load.
  /// [preload]: Distance to preload more data.
  static PaginationController<K, E> init<K, E>(
    String name, {
    required K initialKey,
    int? invisibleItemsThreshold,
  }) {
    final value = PaginationController<K, E>(
      initialKey: initialKey,
      invisibleItemsThreshold: invisibleItemsThreshold,
    );
    _proxies[name] = value;
    return value;
  }

  PaginationController({
    required this.initialKey,
    this.invisibleItemsThreshold,
  }) : super(PaginationState<K, E>(key: initialKey));

  /// Creates a controller from an existing [PaginationState].
  ///
  /// [firstPageKey] is the key to be used in case of a [refresh].
  PaginationController.fromValue(
    PaginationState<K, E> value, {
    required this.initialKey,
    this.invisibleItemsThreshold,
  }) : super(value);

  ObserverList<PagingStatusListener>? _statusListeners =
      ObserverList<PagingStatusListener>();

  ObserverList<PageRequestListener<K>>? _pageRequestListeners =
      ObserverList<PageRequestListener<K>>();

  /// The number of remaining invisible items that should trigger a new fetch.
  final int? invisibleItemsThreshold;

  /// The key for the first page to be fetched.
  final K initialKey;

  /// List with all items loaded so far. Initially `null`.
  List<E>? get items => value.items;

  set items(List<E>? newItems) {
    value = PaginationState<K, E>(
      error: error,
      items: newItems,
      key: nextKey,
    );
  }

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
