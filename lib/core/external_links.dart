import 'package:url_launcher/url_launcher.dart';
import 'failure.dart';

class ExternalLinks {
  Future<void> open(String url) async {
    final uri = Uri.parse(url);
    if (!['https', 'mailto', 'tel'].contains(uri.scheme) ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const AppFailure('Не удалось открыть ссылку. Попробуйте ещё раз.');
    }
  }

  Future<void> payment(String url) {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https' ||
        ![
          'yookassa.ru',
          'yoomoney.ru',
        ].any((host) => uri.host == host || uri.host.endsWith('.$host'))) {
      throw const AppFailure('Не удалось проверить адрес страницы оплаты.');
    }
    return open(url);
  }
}
