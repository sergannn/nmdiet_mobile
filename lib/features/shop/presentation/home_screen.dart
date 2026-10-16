import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import 'widgets.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.container,
    required this.openCatalog,
  });
  final AppContainer container;
  final VoidCallback openCatalog;
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => container.catalog.load(refresh: true),
    child: ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Container(
          color: AppColors.mist,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, size: 16, color: AppColors.blue),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Собственные формулы · Сделано в России',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/brand/products.webp',
          height: 200,
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NMDIET', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Собственные формулы.\nЛичный подход к качеству.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text('Биодобавки, созданные для себя и самых близких.'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: openCatalog,
                  child: const Text('Подобрать комплекс'),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Популярные продукты',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (container.catalog.loading &&
                  container.catalog.products.isEmpty)
                const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (container.catalog.error != null) ...[
                Notice(container.catalog.error!),
                OutlinedButton(
                  onPressed: () => container.catalog.load(refresh: true),
                  child: const Text('Попробовать снова'),
                ),
              ] else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisExtent: 294,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: container.catalog.featured.length,
                  itemBuilder: (_, i) {
                    final p = container.catalog.featured[i];
                    return ProductTile(
                      product: p,
                      favorite: container.favorites.ids.contains(p.id),
                      onFavorite: () => container.favorites.toggle(p.id),
                      onOpen: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ProductScreen(container: container, product: p),
                        ),
                      ),
                      onAdd: () {
                        container.cart.add(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${p.name} в корзине'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 18),
              Text(
                'За каждой формулой — люди',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/brand/founder.jpg',
                      width: 95,
                      height: 130,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Наталья Щеглова',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Основатель NMDIET, нутрициолог и разработчик рецептур.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'БАД. Не является лекарственным средством.',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
