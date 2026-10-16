import 'package:flutter/foundation.dart';
import '../../../core/failure.dart';
import '../domain/models.dart';
import '../domain/repositories.dart';

String userError(Object error) => error is AppFailure
    ? error.message
    : 'Не удалось загрузить данные. Попробуйте ещё раз.';

class CatalogViewModel extends ChangeNotifier {
  CatalogViewModel(this.repository);
  final ProductRepository repository;
  List<Product> products = [];
  bool loading = true, cached = false;
  String? error;
  String query = '', category = 'all';
  List<Product> get visibleProducts => products
      .where(
        (p) =>
            (category == 'all' || p.category == category) &&
            '${p.name} ${p.description}'.toLowerCase().contains(
              query.toLowerCase().trim(),
            ),
      )
      .toList();
  List<Product> get featured =>
      products.where((p) => p.popular).take(4).toList();
  List<Product> favorites(Set<int> ids) =>
      products.where((p) => ids.contains(p.id)).toList();
  void search(String value) {
    query = value;
    notifyListeners();
  }

  void selectCategory(String value) {
    category = value;
    notifyListeners();
  }

  Future<void> load({bool refresh = false}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final snapshot = await repository.catalog(refresh: refresh);
      products = snapshot.products;
      cached = snapshot.cached;
    } catch (e) {
      error = userError(e);
    }
    loading = false;
    notifyListeners();
  }
}

class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel(this.repository);
  final CollectionRepository repository;
  Set<int> _ids = {};
  Set<int> get ids => Set.unmodifiable(_ids);
  String? error;
  Future<void> load() async {
    try {
      _ids = await repository.readFavorites();
    } catch (e) {
      error = userError(e);
    }
    notifyListeners();
  }

  Future<void> toggle(int id) async {
    _ids = {..._ids};
    if (!_ids.add(id)) _ids.remove(id);
    notifyListeners();
    try {
      await repository.writeFavorites(_ids);
    } catch (_) {
      error = 'Не удалось сохранить избранное.';
      notifyListeners();
    }
  }
}

class CartViewModel extends ChangeNotifier {
  CartViewModel(this.repository, this.products);
  final CollectionRepository repository;
  final ProductRepository products;
  Map<int, int> _quantities = {};
  List<Product> _products = [];
  bool loading = true;
  String? error;
  List<CartLine> get lines => _products
      .where((p) => _quantities.containsKey(p.id))
      .map((p) => CartLine(p, _quantities[p.id]!))
      .toList();
  List<BasketItem> get items =>
      lines.map((x) => BasketItem(x.product.id, x.quantity)).toList();
  int get count => lines.fold(0, (sum, x) => sum + x.quantity);
  int get subtotalMinor => lines.fold(0, (sum, x) => sum + x.totalMinor);
  String get fingerprint =>
      items.map((x) => '${x.productId}:${x.quantity}').join('|');

  Future<void> load() async {
    try {
      _quantities = await repository.readCart();
      _products = (await products.catalog()).products;
    } catch (e) {
      error = userError(e);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> add(Product product) async {
    if (!_products.any((p) => p.id == product.id)) {
      _products = [..._products, product];
    }
    await setQuantity(product.id, (_quantities[product.id] ?? 0) + 1);
  }

  Future<void> setQuantity(int id, int quantity) async {
    if (quantity <= 0) {
      _quantities.remove(id);
    } else {
      _quantities[id] = quantity.clamp(1, 99);
    }
    error = null;
    notifyListeners();
    try {
      await repository.writeCart(Map.of(_quantities));
    } catch (_) {
      error = 'Не удалось сохранить корзину.';
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _quantities = {};
    notifyListeners();
    await repository.writeCart({});
  }
}

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel(this.repository, this.cart);
  final CheckoutRepository repository;
  final CartViewModel cart;
  BasketQuote? quote;
  StoreOrder? order;
  String? delivery, error;
  bool busy = false, consent = false;
  int _revision = 0;
  String? _orderedCart;

  Future<void> restore() async {
    try {
      order = await repository.lastOrder();
    } catch (_) {
      /* No saved order yet. */
    }
    notifyListeners();
  }

  void acceptConsent(bool value) {
    consent = value;
    notifyListeners();
  }

  Future<void> prepare({String? deliveryId}) async {
    final revision = ++_revision;
    if (cart.items.isEmpty) {
      quote = null;
      return;
    }
    busy = true;
    error = null;
    notifyListeners();
    try {
      final selected = deliveryId ?? delivery;
      var next = await repository.quote(cart.items, selected);
      var nextDelivery = selected;
      if (nextDelivery == null && next.deliveries.isNotEmpty) {
        nextDelivery = next.deliveries.first.id;
        next = await repository.quote(cart.items, nextDelivery);
      }
      if (revision != _revision) return;
      quote = next;
      delivery = nextDelivery;
    } catch (e) {
      if (revision == _revision) {
        quote = null;
        error = userError(e);
      }
    }
    if (revision == _revision) {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> submit(CheckoutDetails details) async {
    if (busy) return false;
    error = details.validate();
    if (!consent) error = 'Подтвердите согласие с условиями заказа.';
    if (quote == null || delivery == null || cart.items.isEmpty) {
      error ??= 'Обновите стоимость заказа.';
    }
    if (error != null) {
      notifyListeners();
      return false;
    }
    busy = true;
    notifyListeners();
    try {
      order = await repository.placeOrder(
        cart.items,
        delivery!,
        details,
        quote!.totalMinor,
      );
      _orderedCart = cart.fingerprint;
      busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      final message = userError(e);
      busy = false;
      await prepare();
      error = message;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshOrder() async {
    if (order == null || busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      order = await repository.refreshOrder(order!);
      if (order!.paid && _orderedCart == cart.fingerprint) await cart.clear();
    } catch (e) {
      error = userError(e);
    }
    busy = false;
    notifyListeners();
  }
}

class ReviewsViewModel extends ChangeNotifier {
  ReviewsViewModel(this.repository, this.slug);
  final ProductRepository repository;
  final String slug;
  List<ProductReview> reviews = [];
  bool loading = false;
  String? error, message;
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      reviews = await repository.reviews(slug);
    } catch (e) {
      error = userError(e);
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> submit(String author, int rating, String text) async {
    if (loading) return false;
    if (author.trim().isEmpty || text.trim().length < 5) {
      error = 'Укажите имя и напишите отзыв.';
      notifyListeners();
      return false;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      await repository.addReview(slug, author.trim(), rating, text.trim());
      message = 'Спасибо! Отзыв появится после проверки.';
    } catch (e) {
      error = userError(e);
    }
    loading = false;
    notifyListeners();
    return error == null;
  }
}
