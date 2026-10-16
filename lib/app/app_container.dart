import 'dart:async';
import 'package:flutter/services.dart';
import '../features/shop/data/bundled_product_stories.dart';
import '../features/shop/domain/product_story.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/external_links.dart';
import '../features/shop/data/preference_store.dart';
import '../features/shop/data/remote_product_repository.dart';
import '../features/shop/data/remote_checkout_repository.dart';
import '../features/shop/domain/repositories.dart';
import '../features/shop/presentation/view_models.dart';

class AppContainer {
  AppContainer({
    required this.catalog,
    required this.cart,
    required this.favorites,
    required this.checkout,
    required this.products,
    required this.links,
    this.stories = const EmptyProductStories(),
  });
  final CatalogViewModel catalog;
  final CartViewModel cart;
  final FavoritesViewModel favorites;
  final CheckoutViewModel checkout;
  final ProductRepository products;
  final ExternalLinks links;
  final ProductStoryRepository stories;

  factory AppContainer.production() {
    const apiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://nmdiet.ru/api/mobile/v1/',
    );
    final api = ApiClient(http.Client(), Uri.parse(apiUrl));
    final store = PreferenceStore(SharedPreferencesAsync());
    final products = RemoteProductRepository(api, store);
    final cart = CartViewModel(store, products);
    return AppContainer(
      catalog: CatalogViewModel(products),
      cart: cart,
      favorites: FavoritesViewModel(store),
      checkout: CheckoutViewModel(RemoteCheckoutRepository(api, store), cart),
      products: products,
      links: ExternalLinks(),
      stories: BundledProductStories(rootBundle),
    );
  }

  void initialize() {
    unawaited(catalog.load());
    unawaited(cart.load());
    unawaited(favorites.load());
    unawaited(checkout.restore());
  }
}
