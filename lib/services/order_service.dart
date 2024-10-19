import 'package:collection/collection.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderService {
  final List<Order> _orders = [];

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  
  void createOrder(Map<Product, int> productsWithQuantities) {
    if (productsWithQuantities.isEmpty) {
      throw ArgumentError('Order must contain at least one product.');
    }
    final order = Order(_generateId(), productsWithQuantities);
    _orders.add(order);
  }

  void updateOrder(String id, Map<Product, int> productsWithQuantities) {
    if (productsWithQuantities.isEmpty) {
      throw ArgumentError('Order must contain at least one product.');
    }
    final orderIndex = _orders.indexWhere((order) => order.id == id);
    if (orderIndex != -1) {
      _orders[orderIndex] = Order(id, productsWithQuantities);
    } else {
      throw ArgumentError('Order with ID $id not found.');
    }
  }

  List<Order> getOrders() => List.unmodifiable(_orders);

  Order? getOrderById(String id) {
    return _orders.firstWhereOrNull((order) => order.id == id);
  }
}
