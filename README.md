# NMDIET Mobile

Flutter application for iOS and Android. Native Flutter UI, not an embedded website. Product information comes from the existing Laravel/MoonShine database.

## Structure

- `lib/features/shop/domain`: framework-independent models and repository contracts.
- `lib/features/shop/data`: API mapping, repositories and local storage.
- `lib/features/shop/presentation`: screens and observable view models.
- `lib/core`: HTTP transport, errors, currency formatting and external links.
- `lib/app`: explicit dependency injection, theme and navigation shell.

Presentation and data depend on domain contracts. HTTP, storage and navigation can be replaced in tests. There is no global repository singleton or generated service locator.

## Run

```sh
flutter pub get
flutter run
flutter test
flutter analyze
flutter build apk --debug
flutter build ios --simulator --debug
```

Default API: `https://nmdiet.ru/api/mobile/v1/`. Override with `--dart-define=API_BASE_URL=https://your-host/api/mobile/v1/`. Use HTTPS outside local development.

## Implemented

Home, searchable/filterable catalog, product gallery, moderated reviews, favorites, persistent basket, native checkout, delivery selection and payment status. Previously loaded products remain available offline; checkout requires connectivity.

Payment opens the provider's HTTPS page in the system browser. Secrets remain on the server. Prices are calculated from published products, the quoted total is validated and duplicate submissions share an idempotency key. Payment status is confirmed with the provider and refreshed when returning to the app. Available payment methods depend on the merchant account settings.

Basket storage contains product IDs and quantities, not authoritative prices. Contact/address fields are not persisted. The last order includes a signed status URL; device storage/backups should be treated as sensitive. Status links expire after seven days.

## GitHub Pages

Repository: https://github.com/sergannn/nmdiet_mobile

Preview: https://sergannn.github.io/nmdiet_mobile/

`.github/workflows/pages.yml` pins Flutter 3.35.3, restores locked dependencies, runs analysis/tests and builds `build/web`. Pushes to `main` deploy that artifact through GitHub Pages; pull requests only run checks/build. Builds use `/nmdiet_mobile/` as the base path and the existing production API. Do not commit generated `build/` files or server secrets. Pages serves only the Flutter frontend; Laravel and its database stay on the current hosting account.

## Backend API

Companion Laravel changes are in `../nmdiet_build_l12_20260805_015010`: mobile routes, controllers, requests, resources, checkout services and an additive orders migration. API tests: `tests/Feature/MobileApiTest.php`.

Endpoints: `GET products`, `GET products/{slug}`, `GET products/{slug}/reviews`, `POST products/{slug}/reviews`, `POST cart/quote`, `POST orders`, signed `GET orders/{id}`. Money uses integer kopecks. New reviews require moderation.

Delivery uses the existing site's delivery-rate service, not live carrier quotes, pickup-point widgets or label creation. Existing MAX/MoySklad adapters remain server-side and require working account configuration.

## Release Boundaries

No real charge was made during development. Production signing/icons, privacy declarations, registered return deep links and App Store/Google Play submission are separate release work. A browser preview demonstrates shared UI, not physical-device/store readiness.
