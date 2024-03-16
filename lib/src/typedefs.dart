part of 'pagination.dart';

/// A callback function used for loading more data in pagination.
typedef OnPaginationCallback<T extends Object> = Future<Response<T>> Function(
  PaginationConfig config,
);

/// A callback function used for notifying when new data is loaded in pagination.
typedef OnPaginationNotifier<T extends Object> = void Function(List<T> value);

/// A callback function used for checking permission to load more data in pagination.
typedef OnPaginationDataLoadingPermission = Future<bool> Function();

/// A callback function used for requesting to load more data in pagination.
typedef OnPaginationDataLoadingRequest = void Function();
