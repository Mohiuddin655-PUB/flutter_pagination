part of 'pagination.dart';

typedef OnPaginationCallback<T extends Object> = Future<Response<T>> Function(
  PaginationConfig config,
);

typedef OnPaginationNotifier<T extends Object> = void Function(List<T> value);

typedef OnPaginationDataLoadingPermission = Future<bool> Function();

typedef OnPaginationDataLoadingRequest = void Function();
