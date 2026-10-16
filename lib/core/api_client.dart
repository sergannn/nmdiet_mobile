import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'failure.dart';

class ApiClient {
  ApiClient(this.client, this.baseUri);
  final http.Client client;
  final Uri baseUri;

  Future<Map<String, dynamic>> get(String path) =>
      _send('GET', baseUri.resolve(path));
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _send('POST', baseUri.resolve(path), body);
  Future<Map<String, dynamic>> getSigned(String url) {
    final uri = Uri.parse(url);
    if (uri.scheme != baseUri.scheme ||
        uri.host != baseUri.host ||
        uri.port != baseUri.port) {
      throw const AppFailure('Не удалось проверить адрес заказа.');
    }
    return _send('GET', uri);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    Uri uri, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final response =
          await (method == 'GET'
                  ? client.get(uri, headers: headers)
                  : client.post(uri, headers: headers, body: jsonEncode(body)))
              .timeout(const Duration(seconds: 30));
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (response.statusCode >= 400) {
        final errors = decoded['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final messages = errors.values.first;
          if (messages is List && messages.isNotEmpty) {
            throw AppFailure(messages.first.toString());
          }
        }
        throw AppFailure(
          response.statusCode == 429
              ? 'Слишком много запросов. Попробуйте чуть позже.'
              : response.statusCode == 403
              ? 'Ссылка заказа истекла. Обратитесь в поддержку.'
              : response.statusCode >= 500
              ? 'Сервис временно недоступен. Попробуйте ещё раз.'
              : 'Не удалось выполнить запрос. Обновите данные.',
        );
      }
      return decoded;
    } on AppFailure {
      rethrow;
    } on TimeoutException {
      throw const AppFailure('Сервер отвечает долго. Попробуйте ещё раз.');
    } on FormatException {
      throw const AppFailure('Не удалось прочитать ответ сервера.');
    } on http.ClientException {
      throw const AppFailure('Нет соединения с интернетом.');
    }
  }
}
