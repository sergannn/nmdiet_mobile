import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api_client.dart';
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'dto.dart';
import 'preference_store.dart';

class RemoteCheckoutRepository implements CheckoutRepository {
  RemoteCheckoutRepository(this.api, this.store);
  final ApiClient api;
  final PreferenceStore store;
  @override
  Future<BasketQuote> quote(List<BasketItem> items, String? delivery) async =>
      ShopDto.quote(
        (await api.post('cart/quote', ShopDto.basket(items, delivery)))['data']
            as Map<String, dynamic>,
      );

  @override
  Future<StoreOrder> placeOrder(
    List<BasketItem> items,
    String delivery,
    CheckoutDetails details,
    int expectedTotalMinor,
  ) async {
    final body = {
      ...ShopDto.basket(items, delivery),
      'customer_name': details.name.trim(),
      'customer_phone': details.phone.trim(),
      'customer_email': details.email.trim(),
      'city': details.city.trim(),
      'address': details.address.trim(),
      'comment': details.comment.trim(),
      'consent': true,
      'expected_total_minor': expectedTotalMinor,
    };
    // Persist only a digest and a random retry key, never the customer's details.
    final digest = sha256.convert(utf8.encode(jsonEncode(body))).toString();
    final previousDigest = await store.read('checkout.digest');
    final key = previousDigest == digest
        ? await store.read('checkout.key')
        : null;
    final checkoutKey = key ?? const Uuid().v4();
    await store.write('checkout.digest', digest);
    await store.write('checkout.key', checkoutKey);
    final response = await api.post('orders', {
      ...body,
      'checkout_key': checkoutKey,
    });
    final order = ShopDto.order(response['data'] as Map<String, dynamic>);
    await store.write('order.last', jsonEncode(ShopDto.orderJson(order)));
    return order;
  }

  @override
  Future<StoreOrder> refreshOrder(StoreOrder order) async {
    final updated = ShopDto.order(
      (await api.getSigned(order.statusUrl))['data'] as Map<String, dynamic>,
    );
    await store.write('order.last', jsonEncode(ShopDto.orderJson(updated)));
    if (updated.paid || updated.canceled) {
      await store.remove('checkout.digest');
      await store.remove('checkout.key');
    }
    return updated;
  }

  @override
  Future<StoreOrder?> lastOrder() async {
    final value = await store.read('order.last');
    if (value == null) return null;
    try {
      return ShopDto.order(jsonDecode(value) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
