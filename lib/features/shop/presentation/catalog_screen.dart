import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import 'product_screen.dart';
import 'widgets.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({
    super.key,
    required this.container,
    this.favoritesOnly = false,
  });
  final AppContainer container;
  final bool favoritesOnly;
  @override
  Widget build(BuildContext context) {
    final vm = container.catalog;
    final products = favoritesOnly
        ? vm.favorites(container.favorites.ids)
        : vm.visibleProducts;
    return Column(
      children: [
        if (!favoritesOnly) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              onChanged: vm.search,
              decoration: const InputDecoration(
                hintText: 'Найти комплекс',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children:
                  {
                        'all': 'Все',
                        'daily': 'На каждый день',
                        'women': 'Для женщин',
                        'kids': 'Для детей',
                      }.entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              e.value,
                              style: Brand.small.copyWith(
                                color: vm.category == e.key
                                    ? AppColors.white
                                    : AppColors.ink,
                              ),
                            ),
                            selected: vm.category == e.key,
                            showCheckmark: false,
                            onSelected: (_) => vm.selectCategory(e.key),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
        if (vm.cached)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.cloud_off_outlined, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Сохранённый каталог', style: Brand.caption),
                ),
                IconButton(
                  tooltip: 'Обновить каталог',
                  onPressed: () => vm.load(refresh: true),
                  icon: const Icon(Icons.refresh, size: 19),
                ),
              ],
            ),
          ),
        Expanded(
          child: vm.loading && vm.products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.error != null && vm.products.isEmpty
              ? EmptyState(
                  icon: Icons.wifi_off,
                  title: 'Не удалось загрузить каталог',
                  message: vm.error,
                  action: FilledButton(
                    onPressed: () => vm.load(refresh: true),
                    child: const Text('Повторить'),
                  ),
                )
              : products.isEmpty
              ? EmptyState(
                  icon: favoritesOnly
                      ? Icons.favorite_border
                      : Icons.search_off,
                  title: favoritesOnly
                      ? 'Пока нет избранного'
                      : 'Ничего не найдено',
                  message: favoritesOnly
                      ? 'Сохраните понравившиеся продукты.'
                      : 'Попробуйте другой запрос или категорию.',
                )
              : RefreshIndicator(
                  onRefresh: () => vm.load(refresh: true),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(Brand.gutter),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          mainAxisExtent: Brand.tileHeight,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
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
                ),
        ),
        if (container.favorites.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              container.favorites.error!,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
      ],
    );
  }
}
