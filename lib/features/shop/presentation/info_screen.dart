import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import 'view_models.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.container});
  final AppContainer container;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('О NMDIET')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Image.asset(
          'assets/brand/products.webp',
          height: 180,
          fit: BoxFit.contain,
        ),
        Text(
          'Собственные формулы.\nЛичная ответственность.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        const Text(
          'NMDIET появился из личного запроса к качеству. Наталья Щеглова — основатель бренда, нутрициолог и разработчик рецептур.',
        ),
        const SizedBox(height: 24),
        for (final item in <(IconData, String, String)>[
          (Icons.person_outline, 'История бренда', 'nmdiet'),
          (Icons.menu_book_outlined, 'Библиотека нутриентов', 'library'),
          (Icons.local_shipping_outlined, 'Доставка и оплата', 'details'),
          (Icons.chat_bubble_outline, 'Контакты и поддержка', 'contacts'),
          (Icons.description_outlined, 'Правовая информация', 'law'),
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(item.$1, color: AppColors.blue),
            title: Text(item.$2),
            trailing: const Icon(Icons.open_in_new, size: 17),
            onTap: () async {
              try {
                await container.links.open(
                  'https://nmdiet.ru/secret/${item.$3}',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(userError(e))));
                }
              }
            },
          ),
        const SizedBox(height: 24),
        const Text(
          'БАД. Не является лекарственным средством.',
          style: Brand.caption,
        ),
      ],
    ),
  );
}
