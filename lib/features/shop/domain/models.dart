class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.category,
    required this.capsules,
    required this.imageUrl,
    required this.gallery,
    required this.benefits,
    required this.popular,
  });
  final int id;
  final String slug, name, description, category, capsules, imageUrl;
  final int priceMinor;
  final List<String> gallery, benefits;
  final bool popular;
}

class CatalogSnapshot {
  const CatalogSnapshot(this.products, {this.cached = false});
  final List<Product> products;
  final bool cached;
}

class CartLine {
  const CartLine(this.product, this.quantity);
  final Product product;
  final int quantity;
  int get totalMinor => product.priceMinor * quantity;
}

class BasketItem {
  const BasketItem(this.productId, this.quantity);
  final int productId, quantity;
}

class DeliveryOption {
  const DeliveryOption(this.id, this.name, this.priceMinor);
  final String id, name;
  final int priceMinor;
}

class BasketQuote {
  const BasketQuote({
    required this.subtotalMinor,
    required this.deliveryMinor,
    required this.totalMinor,
    required this.deliveries,
  });
  final int subtotalMinor, deliveryMinor, totalMinor;
  final List<DeliveryOption> deliveries;
}

class CheckoutDetails {
  const CheckoutDetails({
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.address,
    this.comment = '',
  });
  final String name, phone, email, city, address, comment;
  String? validate() {
    if (name.trim().isEmpty) return 'Укажите имя.';
    if (phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Проверьте номер телефона.';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      return 'Проверьте e-mail.';
    }
    if (city.trim().isEmpty || address.trim().isEmpty) {
      return 'Укажите город и адрес доставки.';
    }
    return null;
  }
}

class StoreOrder {
  const StoreOrder({
    required this.number,
    required this.totalMinor,
    required this.paymentStatus,
    required this.paymentUrl,
    required this.statusUrl,
  });
  final String number, paymentStatus, paymentUrl, statusUrl;
  final int totalMinor;
  bool get paid => paymentStatus == 'paid';
  bool get canceled => paymentStatus == 'canceled';
}

class ProductReview {
  const ProductReview(this.author, this.rating, this.text);
  final String author, text;
  final int rating;
}
