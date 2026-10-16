import 'package:flutter/material.dart';
import '../../../app/app_container.dart';
import '../domain/models.dart';
import 'view_models.dart';
import 'widgets.dart';
import 'order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.container});
  final AppContainer container;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final name = TextEditingController(),
      phone = TextEditingController(),
      email = TextEditingController();
  final city = TextEditingController(),
      address = TextEditingController(),
      comment = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.container.checkout.prepare();
    });
  }

  @override
  void dispose() {
    for (final controller in [name, phone, email, city, address, comment]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.container.checkout,
    builder: (_, child) {
      final vm = widget.container.checkout;
      return Scaffold(
        appBar: AppBar(title: const Text('Оформление заказа')),
        body: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Контактные данные',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: name,
                autofillHints: const [AutofillHints.name],
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Имя и фамилия'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: const InputDecoration(labelText: 'Телефон'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 30),
              Text('Доставка', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: city,
                autofillHints: const [AutofillHints.addressCity],
                decoration: const InputDecoration(labelText: 'Город'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: address,
                minLines: 2,
                maxLines: 3,
                autofillHints: const [AutofillHints.fullStreetAddress],
                decoration: const InputDecoration(
                  labelText: 'Адрес или пункт выдачи',
                ),
              ),
              const SizedBox(height: 16),
              if (vm.quote != null)
                DropdownButtonFormField<String>(
                  key: ValueKey(vm.delivery),
                  initialValue: vm.delivery,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Способ доставки',
                  ),
                  items: vm.quote!.deliveries
                      .map(
                        (option) => DropdownMenuItem(
                          value: option.id,
                          child: Text(
                            option.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: vm.busy
                      ? null
                      : (value) => vm.prepare(deliveryId: value),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: comment,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Комментарий к заказу',
                ),
              ),
              const SizedBox(height: 24),
              if (vm.busy) const LinearProgressIndicator(),
              if (vm.error != null) ...[
                Notice(vm.error!),
                if (vm.quote == null)
                  TextButton.icon(
                    onPressed: vm.busy ? null : vm.prepare,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Обновить стоимость'),
                  ),
              ],
              if (vm.quote != null) ...[
                PriceRow('Товары', vm.quote!.subtotalMinor),
                PriceRow('Доставка', vm.quote!.deliveryMinor),
                const Divider(),
                PriceRow('Итого', vm.quote!.totalMinor, emphasis: true),
              ],
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: vm.consent,
                onChanged: (value) => vm.acceptConsent(value ?? false),
                title: const Text(
                  'Согласен с условиями заказа и обработкой персональных данных',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await widget.container.links.open(
                      'https://nmdiet.ru/secret/law',
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(userError(e))));
                    }
                  }
                },
                child: const Text('Оферта и политика конфиденциальности'),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: vm.busy || vm.quote == null
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        final success = await vm.submit(
                          CheckoutDetails(
                            name: name.text,
                            phone: phone.text,
                            email: email.text,
                            city: city.text,
                            address: address.text,
                            comment: comment.text,
                          ),
                        );
                        if (success && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  OrderScreen(container: widget.container),
                            ),
                          );
                        }
                      },
                child: Text(
                  vm.busy ? 'Пожалуйста, подождите…' : 'Оформить заказ',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}
