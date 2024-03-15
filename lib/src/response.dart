part of 'pagination.dart';

class PaginationResponse<T extends Object> extends Response<T> {
  PaginationResponse._({
    super.status,
    super.result,
    super.snapshot,
  });

  PaginationResponse.value({
    required List<T>? result,
    required Object? snapshot,
  }) : this._(status: Status.ok, result: result, snapshot: snapshot);

  PaginationResponse.error() : this._(status: Status.error);

  PaginationResponse.invalid() : super(status: Status.invalid);

  PaginationResponse.notFound() : super(status: Status.notFound);
}
