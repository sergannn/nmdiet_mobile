import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmdiet_mobile/app/app_container.dart';
import 'package:nmdiet_mobile/app/theme.dart';
import 'package:nmdiet_mobile/features/shop/data/bundled_product_stories.dart';
import 'package:nmdiet_mobile/features/shop/presentation/product_screen.dart';
import 'package:nmdiet_mobile/features/shop/domain/product_story.dart';
import 'support/fakes.dart';

class ReadyStories implements ProductStoryRepository {
  ReadyStories(this.story);
  final ProductStory story;
  @override
  Future<ProductStory> product(String slug) => SynchronousFuture(story);
}

void main() {
  test('visual constants are centralized and the site font is used', () {
    expect(appTheme().textTheme.bodyMedium!.fontFamily, Brand.fontFamily);
    expect(appTheme().colorScheme.primary, AppColors.navy);
    for (final f
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.endsWith('.dart') &&
                  !f.path.endsWith('brand_config.dart'),
            )) {
      final source = f.readAsStringSync();
      expect(
        source,
        isNot(matches(r'Color\(0x|fontSize:\s*\d')),
        reason: f.path,
      );
    }
  });
  test('all eleven product stories and document images are present', () {
    final content =
        jsonDecode(
              File('assets/content/product_stories.json').readAsStringSync(),
            )
            as Map;
    expect(content.length, 11);
    for (final story in content.values) {
      expect(story['sections'], isNotEmpty);
      for (final section in story['sections']) {
        expect(section['title'], isNotEmpty);
        for (final image in section['images']) {
          expect(File(image['asset'] as String).existsSync(), isTrue);
        }
      }
    }
  });
  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets('branded product, composition and reviews at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fake = await testContainer();
      final loaded = await tester.runAsync(
        () => BundledProductStories(rootBundle).product('tipo-mix'),
      );
      expect(loaded!.sections, isNotEmpty);
      final app = AppContainer(
        catalog: fake.catalog,
        cart: fake.cart,
        favorites: fake.favorites,
        checkout: fake.checkout,
        products: fake.products,
        links: fake.links,
        stories: ReadyStories(loaded),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(),
          home: ProductScreen(container: app, product: product),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Йодид калия'), findsWidgets);
      final reviews = find.widgetWithText(TextButton, 'Отзывы покупателей');
      await tester.ensureVisible(reviews);
      await tester.tap(reviews);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Оставить отзыв').hitTestable(), findsOneWidget);
    });
  }
}
