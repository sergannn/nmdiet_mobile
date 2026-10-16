import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import '../domain/models.dart';
import 'brand_widgets.dart';
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
  void _open(BuildContext context, Product p) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ProductScreen(container: container, product: p),
    ),
  );
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => container.catalog.load(refresh: true),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Brand.gutter,
            18,
            Brand.gutter,
            36,
          ),
          child: Column(
            children: [
              SizedBox(
                height: Brand.heroPhotoHeight,
                width: double.infinity,
                child: Image.asset(Brand.heroPhoto, fit: BoxFit.contain),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 34),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Brand.panelRadius),
                  image: const DecorationImage(
                    image: AssetImage(Brand.heroSurface),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NMDIET · БИОДОБАВКИ', style: Brand.eyebrow),
                    const SizedBox(height: 15),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Собственные\nформулы.',
                        style: Brand.heroTitle,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Личный подход к качеству.',
                      style: Brand.heroSubtitle,
                    ),
                    const SizedBox(height: 23),
                    const Text(
                      'Биодобавки, созданные основателем бренда для себя и самых близких людей.',
                      style: Brand.body,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 3,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Text(
                            '15 000+ покупателей выбрали NMDIET',
                            style: Brand.body,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: openCatalog,
                      child: const Text('Подобрать комплекс'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const _DeliveryBanner(),
        BrandSection(
          eyebrow: 'Популярные продукты',
          title: 'С чего часто начинают\nзнакомство с NMDIET',
          intro: 'Три комплекса для разных ежедневных задач.',
          children: [
            if (container.catalog.loading && container.catalog.products.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (container.catalog.error != null)
              Notice(container.catalog.error!)
            else
              SizedBox(
                height: 456,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _featured.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 14),
                  itemBuilder: (_, i) {
                    final p = _featured[i];
                    return SizedBox(
                      width: 288,
                      child: _EditorialProduct(
                        product: p,
                        onOpen: () => _open(context, p),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: openCatalog,
              child: const Text('Смотреть весь каталог'),
            ),
          ],
        ),
        BrandSection(
          eyebrow: 'Подход NMDIET',
          title: 'Формулы, в которых нет\nслучайных компонентов.',
          intro:
              'Каждый микроэлемент должен работать на вашу задачу. Поэтому при разработке продуктов мы начинаем не со списка популярных ингредиентов, а с выбора оптимального сочетания веществ для конкретного запроса.',
          children: [
            BrandPanel(
              label: 'Собственные формулы',
              title: 'Биокомплексы NMDIET — собственная разработка бренда.',
              text:
                  'Синергия активных компонентов, их формы и дозировки подбираются для каждого продукта отдельно. Наши рецептуры не повторяют готовых решений.',
              color: AppColors.catalog,
              child: Image.asset(
                'assets/brand/site/tiro.webp',
                height: 220,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const BrandPanel(
              label: 'Формы и биодоступность',
              title:
                  'Витамины в активных формах, минералы высокой биодоступности.',
              text:
                  'При выборе сырья обращаем внимание на биохимическую форму вещества и отдаём предпочтение только подходящим для рецептуры характеристикам.',
            ),
            const BrandPanel(
              label: 'Принцип чистого состава',
              title: 'Лаконичные рецептуры без дополнительных ингредиентов.',
              text:
                  'Вспомогательные компоненты используем только тогда, когда они критически необходимы для производства или стабильности продукта.',
              color: AppColors.lavender,
            ),
            for (final fact in const [
              (
                'Государственная регистрация',
                'Каждый продукт NMDIET имеет свидетельство о государственной регистрации (СГР) и проверяется по единому реестру продукции ЕАЭС.',
              ),
              (
                'Документы и маркировка',
                'Все товары имеют обязательную маркировку и документы, предусмотренные для легального оборота в России.',
              ),
              (
                'Производство в Санкт-Петербурге',
                'Продукция NMDIET выпускается на сертифицированной производственной площадке в Санкт-Петербурге.',
              ),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 34, height: 3, color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(fact.$1, style: Brand.cardTitle),
                    const SizedBox(height: 12),
                    Text(fact.$2, style: Brand.body),
                  ],
                ),
              ),
            const BrandPanel(
              label: 'Личный принцип разработки рецептур создателя NMDIET',
              title:
                  '«Стала бы я принимать эту биодобавку сама? Посоветовала бы своим близким?»',
              color: AppColors.mist,
            ),
          ],
        ),
        BrandSection(
          title: 'Выберите продукт под свою задачу',
          children: [
            if (container.catalog.products.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisExtent: Brand.tileHeight,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: container.catalog.products.length,
                itemBuilder: (_, i) {
                  final p = container.catalog.products[i];
                  return ProductTile(
                    product: p,
                    favorite: container.favorites.ids.contains(p.id),
                    onFavorite: () => container.favorites.toggle(p.id),
                    onOpen: () => _open(context, p),
                    onAdd: () => container.cart.add(p),
                  );
                },
              ),
          ],
        ),
        BrandSection(
          eyebrow: 'Официальный интернет-магазин',
          title: 'Покупать на сайте NMDIET — удобно и выгодно',
          children: [
            const BrandPanel(
              title: 'Продукция напрямую от производителя',
              text: 'Официальный магазин NMDIET',
              color: AppColors.mist,
            ),
            const BrandPanel(
              title: 'Полный ассортимент',
              text: 'Выберите продукты для себя и самых близких.',
            ),
            OutlinedButton(
              onPressed: openCatalog,
              child: const Text('Перейти в каталог'),
            ),
          ],
        ),
        BrandSection(
          eyebrow: 'О создателе NMDIET',
          title: 'NMDIET появился из очень личного запроса к качеству.',
          children: [
            const Text(
              'Я создала NMDIET как практикующий нутрициолог, потому что не всегда могла найти готовые комплексы с теми формами веществ, сочетаниями и дозировками, которые считала оптимальными.',
              style: Brand.bodyInk,
            ),
            const SizedBox(height: 24),
            const Text(
              'Так появились собственные рецептуры NMDIET — сначала для меня и моей семьи, а затем для людей, которым так же важно понимать, что именно они принимают.',
              style: Brand.body,
            ),
            const SizedBox(height: 24),
            const BrandPanel(
              title:
                  '«Стала бы я принимать эту биодобавку сама? Посоветовала бы своим близким?»',
              text:
                  'Мой личный критерий при разработке каждого нового продукта NMDIET.',
              color: AppColors.mist,
            ),
            const SizedBox(height: 12),
            const Text('Наталья', style: Brand.cardTitle),
            const Text(
              'Основатель NMDIET · практикующий нутрициолог',
              style: Brand.small,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => openBrandLink(context, container, 'nmdiet'),
              child: const Text('История NMDIET'),
            ),
            const SizedBox(height: 28),
            Image.asset(
              Brand.founderPhoto,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ],
        ),
        BrandFooter(container: container, openCatalog: openCatalog),
      ],
    ),
  );
  List<Product> get _featured {
    final all = container.catalog.products;
    final selected = [
      for (final slug in ['tipo-mix', 'coenzyme-q10', 'magnesium-mix'])
        ...all.where((p) => p.slug == slug),
    ];
    return selected.isEmpty ? container.catalog.featured : selected;
  }
}

class _EditorialProduct extends StatelessWidget {
  const _EditorialProduct({required this.product, required this.onOpen});
  final Product product;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final art = switch (product.slug) {
      'tipo-mix' => 'tiro',
      'coenzyme-q10' => 'cardio',
      'magnesium-mix' => 'magnesium',
      _ => null,
    };
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(Brand.panelRadius),
      child: Container(
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          color: AppColors.panel,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(Brand.panelRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: art == null
                  ? ProductImage(product)
                  : Image.asset(
                      'assets/brand/site/$art.webp',
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 18),
            Text(product.capsules, style: Brand.caption),
            const SizedBox(height: 8),
            Text(product.name, style: Brand.cardTitle),
            const SizedBox(height: 12),
            Text(
              product.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Brand.small,
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Подробнее', style: Brand.small),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryBanner extends StatelessWidget {
  const _DeliveryBanner();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Brand.gutter, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('OZON', style: Brand.cardTitle),
        const SizedBox(height: 16),
        const Text('У вас есть аккаунт в Ozon?', style: Brand.eyebrow),
        const SizedBox(height: 10),
        const Text(
          'Отправляем заказы на сайте в пункты выдачи Ozon',
          style: Brand.cardTitle,
        ),
        const SizedBox(height: 12),
        const Text(
          'Заберите заказ в удобном пункте рядом с домом.',
          style: Brand.body,
        ),
        const SizedBox(height: 8),
        const Text(
          'Выбор адреса ПВЗ — при оформлении заказа на сайте',
          style: Brand.caption,
        ),
      ],
    ),
  );
}
