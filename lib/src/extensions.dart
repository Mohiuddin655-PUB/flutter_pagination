part of 'pagination.dart';

/// Extension for ScrollController to enable pagination.
extension PaginationHelperExtension on ScrollController {
  /// Sets up pagination for the associated scroll controller.
  ///
  /// [preload]: Distance to preload more data, defaults to 0.
  /// [onLoad]: Callback function to load more data.
  /// [onLoading]: Callback function to check if loading is in progress.
  void paginate({
    double preload = 0,
    required OnPaginationDataLoadingRequest onLoad,
    required OnPaginationDataLoadingPermission onLoading,
  }) {
    PaginationHelper(
      controller: this,
      preload: preload,
      onLoad: onLoad,
      onLoading: onLoading,
    );
  }
}
