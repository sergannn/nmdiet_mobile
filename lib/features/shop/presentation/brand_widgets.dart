import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../app/app_container.dart';
import 'info_screen.dart';
import 'view_models.dart';

class BrandHeader extends StatelessWidget implements PreferredSizeWidget {
  const BrandHeader({
    super.key,
    required this.container,
    required this.openCatalog,
    required this.openCart,
    this.back = false,
  });
  final AppContainer container;
  final VoidCallback openCatalog, openCart;
  final bool back;
  @override
  Size get preferredSize =>
      const Size.fromHeight(Brand.headerHeight + Brand.trustHeight);
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    child: SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: Brand.headerHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (back)
                    IconButton(
                      tooltip: 'Назад',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () => _menu(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(52, 48),
                      ),
                      child: const Text('МЕНЮ', style: Brand.trustProof),
                    ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: 'NMDIET',
                    image: true,
                    child: Image.asset(
                      Brand.logo,
                      width: 120,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    button: true,
                    label: 'Корзина',
                    child: InkWell(
                      onTap: openCart,
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 23),
                            const SizedBox(width: 5),
                            Text(
                              '${container.cart.count}',
                              style: Brand.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: Brand.trustHeight,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.mist,
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.line, width: .5),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Экспертный российский бренд',
                      style: Brand.trustTitle,
                    ),
                    Text(
                      '★ 4,9–5,0   ·   3 500+ отзывов на маркетплейсах',
                      style: Brand.trustProof,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  void _menu(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Brand.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Выбрать комплекс'),
              leading: const Icon(Icons.grid_view_outlined),
              onTap: () {
                Navigator.pop(sheet);
                openCatalog();
              },
            ),
            ListTile(
              title: const Text('Про NMDIET'),
              leading: const Icon(Icons.info_outline),
              onTap: () {
                Navigator.pop(sheet);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => InfoScreen(container: container),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Корзина'),
              leading: const Icon(Icons.shopping_bag_outlined),
              onTap: () {
                Navigator.pop(sheet);
                openCart();
              },
            ),
            for (final link in const [
              ('Доставка и оплата', 'details', Icons.local_shipping_outlined),
              ('Контакты', 'contacts', Icons.chat_bubble_outline),
              ('Библиотека', 'library', Icons.menu_book_outlined),
              ('Юридические документы', 'law', Icons.description_outlined),
            ])
              ListTile(
                title: Text(link.$1),
                leading: Icon(link.$3),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {
                  Navigator.pop(sheet);
                  openBrandLink(context, container, link.$2);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> openBrandLink(
  BuildContext context,
  AppContainer app,
  String path,
) async {
  try {
    await app.links.open('https://nmdiet.ru/secret/$path');
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userError(e))));
    }
  }
}

class BrandSection extends StatelessWidget {
  const BrandSection({
    super.key,
    this.eyebrow,
    required this.title,
    this.intro,
    required this.children,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Brand.gutter,
      vertical: 36,
    ),
  });
  final String? eyebrow, intro;
  final String title;
  final List<Widget> children;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: Brand.eyebrow),
          const SizedBox(height: 18),
        ],
        Text(title, style: Brand.sectionTitle),
        if (intro != null) ...[
          const SizedBox(height: 20),
          Text(intro!, style: Brand.body),
        ],
        const SizedBox(height: 28),
        ...children,
      ],
    ),
  );
}

class BrandPanel extends StatelessWidget {
  const BrandPanel({
    super.key,
    this.label,
    required this.title,
    this.text,
    this.child,
    this.color = AppColors.panel,
  });
  final String? label, text;
  final String title;
  final Widget? child;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 34),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Brand.panelRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: Brand.eyebrow),
          const SizedBox(height: 16),
        ],
        Text(title, style: Brand.cardTitle),
        if (text != null) ...[
          const SizedBox(height: 18),
          Text(text!, style: Brand.body),
        ],
        if (child != null) ...[const SizedBox(height: 20), child!],
      ],
    ),
  );
}

class BrandFooter extends StatelessWidget {
  const BrandFooter({
    super.key,
    required this.container,
    required this.openCatalog,
  });
  final AppContainer container;
  final VoidCallback openCatalog;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.mist,
    padding: const EdgeInsets.symmetric(horizontal: Brand.gutter, vertical: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NMDIET представлен на ведущих маркетплейсах',
          style: Brand.sectionTitle,
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            Text('OZON', style: Brand.cardTitle),
            Text('Wildberries', style: Brand.cardTitle),
            Text('Яндекс Маркет', style: Brand.cardTitle),
          ],
        ),
        const SizedBox(height: 32),
        Image.asset(Brand.logo, width: 120, height: 48),
        const SizedBox(height: 12),
        TextButton(
          onPressed: openCatalog,
          child: const Text('Выбрать комплекс'),
        ),
        for (final x in const [
          ('Доставка и оплата', 'details'),
          ('Контакты', 'contacts'),
          ('Правовая информация', 'law'),
        ])
          TextButton(
            onPressed: () => openBrandLink(context, container, x.$2),
            child: Text(x.$1),
          ),
        const SizedBox(height: 18),
        const Text(
          'БАД. Не является лекарственным средством.',
          style: Brand.caption,
        ),
      ],
    ),
  );
}
