import 'package:flutter/foundation.dart';

import 'status.dart';

/// The current item's list, error, and next page key state for a paginated
/// widget.
@immutable
class PaginationState<T extends Object> {
  const PaginationState({
    this.snapshot,
    this.items,
    this.error,
  });

  /// List with all items loaded so far.
  final List<T>? items;

  /// The current error, if any.
  final dynamic error;

  /// The key for the next page to be fetched.
  final Object? snapshot;

  /// The current pagination status.
  PaginationStatus get status {
    if (_isOngoing) {
      return PaginationStatus.ongoing;
    }

    if (_isCompleted) {
      return PaginationStatus.completed;
    }

    if (_isLoadingFirstPage) {
      return PaginationStatus.initial;
    }

    if (_hasSubsequentPageError) {
      return PaginationStatus.failure;
    }

    if (_isEmpty) {
      return PaginationStatus.nullable;
    } else {
      return PaginationStatus.error;
    }
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'PaginationState')}(items: \u2524'
        '$items\u251C, error: $error, key: $snapshot)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PaginationState &&
        other.items == items &&
        other.error == error &&
        other.snapshot == snapshot;
  }

  @override
  int get hashCode {
    return Object.hash(
      items.hashCode,
      error.hashCode,
      snapshot.hashCode,
    );
  }

  int? get _itemCount => items?.length;

  bool get _hasNextPage => snapshot != null;

  bool get _hasItems {
    final itemCount = _itemCount;
    return itemCount != null && itemCount > 0;
  }

  bool get _hasError => error != null;

  bool get _isListingUnfinished => _hasItems && _hasNextPage;

  bool get _isOngoing => _isListingUnfinished && !_hasError;

  bool get _isCompleted => _hasItems && !_hasNextPage;

  bool get _isLoadingFirstPage => _itemCount == null && !_hasError;

  bool get _hasSubsequentPageError => _isListingUnfinished && _hasError;

  bool get _isEmpty => _itemCount != null && _itemCount == 0;
}
