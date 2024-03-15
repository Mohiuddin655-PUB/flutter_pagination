part of 'pagination.dart';

/// Configuration for pagination settings.
class PaginationConfig {
  /// Initial number of items to load.
  final int initialSize;

  /// Number of items to fetch each time.
  final int fetchingSize;

  /// Snapshot object to track pagination state.
  final Object? snapshot;

  /// SnapshotAsPage value to track paged pagination state.
  int get snapshotAsPage => snapshot is int ? snapshot as int : 1;

  const PaginationConfig({
    required this.initialSize,
    required this.fetchingSize,
    required this.snapshot,
  });
}
