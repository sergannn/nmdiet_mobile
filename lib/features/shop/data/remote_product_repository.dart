import 'dart:convert';
import '../../../core/api_client.dart';
import '../../../core/failure.dart';
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'dto.dart';
import 'preference_store.dart';

class RemoteProductRepository implements ProductRepository {
  RemoteProductRepository(this.api, this.store);
  final ApiClient api;
  final PreferenceStore store;
  CatalogSnapshot? _catalog;
  Future<CatalogSnapshot>? _loading;

  @override
  Future<CatalogSnapshot> catalog({bool refresh = false}) {
    if (_loading != null) return _loading!;
    if (!refresh && _catalog != null) return Future.value(_catalog);
    return _loading = _load().whenComplete(() => _loading = null);
  }

  Future<CatalogSnapshot> _load() async {
    try {
      final response = await api.get('products');
      final products = (response['data'] as List)
          .map(
            (dynamic x) => ShopDto.product(Map<String, dynamic>.from(x as Map)),
          )
          .toList();
      _catalog = CatalogSnapshot(List.unmodifiable(products));
      await store.write(
        'catalog.v1',
        jsonEncode(products.map(ShopDto.productJson).toList()),
      );
      return _catalog!;
    } on AppFailure {
      final cache = await store.read('catalog.v1');
      if (cache == null) rethrow;
      try {
        final products = (jsonDecode(cache) as List)
            .map(
              (dynamic x) =>
                  ShopDto.product(Map<String, dynamic>.from(x as Map)),
            )
            .toList();
        return _catalog = CatalogSnapshot(
          List.unmodifiable(products),
          cached: true,
        );
      } on FormatException {
        rethrow;
      }
    }
  }

  @override
  Future<List<ProductReview>> reviews(String slug) async {
    final response = await api.get(
      'products/${Uri.encodeComponent(slug)}/reviews',
    );
    return (response['data'] as List)
        .map(
          (dynamic x) => ProductReview(
            x['author_name'] as String,
            (x['rating'] as num).toInt(),
            x['text'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<void> addReview(
    String slug,
    String author,
    int rating,
    String text,
  ) async {
    await api.post('products/${Uri.encodeComponent(slug)}/reviews', {
      'author_name': author,
      'rating': rating,
      'text': text,
    });
  }
}
