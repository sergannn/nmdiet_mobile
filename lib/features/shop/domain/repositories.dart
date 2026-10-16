import 'models.dart';

abstract interface class ProductRepository {
  Future<CatalogSnapshot> catalog({bool refresh = false});
  Future<List<ProductReview>> reviews(String slug);
  Future<void> addReview(String slug, String author, int rating, String text);
}

abstract interface class CollectionRepository {
  Future<Map<int, int>> readCart();
  Future<void> writeCart(Map<int, int> items);
  Future<Set<int>> readFavorites();
  Future<void> writeFavorites(Set<int> ids);
}

abstract interface class CheckoutRepository {
  Future<BasketQuote> quote(List<BasketItem> items, String? delivery);
  Future<StoreOrder> placeOrder(
    List<BasketItem> items,
    String delivery,
    CheckoutDetails details,
    int expectedTotalMinor,
  );
  Future<StoreOrder> refreshOrder(StoreOrder order);
  Future<StoreOrder?> lastOrder();
}
