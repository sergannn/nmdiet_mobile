import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import 'checkout_screen.dart';
import 'order_screen.dart';
import 'product_screen.dart';
import 'widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.container,
    required this.openCatalog,
  });
  final AppContainer container;
  final VoidCallback openCatalog;
  @override
  Widget build(BuildContext context) {
    final vm = container.cart;
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        if (container.checkout.order != null)
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Мой заказ'),
            subtitle: Text(container.checkout.order!.number),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => OrderScreen(container: container),
              ),
            ),
          ),
        if (vm.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Notice(vm.error!),
          ),
        Expanded(
          child: vm.lines.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Корзина пока пустая',
                  message: 'Выберите комплекс в каталоге.',
                  action: FilledButton(
                    onPressed: openCatalog,
                    child: const Text('Открыть каталог'),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.lines.length,
                  separatorBuilder: (_, i) => const Divider(height: 32),
                  itemBuilder: (_, i) {
                    final line = vm.lines[i], p = line.product;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 110,
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ProductScreen(
                                  container: container,
                                  product: p,
                                ),
                              ),
                            ),
                            child: ProductImage(p),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(p.capsules),
                              const SizedBox(height: 8),
                              Text(
                                money(line.totalMinor),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  IconButton.outlined(
                                    tooltip: 'Уменьшить количество',
                                    onPressed: () =>
                                        vm.setQuantity(p.id, line.quantity - 1),
                                    icon: const Icon(Icons.remove, size: 17),
                                  ),
                                  SizedBox(
                                    width: 36,
                                    child: Text(
                                      '${line.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  IconButton.outlined(
                                    tooltip: 'Увеличить количество',
                                    onPressed: line.quantity >= 99
                                        ? null
                                        : () => vm.setQuantity(
                                            p.id,
                                            line.quantity + 1,
                                          ),
                                    icon: const Icon(Icons.add, size: 17),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Удалить товар',
                                    onPressed: () => vm.setQuantity(p.id, 0),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        if (vm.lines.isNotEmpty)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PriceRow('Товары', vm.subtotalMinor, emphasis: true),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => CheckoutScreen(container: container),
                        ),
                      ),
                      child: const Text('Перейти к оформлению'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
