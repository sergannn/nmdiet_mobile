import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmdiet_mobile/app/nmdiet_app.dart';
import 'support/fakes.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets('mobile shopping layout at $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = await testContainer();
      await tester.pumpWidget(NmdietApp(container: container));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Каталог').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('В корзину').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Корзина').last);
      await tester.pumpAndSettle();
      expect(find.text('Тиро-микс').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Перейти к оформлению'));
      await tester.pumpAndSettle();
      expect(find.text('Контактные данные'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
