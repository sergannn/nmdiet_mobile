import 'package:flutter_test/flutter_test.dart';
import 'package:nmdiet_mobile/core/money.dart';
import 'package:nmdiet_mobile/features/shop/domain/models.dart';
import 'package:nmdiet_mobile/features/shop/presentation/view_models.dart';
import 'support/fakes.dart';

void main() {
  test('search and category filters compose', () async {
    final model = CatalogViewModel(FakeProducts());
    await model.load();
    model.search('магний');
    expect(model.visibleProducts.map((x) => x.id), [2]);
    model.selectCategory('daily');
    expect(model.visibleProducts, isEmpty);
  });
  test('cart persists only product IDs and bounded quantities', () async {
    final storage = FakeCollections(), products = FakeProducts();
    final cart = CartViewModel(storage, products);
    await cart.load();
    await cart.add(product);
    await cart.setQuantity(1, 150);
    expect(cart.count, 99);
    expect(cart.subtotalMinor, 149000 * 99);
    expect(storage.cart, {1: 99});
    final restored = CartViewModel(storage, products);
    await restored.load();
    expect(restored.count, 99);
    await restored.setQuantity(1, 0);
    expect(storage.cart, isEmpty);
  });
  test('favorites survive a new view model', () async {
    final storage = FakeCollections();
    final a = FavoritesViewModel(storage);
    await a.toggle(1);
    final b = FavoritesViewModel(storage);
    await b.load();
    expect(b.ids, {1});
    await b.toggle(1);
    expect(b.ids, isEmpty);
  });
  test(
    'checkout requires consent and clears matching cart only after confirmed payment',
    () async {
      final products = FakeProducts(),
          storage = FakeCollections(),
          repository = FakeCheckout();
      final cart = CartViewModel(storage, products);
      await cart.load();
      await cart.add(product);
      final checkout = CheckoutViewModel(repository, cart);
      await checkout.prepare();
      const details = CheckoutDetails(
        name: 'Покупатель',
        phone: '+79001234567',
        email: 'test@example.com',
        city: 'Москва',
        address: 'Тестовый адрес',
      );
      expect(await checkout.submit(details), false);
      expect(repository.submissions, 0);
      checkout.acceptConsent(true);
      expect(await checkout.submit(details), true);
      expect(cart.count, 1);
      await checkout.refreshOrder();
      expect(cart.count, 1);
      repository.paid = true;
      await checkout.refreshOrder();
      expect(cart.count, 0);
    },
  );
  test('money uses integer minor units without rounding', () {
    expect(money(149000), '1 490 ₽');
    expect(money(149050), '1 490,50 ₽');
  });
}
