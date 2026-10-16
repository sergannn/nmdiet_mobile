import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../domain/models.dart';
import '../domain/product_story.dart';
import 'brand_widgets.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'view_models.dart';
import 'widgets.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.container,
    required this.product,
  });
  final AppContainer container;
  final Product product;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final gallery = PageController();
  final reviewsKey = GlobalKey();
  late final ReviewsViewModel reviews;
  late final Future<ProductStory> story;
  int photo = 0;
  @override
  void initState() {
    super.initState();
    reviews = ReviewsViewModel(widget.container.products, widget.product.slug)
      ..load();
    story = widget.container.stories.product(widget.product.slug);
  }

  @override
  void dispose() {
    gallery.dispose();
    reviews.dispose();
    super.dispose();
  }

  void _catalog() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Каталог')),
        body: CatalogScreen(container: widget.container),
      ),
    ),
  );
  void _cart() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Корзина')),
        body: CartScreen(container: widget.container, openCatalog: _catalog),
      ),
    ),
  );
  void _add() {
    widget.container.cart.add(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Добавлено в корзину'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product, app = widget.container;
    final images = p.gallery.isEmpty ? [p.imageUrl] : p.gallery;
    return AnimatedBuilder(
      animation: Listenable.merge([app.favorites, app.cart, reviews]),
      builder: (_, child) => Scaffold(
        appBar: BrandHeader(
          container: app,
          openCatalog: _catalog,
          openCart: _cart,
          back: true,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Brand.pageWidth),
            child: FutureBuilder<ProductStory>(
              future: story,
              builder: (_, snapshot) {
                final content = snapshot.data ?? const ProductStory();
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: Brand.productPhotoHeight,
                        child: PageView.builder(
                          controller: gallery,
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => photo = i),
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(14, 24, 14, 4),
                            child: ProductImage(p, url: images[i]),
                          ),
                        ),
                      ),
                      if (images.length > 1)
                        SizedBox(
                          height: 72,
                          child: Center(
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              separatorBuilder: (_, i) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) => Semantics(
                                label: 'Фото ${i + 1}',
                                button: true,
                                selected: i == photo,
                                child: InkWell(
                                  onTap: () => gallery.animateToPage(
                                    i,
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                  ),
                                  child: Container(
                                    width: 58,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 7,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: i == photo
                                            ? AppColors.blue
                                            : AppColors.line,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        Brand.fieldRadius,
                                      ),
                                    ),
                                    child: ProductImage(p, url: images[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NMDIET · СОБСТВЕННАЯ ФОРМУЛА',
                              style: Brand.productEyebrow,
                            ),
                            const SizedBox(height: 10),
                            Text(p.name, style: Brand.productTitle),
                            if (content.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                content.subtitle,
                                style: Brand.bodyInk.copyWith(
                                  color: AppColors.softBlue,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(left: 14),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.accent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (content.concept.isNotEmpty) ...[
                                    Text(content.concept, style: Brand.bodyInk),
                                    const SizedBox(height: 10),
                                  ],
                                  Text(p.description, style: Brand.small),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text('ОБЪЁМ', style: Brand.eyebrow),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final item in _variants)
                                  OutlinedButton(
                                    onPressed: item.id == p.id
                                        ? null
                                        : () => Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (_) => ProductScreen(
                                                container: app,
                                                product: item,
                                              ),
                                            ),
                                          ),
                                    style: OutlinedButton.styleFrom(
                                      disabledForegroundColor: AppColors.ink,
                                      backgroundColor: item.id == p.id
                                          ? AppColors.catalog
                                          : AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          Brand.fieldRadius,
                                        ),
                                      ),
                                    ),
                                    child: Text(item.capsules),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(money(p.priceMinor), style: Brand.price),
                            const SizedBox(height: 8),
                            const Text(
                              'Специальная цена официального сайта',
                              style: Brand.caption,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _add,
                                child: const Text('В корзину'),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              children: [
                                TextButton.icon(
                                  onPressed: () => app.favorites.toggle(p.id),
                                  icon: Icon(
                                    app.favorites.ids.contains(p.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20,
                                  ),
                                  label: Text(
                                    app.favorites.ids.contains(p.id)
                                        ? 'В избранном'
                                        : 'В избранное',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Scrollable.ensureVisible(
                                    reviewsKey.currentContext!,
                                    duration: const Duration(milliseconds: 350),
                                  ),
                                  child: const Text('Отзывы покупателей'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      for (final section in content.sections)
                        _StorySection(section: section),
                      if (content.sections.isEmpty)
                        BrandSection(
                          eyebrow: 'О продукте',
                          title: p.name,
                          intro: p.description,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => openBrandLink(
                                context,
                                app,
                                'products/${p.slug}',
                              ),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Полная информация'),
                            ),
                          ],
                        ),
                      BrandSection(
                        key: reviewsKey,
                        eyebrow: 'Отзывы',
                        title: 'Отзывы покупателей',
                        children: [
                          if (reviews.loading)
                            const Center(child: CircularProgressIndicator()),
                          if (reviews.error != null) Notice(reviews.error!),
                          if (!reviews.loading && reviews.reviews.isEmpty)
                            const Text(
                              'Пока нет опубликованных отзывов.',
                              style: Brand.body,
                            ),
                          for (final r in reviews.reviews)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.author, style: Brand.cardTitle),
                                  Text(
                                    '★' * r.rating,
                                    style: Brand.bodyInk.copyWith(
                                      color: AppColors.rating,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(r.text, style: Brand.body),
                                  const Divider(),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: reviews.loading
                                ? null
                                : () => _writeReview(context),
                            icon: const Icon(Icons.rate_review_outlined),
                            label: const Text('Оставить отзыв'),
                          ),
                        ],
                      ),
                      BrandFooter(container: app, openCatalog: _catalog),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Product> get _variants {
    final p = widget.product;
    final family = p.slug.startsWith('tipo-mix')
        ? 'tipo-mix'
        : p.slug.startsWith('vitamin-b-complex')
        ? 'vitamin-b-complex'
        : p.slug;
    final all = widget.container.catalog.products
        .where((x) => x.slug == family || x.slug.startsWith('$family-'))
        .toList();
    return all.isEmpty ? [p] : all;
  }

  Future<void> _writeReview(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ReviewDialog(reviews: reviews),
    );
    if (context.mounted && reviews.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(reviews.message!)));
    }
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection({required this.section});
  final StorySection section;
  @override
  Widget build(BuildContext context) => BrandSection(
    eyebrow: section.eyebrow.isEmpty ? null : section.eyebrow,
    title: section.title,
    children: [
      for (final b in section.blocks)
        if (b.kind == 'component')
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.title, style: Brand.cardTitle),
                      const SizedBox(height: 4),
                      Text(b.text, style: Brand.small),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(b.value, style: Brand.bodyInk),
              ],
            ),
          )
        else if (b.kind == 'panel')
          BrandPanel(title: b.text, color: AppColors.mist)
        else
          Padding(
            padding: EdgeInsets.only(
              bottom: 18,
              top: b.kind == 'heading' ? 16 : 0,
            ),
            child: Text(
              b.text,
              style: b.kind == 'heading' ? Brand.cardTitle : Brand.body,
            ),
          ),
      for (final asset in section.images)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: InkWell(
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => Dialog.fullscreen(
                child: Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        minScale: .5,
                        maxScale: 5,
                        child: Image.asset(asset),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton.filled(
                        tooltip: 'Закрыть',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Image.asset(
              asset,
              width: double.infinity,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
        ),
    ],
  );
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.reviews});
  final ReviewsViewModel reviews;
  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final author = TextEditingController(), text = TextEditingController();
  int rating = 5;
  @override
  void dispose() {
    author.dispose();
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.reviews,
    builder: (_, child) => AlertDialog(
      title: const Text('Ваш отзыв'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: author,
                decoration: const InputDecoration(labelText: 'Имя'),
                maxLength: 255,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: rating,
                decoration: const InputDecoration(labelText: 'Оценка'),
                items: [
                  for (final n in [5, 4, 3, 2, 1])
                    DropdownMenuItem(value: n, child: Text('$n из 5')),
                ],
                onChanged: (v) => setState(() => rating = v!),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: text,
                minLines: 3,
                maxLines: 6,
                maxLength: 3000,
                decoration: const InputDecoration(labelText: 'Отзыв'),
              ),
              if (widget.reviews.error != null) Notice(widget.reviews.error!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.reviews.loading
              ? null
              : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: widget.reviews.loading
              ? null
              : () async {
                  if (await widget.reviews.submit(
                        author.text,
                        rating,
                        text.text,
                      ) &&
                      context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: Text(widget.reviews.loading ? 'Отправка…' : 'Отправить'),
        ),
      ],
    ),
  );
}
