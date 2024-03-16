part of 'pagination.dart';

/// Helper class to manage pagination in Flutter apps.
class PaginationHelper {
  /// Scroll controller for the list view.
  final ScrollController controller;

  /// Distance to preload more data, defaults to 1000.
  final double preload;

  /// Callback function to load more data.
  final OnPaginationDataLoadingRequest onLoad;

  /// Callback function to check if loading is in progress.
  final OnPaginationDataLoadingPermission onLoading;

  /// Constructs a PaginationHelper with the provided parameters.
  ///
  /// [controller]: Scroll controller for the list view.
  /// [onLoad]: Callback function to load more data.
  /// [onLoading]: Callback function to check if loading is in progress.
  /// [preload]: Distance to preload more data, defaults to 1000.
  PaginationHelper({
    required this.controller,
    required this.onLoad,
    required this.onLoading,
    this.preload = 1000,
  }) {
    controller.addListener(_checker);
  }

  /// Checks if additional data needs to be loaded.
  ///
  /// This function is called whenever the scroll position changes to determine
  /// if more data should be loaded based on the preload distance.
  void _checker() {
    onLoading().onError((_, __) => false).then((value) {
      if (!value) {
        if (preload > 0) {
          _preloader();
        } else {
          _loader();
        }
      }
    });
  }

  /// Loads more data when reaching the edge of the list view.
  ///
  /// This function is called when the user scrolls to the edge of the list view
  /// to load more data if preload is set to 0 or less.
  void _loader() {
    if (controller.position.atEdge) {
      if (controller.position.pixels != 0) {
        onLoad();
      }
    }
  }

  /// Preloads more data when approaching the preload distance.
  ///
  /// This function is called when the user scrolls close to the preload distance
  /// to preload more data if preload is set to a positive value.
  void _preloader() {
    final pixels = controller.position.pixels;
    final extend = controller.position.maxScrollExtent - preload;
    if (pixels != 0 && pixels >= extend) {
      onLoad();
    }
  }
}
