import 'package:nmdiet_mobile/app/app_container.dart';
import 'package:nmdiet_mobile/core/external_links.dart';
import 'package:nmdiet_mobile/features/shop/domain/models.dart';
import 'package:nmdiet_mobile/features/shop/domain/repositories.dart';
import 'package:nmdiet_mobile/features/shop/presentation/view_models.dart';

const product = Product(
  id: 1,
  slug: 'tipo-mix',
  name: 'Тиро-микс',
  description: 'Комплекс для поддержки щитовидной железы.',
  priceMinor: 149000,
  category: 'daily',
  capsules: '90 капсул',
  imageUrl: 'https://nmdiet.ru/assets/products/tipo-mix-90.jpg',
  gallery: [
    'https://nmdiet.ru/assets/products/tipo-mix-90.jpg',
    'https://nmdiet.ru/assets/products/tipo-mix-30.jpg',
  ],
  benefits: [],
  popular: true,
);

class FakeProducts implements ProductRepository {
  List<Product> items = [
    product,
    const Product(
      id: 2,
      slug: 'magnesium-mix',
      name: 'Магний-микс',
      description: 'Магний и L-теанин.',
      priceMinor: 159000,
      category: 'women',
      capsules: '120 капсул',
      imageUrl: 'https://nmdiet.ru/assets/products/magnesium-mix.jpg',
      gallery: [],
      benefits: [],
      popular: true,
    ),
  ];
  @override
  Future<CatalogSnapshot> catalog({bool refresh = false}) async =>
      CatalogSnapshot(items);
  @override
  Future<List<ProductReview>> reviews(String slug) async => [];
  @override
  Future<void> addReview(
    String slug,
    String author,
    int rating,
    String text,
  ) async {}
}

class FakeCollections implements CollectionRepository {
  Map<int, int> cart = {};
  Set<int> favorites = {};
  @override
  Future<Map<int, int>> readCart() async => Map.of(cart);
  @override
  Future<void> writeCart(Map<int, int> items) async {
    cart = Map.of(items);
  }

  @override
  Future<Set<int>> readFavorites() async => Set.of(favorites);
  @override
  Future<void> writeFavorites(Set<int> ids) async {
    favorites = Set.of(ids);
  }
}

class FakeCheckout implements CheckoutRepository {
  int submissions = 0;
  bool paid = false;
  @override
  Future<BasketQuote> quote(List<BasketItem> items, String? delivery) async =>
      BasketQuote(
        subtotalMinor: items.fold(0, (sum, x) => sum + x.quantity * 149000),
        deliveryMinor: delivery == null ? 0 : 39000,
        totalMinor:
            items.fold(0, (sum, x) => sum + x.quantity * 149000) +
            (delivery == null ? 0 : 39000),
        deliveries: [const DeliveryOption('cdek', 'СДЭК', 39000)],
      );
  @override
  Future<StoreOrder> placeOrder(
    List<BasketItem> items,
    String delivery,
    CheckoutDetails details,
    int expectedTotalMinor,
  ) async {
    submissions++;
    return StoreOrder(
      number: 'NMD-TEST',
      totalMinor: expectedTotalMinor,
      paymentStatus: 'pending',
      paymentUrl: 'https://yoomoney.ru/test',
      statusUrl: 'https://nmdiet.ru/api/mobile/v1/orders/1?signature=test',
    );
  }

  @override
  Future<StoreOrder> refreshOrder(StoreOrder order) async => StoreOrder(
    number: order.number,
    totalMinor: order.totalMinor,
    paymentStatus: paid ? 'paid' : 'pending',
    paymentUrl: order.paymentUrl,
    statusUrl: order.statusUrl,
  );
  @override
  Future<StoreOrder?> lastOrder() async => null;
}

class FakeLinks extends ExternalLinks {
  String? opened;
  @override
  Future<void> open(String url) async {
    opened = url;
  }
}

Future<AppContainer> testContainer() async {
  final products = FakeProducts(),
      collections = FakeCollections(),
      checkout = FakeCheckout();
  final cart = CartViewModel(collections, products);
  final catalog = CatalogViewModel(products),
      favorites = FavoritesViewModel(collections);
  await Future.wait([cart.load(), catalog.load(), favorites.load()]);
  return AppContainer(
    catalog: catalog,
    cart: cart,
    favorites: favorites,
    checkout: CheckoutViewModel(checkout, cart),
    products: products,
    links: FakeLinks(),
  );
}
