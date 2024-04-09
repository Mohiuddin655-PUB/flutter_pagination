import 'beer_summary.dart';

class RemoteApi {
  static Future<List<BeerSummary>> _data(int pageKey, int limit) {
    return Future.delayed(const Duration(seconds: 2)).then((_) {
      final items = List.generate(limit, (i) {
        final number = pageKey + 1;
        return BeerSummary(
          id: i + pageKey,
          name: "Item number is $number",
          imageUrl: i % 2 == 0
              ? "https://images.freeimages.com/365/images/previews/a7b/jumper-mockup-psd-56444.jpg?fmt=webp&w=500"
              : i % 3 == 0
                  ? "https://images.freeimages.com/variants/h5x75mMzcK26DrsoLKqg3AEi/f4a36f6589a0e50e702740b15352bc00e4bfaf6f58bd4db850e167794d05993d?fmt=webp&w=500"
                  : "https://images.freeimages.com/images/large-previews/aed/three-bees-on-sunflower-1337029.jpg?fmt=webp&w=500",
        );
      });
      return items;
    });
  }

  static Future<List<BeerSummary>> getBeerList(
    int page,
    int limit, {
    String? searchTerm,
  }) async {
    return _data(page, limit);
  }
}
