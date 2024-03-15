part of 'pagination.dart';

/// Represents data for pagination, either as a placeholder or with actual data.
class PaginationData<T extends Object> {
  /// Indicates if the data is a placeholder.
  final bool isPlaceholder;

  /// The actual data.
  final T? data;

  const PaginationData._({
    this.isPlaceholder = true,
    this.data,
  });

  const PaginationData.empty() : this._();

  const PaginationData.value(this.data) : isPlaceholder = false;
}
