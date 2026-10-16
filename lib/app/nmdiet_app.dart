import 'package:flutter/material.dart';
import '../features/shop/presentation/home_screen.dart';
import '../features/shop/presentation/catalog_screen.dart';
import '../features/shop/presentation/cart_screen.dart';
import '../features/shop/presentation/info_screen.dart';
import 'app_container.dart';
import 'theme.dart';

class NmdietApp extends StatelessWidget {
  const NmdietApp({super.key, required this.container});
  final AppContainer container;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NMDIET',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: _Shell(container: container),
  );
}

class _Shell extends StatefulWidget {
  const _Shell({required this.container});
  final AppContainer container;
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int index = 0;
  void openCatalog() => setState(() => index = 1);
  @override
  Widget build(BuildContext context) {
    final app = widget.container;
    return AnimatedBuilder(
      animation: Listenable.merge([
        app.catalog,
        app.cart,
        app.favorites,
        app.checkout,
      ]),
      builder: (_, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            ['NMDIET', 'Каталог', 'Избранное', 'Корзина'][index],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 23),
          ),
          actions: [
            IconButton(
              tooltip: 'О бренде и поддержка',
              icon: const Icon(Icons.info_outline),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => InfoScreen(container: app),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: IndexedStack(
                index: index,
                children: [
                  HomeScreen(container: app, openCatalog: openCatalog),
                  CatalogScreen(container: app),
                  CatalogScreen(container: app, favoritesOnly: true),
                  CartScreen(container: app, openCatalog: openCatalog),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Каталог',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Избранное',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: app.cart.count > 0,
                label: Text('${app.cart.count}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: const Icon(Icons.shopping_bag),
              label: 'Корзина',
            ),
          ],
        ),
      ),
    );
  }
}
