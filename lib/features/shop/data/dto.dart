import '../domain/models.dart';

abstract final class ShopDto {
  static Product product(Map<String, dynamic> json) => Product(
    id: (json['id'] as num).toInt(),
    slug: json['slug'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    priceMinor: (json['price_minor'] as num).toInt(),
    category: json['category'] as String? ?? 'daily',
    capsules: json['capsules'] as String? ?? '',
    imageUrl: json['image_url'] as String,
    gallery: List<String>.from(json['gallery'] as List? ?? []),
    benefits: List<String>.from(json['benefits'] as List? ?? []),
    popular: json['is_popular'] == true,
  );
  static Map<String, dynamic> productJson(Product p) => {
    'id': p.id,
    'slug': p.slug,
    'name': p.name,
    'description': p.description,
    'price_minor': p.priceMinor,
    'category': p.category,
    'capsules': p.capsules,
    'image_url': p.imageUrl,
    'gallery': p.gallery,
    'benefits': p.benefits,
    'is_popular': p.popular,
  };
  static Map<String, dynamic> basket(
    List<BasketItem> items,
    String? delivery,
  ) => {
    'items': items
        .map((x) => {'product_id': x.productId, 'quantity': x.quantity})
        .toList(),
    if (delivery != null) 'delivery_method': delivery,
  };
  static BasketQuote quote(Map<String, dynamic> json) => BasketQuote(
    subtotalMinor: (json['subtotal_minor'] as num).toInt(),
    deliveryMinor: (json['delivery_minor'] as num).toInt(),
    totalMinor: (json['total_minor'] as num).toInt(),
    deliveries: (json['delivery_options'] as List)
        .map(
          (dynamic x) => DeliveryOption(
            x['id'] as String,
            x['name'] as String,
            (x['price_minor'] as num).toInt(),
          ),
        )
        .toList(),
  );
  static StoreOrder order(Map<String, dynamic> json) => StoreOrder(
    number: json['number'] as String,
    totalMinor: (json['total_minor'] as num).toInt(),
    paymentStatus: json['payment_status'] as String,
    paymentUrl: json['payment_url'] as String? ?? '',
    statusUrl: json['status_url'] as String,
  );
  static Map<String, dynamic> orderJson(StoreOrder o) => {
    'number': o.number,
    'total_minor': o.totalMinor,
    'payment_status': o.paymentStatus,
    'payment_url': o.paymentUrl,
    'status_url': o.statusUrl,
  };
}
