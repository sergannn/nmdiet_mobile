import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/repositories.dart';

class PreferenceStore implements CollectionRepository {
  PreferenceStore(this.preferences);
  final SharedPreferencesAsync preferences;
  Future<void> _writes = Future.value();
  Future<String?> read(String key) => preferences.getString(key);
  Future<void> write(String key, String value) {
    final next = _writes
        .catchError((Object _) {})
        .then((_) => preferences.setString(key, value));
    _writes = next;
    return next;
  }

  Future<void> remove(String key) => preferences.remove(key);

  @override
  Future<Map<int, int>> readCart() async {
    try {
      final decoded =
          jsonDecode(await read('cart.v1') ?? '{}') as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          if (int.tryParse(entry.key) != null &&
              entry.value is int &&
              entry.value > 0)
            int.parse(entry.key): (entry.value as int).clamp(1, 99),
      };
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  @override
  Future<void> writeCart(Map<int, int> items) => write(
    'cart.v1',
    jsonEncode(items.map((key, value) => MapEntry(key.toString(), value))),
  );
  @override
  Future<Set<int>> readFavorites() async {
    try {
      return (jsonDecode(await read('favorites.v1') ?? '[]') as List)
          .whereType<int>()
          .toSet();
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  @override
  Future<void> writeFavorites(Set<int> ids) =>
      write('favorites.v1', jsonEncode(ids.toList()));
}
