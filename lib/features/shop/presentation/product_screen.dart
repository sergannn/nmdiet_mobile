import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../domain/models.dart';
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
  late final ReviewsViewModel reviews;
  int photo = 0, tab = 0;
  @override
  void initState() {
    super.initState();
    reviews = ReviewsViewModel(widget.container.products, widget.product.slug)
      ..load();
  }

  @override
  void dispose() {
    gallery.dispose();
    reviews.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.gallery.isEmpty ? [p.imageUrl] : p.gallery;
    return AnimatedBuilder(
      animation: Listenable.merge([widget.container.favorites, reviews]),
      builder: (_, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Продукт'),
          actions: [
            IconButton(
              tooltip: 'В избранное',
              onPressed: () => widget.container.favorites.toggle(p.id),
              icon: Icon(
                widget.container.favorites.ids.contains(p.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: gallery,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => photo = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  child: ProductImage(p, url: images[i]),
                ),
              ),
            ),
            if (images.length > 1)
              SizedBox(
                height: 62,
                child: Center(
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, i) => const SizedBox(width: 8),
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: i == photo
                                  ? AppColors.blue
                                  : AppColors.line,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ProductImage(p, url: images[i]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(p.capsules),
                  const SizedBox(height: 22),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('О продукте')),
                      ButtonSegment(value: 1, label: Text('Отзывы')),
                    ],
                    selected: {tab},
                    onSelectionChanged: (s) => setState(() => tab = s.first),
                  ),
                  const SizedBox(height: 22),
                  if (tab == 0) ...[
                    Text(
                      p.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await widget.container.links.open(
                            'https://nmdiet.ru/secret/products/${p.slug}',
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(userError(e))),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 17),
                      label: const Text('Состав и рекомендации'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'БАД. Не является лекарственным средством.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ] else ...[
                    if (reviews.loading)
                      const Center(child: CircularProgressIndicator()),
                    if (reviews.error != null) Notice(reviews.error!),
                    if (!reviews.loading && reviews.reviews.isEmpty)
                      const Text('Пока нет опубликованных отзывов.'),
                    for (final review in reviews.reviews)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              '★' * review.rating,
                              style: const TextStyle(color: Color(0xFFAE7620)),
                            ),
                            const SizedBox(height: 6),
                            Text(review.text),
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
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    money(p.priceMinor),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    widget.container.cart.add(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Добавлено в корзину'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 19),
                  label: const Text('В корзину'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _writeReview(BuildContext context) async {
    final author = TextEditingController(), text = TextEditingController();
    int rating = 5;
    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (_, setDialog) => AnimatedBuilder(
          animation: reviews,
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
                      items: [5, 4, 3, 2, 1]
                          .map(
                            (n) => DropdownMenuItem(
                              value: n,
                              child: Text('$n из 5'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setDialog(() => rating = value!),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: text,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 3000,
                      decoration: const InputDecoration(labelText: 'Отзыв'),
                    ),
                    if (reviews.error != null) Notice(reviews.error!),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: reviews.loading ? null : () => Navigator.pop(dialog),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: reviews.loading
                    ? null
                    : () async {
                        if (await reviews.submit(
                              author.text,
                              rating,
                              text.text,
                            ) &&
                            dialog.mounted) {
                          Navigator.pop(dialog);
                        }
                      },
                child: Text(reviews.loading ? 'Отправка…' : 'Отправить'),
              ),
            ],
          ),
        ),
      ),
    );
    author.dispose();
    text.dispose();
    if (context.mounted && reviews.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(reviews.message!)));
    }
  }
}
