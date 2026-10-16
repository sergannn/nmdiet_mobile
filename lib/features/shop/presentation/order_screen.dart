import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import 'view_models.dart';
import 'widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, required this.container});
  final AppContainer container;
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.container.checkout.refreshOrder();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.container.checkout,
    builder: (_, child) {
      final vm = widget.container.checkout, order = vm.order;
      return Scaffold(
        appBar: AppBar(title: const Text('Мой заказ')),
        body: order == null
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Заказ пока не оформлен',
              )
            : ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  const SizedBox(height: 30),
                  Icon(
                    order.paid
                        ? Icons.check_circle_outline
                        : Icons.receipt_long_outlined,
                    size: 60,
                    color: order.paid ? AppColors.green : AppColors.blue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    order.paid ? 'Спасибо за заказ!' : 'Заказ оформлен',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(order.number, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Text(
                    money(order.totalMinor),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.paid
                        ? 'Оплата подтверждена'
                        : order.canceled
                        ? 'Оплата отменена'
                        : 'Оплата пока не подтверждена',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!order.paid &&
                      !order.canceled &&
                      order.paymentUrl.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () async {
                        try {
                          await widget.container.links.payment(
                            order.paymentUrl,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(userError(e))),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Перейти к оплате'),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: vm.busy ? null : vm.refreshOrder,
                    icon: const Icon(Icons.refresh),
                    label: Text(vm.busy ? 'Проверяем…' : 'Обновить статус'),
                  ),
                  if (vm.error != null) Notice(vm.error!),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      try {
                        await widget.container.links.open(
                          'https://nmdiet.ru/secret/contacts',
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(userError(e))));
                        }
                      }
                    },
                    child: const Text('Связаться с поддержкой'),
                  ),
                ],
              ),
      );
    },
  );
}
