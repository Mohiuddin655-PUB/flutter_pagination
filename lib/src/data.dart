part of 'pagination.dart';

/// Represents data for pagination, either as a placeholder or with actual data.
class PaginationData<T extends Object> {
  /// Indicates whether this [PaginationData] instance is a placeholder.
  final bool isPlaceholder;

  /// The data associated with this [PaginationData].
  ///
  /// If this [PaginationData] instance is a placeholder, [data] will be `null`.
  final T? data;

  const PaginationData._({
    this.isPlaceholder = true,
    this.data,
  });

  /// Creates a placeholder [PaginationData] instance with no data.
  ///
  /// This constructor is typically used to represent loading or empty states.
  ///
  /// Example:
  /// Creating a placeholder PaginationData instance:
  /// const PaginationData<int>.empty();
  const PaginationData.empty() : this._();

  /// Creates a [PaginationData] instance with the provided [data].
  ///
  /// Setting [isPlaceholder] to `false` indicates that the data is not a placeholder.
  /// Use this constructor when the pagination retrieves actual data.
  ///
  /// Example:
  /// Creating a PaginationData instance with actual data:
  /// const PaginationData<int>.value(42);
  const PaginationData.value(this.data) : isPlaceholder = false;
}
