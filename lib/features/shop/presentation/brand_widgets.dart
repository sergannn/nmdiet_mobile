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
                            Image.asset(Brand.bag, width: 22, height: 22),
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
      child: SingleChildScrollView(
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      BrandSection(
        eyebrow: 'Где ещё купить NMDIET',
        title: 'NMDIET представлен на ведущих маркетплейсах',
        children: [
          LayoutBuilder(
            builder: (_, constraints) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final m in const [
                  (
                    'goldapple',
                    'Золотое Яблоко',
                    'https://goldapple.ru/brands/nmdiet',
                  ),
                  ('itab', 'Айтаб', 'https://itab.pro/brands/nmdiet-301/'),
                  ('ozon', 'Ozon', 'https://ozon.ru/s/nmdiet'),
                  (
                    'wb',
                    'Wildberries',
                    'https://www.wildberries.ru/seller/1333935',
                  ),
                  ('ym', 'Яндекс Маркет', 'https://market.yandex.ru/cc/93dG7C'),
                ])
                  Semantics(
                    label: 'NMDIET на ${m.$2}',
                    button: true,
                    child: InkWell(
                      onTap: () => _external(context, m.$3),
                      child: SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        height: 72,
                        child: Image.asset(
                          'assets/brand/site/market-${m.$1}.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Обратите внимание: наша оригинальная продукция представлена только по ссылкам из логотипов выше. Мы не сотрудничаем с другими продавцами на маркетплейсах. Остерегайтесь подделок!',
            style: Brand.small,
          ),
        ],
      ),
      Container(
        color: AppColors.footer,
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.gutter,
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NMDIET', style: Brand.heroTitle),
            const SizedBox(height: 16),
            const Text(
              'Собственные формулы.\nЛичный подход к качеству.',
              style: Brand.cardTitle,
            ),
            const SizedBox(height: 28),
            const Text('Подписаться', style: Brand.eyebrow),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final x in const [
                  ('VK', 'https://vk.ru/nmdiet'),
                  ('MAX', 'https://max.ru/channel_NMDIET'),
                  ('Telegram', 'https://t.me/nmdiet_russia'),
                ])
                  OutlinedButton(
                    onPressed: () => _external(context, x.$2),
                    child: Text(x.$1),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Связаться с нами', style: Brand.eyebrow),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final x in const [
                  ('Email', 'mailto:nmd_spb@bk.ru'),
                  (
                    'Поддержка в MAX',
                    'https://max.ru/u/f9LHodD0cOKHp1VW5Q_uNwI4WLMkXaHin9S8Yx3fz9iTcs9SkfgjVsaYczM',
                  ),
                  ('Поддержка в Telegram', 'https://t.me/nmdiet_ask'),
                ])
                  OutlinedButton(
                    onPressed: () => _external(context, x.$2),
                    child: Text(x.$1),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Покупателям', style: Brand.cardTitle),
            TextButton(onPressed: openCatalog, child: const Text('Каталог')),
            for (final x in const [
              ('Доставка и оплата', 'details'),
              ('Контакты', 'contacts'),
              ('Об основателе', 'nmdiet'),
              ('Где купить', 'contacts'),
            ])
              TextButton(
                onPressed: () => openBrandLink(context, container, x.$2),
                child: Text(x.$1),
              ),
            const SizedBox(height: 24),
            const Text('Правовая информация', style: Brand.cardTitle),
            for (final x in const [
              ('Публичная оферта', 'law#law-offer'),
              ('Политика конфиденциальности', 'law#law-privacy'),
              ('Согласие на обработку персональных данных', 'law#law-personal'),
              ('Согласие на рассылку', 'law#law-advertising'),
              ('Все юридические документы', 'law'),
            ])
              TextButton(
                onPressed: () => openBrandLink(context, container, x.$2),
                child: Text(x.$1),
              ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'БАД. НЕ ЯВЛЯЕТСЯ ЛЕКАРСТВЕННЫМ СРЕДСТВОМ.',
              style: Brand.small,
            ),
            const SizedBox(height: 24),
            const Text('Изготовитель', style: Brand.eyebrow),
            const SizedBox(height: 12),
            const Text(
              'ООО «ТПК «САМОРАЗВИТИЕ», 195269, Россия, г. Санкт-Петербург, ул. Учительская, д. 23, литер А, помещение 228-229.',
              style: Brand.small,
            ),
            const SizedBox(height: 24),
            const Text('Продавец', style: Brand.eyebrow),
            const SizedBox(height: 12),
            const Text(
              'ИП Щеглова Наталья Юрьевна\nИНН 780436111943\nОГРНИП 323784700227571\n194021, Россия, Санкт-Петербург, Политехническая 17/3',
              style: Brand.small,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _external(context, 'tel:+79311194959'),
              child: const Text('+7 931 119-49-59'),
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2022–2026 NMDIET\nВсе права защищены',
              style: Brand.caption,
            ),
          ],
        ),
      ),
    ],
  );
  Future<void> _external(BuildContext context, String url) async {
    try {
      await container.links.open(url);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userError(e))));
      }
    }
  }
}
