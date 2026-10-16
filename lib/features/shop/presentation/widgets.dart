import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../domain/models.dart';

class ProductImage extends StatelessWidget {
  const ProductImage(this.product, {super.key, this.url});
  final Product product;
  final String? url;
  String get fallback {
    const bundled = {
      'coenzyme-q10.jpg',
      'curcumix.jpg',
      'dia-mix.jpg',
      'home-main.jpg',
      'magnesium-mix.jpg',
      'school-vitamins.jpg',
      'selenmethionine.jpg',
      'tipo-mix-30.jpg',
      'tipo-mix-90.jpg',
      'vitamin-b-complex-30.jpg',
      'vitamin-b-complex-60.jpg',
      'vitamin-c.jpg',
    };
    final filename = Uri.tryParse(
      url ?? product.imageUrl,
    )?.pathSegments.lastOrNull;
    if (bundled.contains(filename)) return 'assets/products/$filename';
    return 'assets/products/${product.slug == 'tipo-mix' ? 'tipo-mix-90' : product.slug}.jpg';
  }

  @override
  Widget build(BuildContext context) => Image.network(
    url ?? product.imageUrl,
    fit: BoxFit.contain,
    errorBuilder: (_, error, stack) => Image.asset(
      fallback,
      fit: BoxFit.contain,
      errorBuilder: (_, error, stack) => const Icon(
        Icons.medication_outlined,
        size: 56,
        color: AppColors.blue,
      ),
    ),
    loadingBuilder: (_, child, progress) => progress == null
        ? child
        : const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
  );
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.favorite,
    required this.onOpen,
    required this.onFavorite,
    required this.onAdd,
  });
  final Product product;
  final bool favorite;
  final VoidCallback onOpen, onFavorite, onAdd;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.catalog,
      border: Border.all(color: AppColors.line),
      borderRadius: BorderRadius.circular(Brand.tileRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  label: product.name,
                  button: true,
                  child: InkWell(
                    onTap: onOpen,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ColoredBox(
                        color: AppColors.white,
                        child: ProductImage(product),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  tooltip: favorite ? 'Убрать из избранного' : 'В избранное',
                  onPressed: onFavorite,
                  icon: Icon(
                    favorite ? Icons.favorite : Icons.favorite_border,
                    color: favorite ? AppColors.green : AppColors.muted,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: InkWell(
                  onTap: onOpen,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      product.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Brand.bodyInk.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                product.capsules,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Brand.small,
              ),
              const SizedBox(height: 8),
              Text(money(product.priceMinor), style: Brand.compactPrice),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Tooltip(
                  message: 'В корзину',
                  child: FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      textStyle: Brand.small,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Brand.tileRadius),
                      ),
                    ),
                    child: const Text('В корзину'),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onOpen,
                  child: const Text('Подробнее'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.blue),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (message != null) ...[
            const SizedBox(height: 10),
            Text(message!, textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    ),
  );
}

class Notice extends StatelessWidget {
  const Notice(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      text,
      style: Brand.small.copyWith(color: Theme.of(context).colorScheme.error),
    ),
  );
}

class PriceRow extends StatelessWidget {
  const PriceRow(this.label, this.amount, {super.key, this.emphasis = false});
  final String label;
  final int amount;
  final bool emphasis;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: emphasis ? Brand.cardTitle : Brand.small),
        ),
        Text(
          money(amount),
          style: emphasis ? Brand.compactPrice : Brand.bodyInk,
        ),
      ],
    ),
  );
}
