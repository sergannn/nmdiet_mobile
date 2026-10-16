import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nmdiet_mobile/core/api_client.dart';
import 'package:nmdiet_mobile/core/failure.dart';
import 'package:nmdiet_mobile/features/shop/data/preference_store.dart';
import 'package:nmdiet_mobile/features/shop/data/remote_checkout_repository.dart';
import 'package:nmdiet_mobile/features/shop/domain/models.dart';

class UnusedPreferences implements SharedPreferencesAsync {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MemoryPreferences extends PreferenceStore {
  MemoryPreferences() : super(UnusedPreferences());
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

void main() {
  test('retries use the same key and never store personal details', () async {
    final keys = <String>[], storage = MemoryPreferences();
    final client = ApiClient(
      MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        keys.add(body['checkout_key'] as String);
        expect(body.containsKey('price'), false);
        return http.Response(
          jsonEncode({
            'data': {
              'number': 'NMD-TEST',
              'total_minor': 188000,
              'payment_status': 'pending',
              'payment_url': 'https://yoomoney.ru/test',
              'status_url':
                  'https://nmdiet.ru/api/mobile/v1/orders/1?signature=test',
            },
          }),
          201,
        );
      }),
      Uri.parse('https://nmdiet.ru/api/mobile/v1/'),
    );
    final repo = RemoteCheckoutRepository(client, storage);
    const details = CheckoutDetails(
      name: 'Test Customer',
      phone: '+79001234567',
      email: 'test@example.com',
      city: 'Москва',
      address: 'Private Street',
    );
    await repo.placeOrder([const BasketItem(1, 1)], 'cdek', details, 188000);
    await repo.placeOrder([const BasketItem(1, 1)], 'cdek', details, 188000);
    expect(keys[0], keys[1]);
    expect(storage.values.toString(), isNot(contains('Private Street')));
    expect(storage.values.toString(), isNot(contains('test@example.com')));
  });
  test('status URLs cannot redirect API requests to another host', () async {
    final api = ApiClient(
      MockClient((_) async => throw StateError('Unexpected request')),
      Uri.parse('https://nmdiet.ru/api/mobile/v1/'),
    );
    expect(
      () => api.getSigned('https://another.example/orders/1'),
      throwsA(isA<AppFailure>()),
    );
  });
  test('validation errors remain readable', () async {
    final api = ApiClient(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'errors': {
              'items': ['Товар больше недоступен.'],
            },
          }),
          422,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
      Uri.parse('https://nmdiet.ru/api/mobile/v1/'),
    );
    expect(
      () => api.post('cart/quote', {}),
      throwsA(
        isA<AppFailure>().having(
          (e) => e.message,
          'message',
          'Товар больше недоступен.',
        ),
      ),
    );
  });
}
