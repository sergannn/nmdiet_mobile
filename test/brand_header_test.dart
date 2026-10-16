import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmdiet_mobile/app/theme.dart';
import 'package:nmdiet_mobile/features/shop/presentation/brand_widgets.dart';
import 'support/fakes.dart';

void main() {
  test('header typography preserves donor emphasis', () {
    expect(Brand.headerMenu.fontWeight, FontWeight.w500);
    expect(Brand.trustTitle.fontWeight, FontWeight.w500);
    expect(Brand.trustProof.fontWeight, FontWeight.w400);
    expect(Brand.trustStrong.fontWeight, FontWeight.w600);
  });
  for (final width in [320.0, 390.0, 430.0, 768.0]) {
    for (final back in [false, true]) {
      testWidgets('header keeps opposite edges at $width, back=$back', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final app = await testContainer();
        var openedCart = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme(),
            home: Scaffold(
              appBar: BrandHeader(
                container: app,
                openCatalog: () {},
                openCart: () => openedCart = true,
                back: back,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final row = tester.widget<Row>(
          find.byKey(const ValueKey('brand-header-row')),
        );
        expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
        final menu = tester.getRect(
          find.byKey(const ValueKey('brand-header-menu')),
        );
        final logo = tester.getRect(
          find.byKey(const ValueKey('brand-header-logo')),
        );
        expect(menu.left, closeTo(Brand.headerGutter, .01));
        expect(logo.right, closeTo(width - Brand.headerGutter, .01));
        expect(logo.width, Brand.logoWidth);
        expect(menu.right, lessThan(logo.left));
        expect(menu.center.dy, closeTo(logo.center.dy, .01));
        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('МЕНЮ'));
        await tester.pumpAndSettle();
        expect(find.text('Назад'), back ? findsOneWidget : findsNothing);
        await tester.tap(find.text('Корзина'));
        await tester.pumpAndSettle();
        expect(openedCart, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
