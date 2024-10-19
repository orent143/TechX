// providers.dart
import 'package:riverpod/riverpod.dart';
import 'order_service.dart';
import 'product_service.dart';
import 'user_service.dart';

final productServiceProvider =
    Provider<ProductService>((ref) => ProductService());
final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
final userServiceProvider = Provider<UserService>((ref) => UserService());
