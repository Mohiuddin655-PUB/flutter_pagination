part of 'pagination.dart';

/// Helper class to manage pagination in Flutter apps.
class PaginationHelper {
  final ScrollController controller;
  final double preload;
  final OnPaginationDataLoadingRequest onLoad;
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

  void _loader() {
    if (controller.position.atEdge) {
      if (controller.position.pixels != 0) {
        onLoad();
      }
    }
  }

  void _preloader() {
    final pixels = controller.position.pixels;
    final extend = controller.position.maxScrollExtent - preload;
    if (pixels != 0 && pixels >= extend) {
      onLoad();
    }
  }
}
