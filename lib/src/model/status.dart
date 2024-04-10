/// All possible status for a pagination.
enum PaginationStatus {
  completed,
  error,
  failure,
  initial,
  nullable,
  ongoing;

  bool get isCompleted => this == completed;

  bool get isError => this == error;

  bool get isFailure => this == failure;

  bool get isInitial => this == initial;

  bool get isNotFound => this == nullable;

  bool get isOngoing => this == ongoing;
}
