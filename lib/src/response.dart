part of 'pagination.dart';

/// Represents a paginated response containing status, result, and snapshot.
class PaginationResponse<T extends Object> extends Response<T> {
  /// Constructs a PaginationResponse instance with the provided parameters.
  PaginationResponse._({
    Status? status,
    List<T>? result,
    Object? snapshot,
  }) : super(status: status, result: result, snapshot: snapshot);

  /// Constructs a PaginationResponse instance with a successful status and data.
  ///
  /// [result]: List of items returned in the response.
  /// [snapshot]: Snapshot representing the current state of the data.
  PaginationResponse.value({
    required List<T>? result,
    required Object? snapshot,
  }) : this._(status: Status.ok, result: result, snapshot: snapshot);

  /// Constructs a PaginationResponse instance with an error status.
  PaginationResponse.error() : this._(status: Status.error);

  /// Constructs a PaginationResponse instance with an invalid status.
  PaginationResponse.invalid() : super(status: Status.invalid);

  /// Constructs a PaginationResponse instance with a not found status.
  PaginationResponse.notFound() : super(status: Status.notFound);
}
