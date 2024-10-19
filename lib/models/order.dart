import 'product.dart';

class Order {
  final String id; // Unique ID for the order
  final Map<Product, int> productsWithQuantities;

  Order(this.id, this.productsWithQuantities);

  double get finalPrice {
    return productsWithQuantities.entries.fold(0.0, (total, entry) {
      return total + (entry.key.price * entry.value);
    });
  }
}
