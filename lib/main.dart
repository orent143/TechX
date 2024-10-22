import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/order.dart';
import 'models/cart.dart';
import 'models/user.dart'; // Import the User model if needed
import 'screens/profile_screen.dart';
import 'services/user_service.dart';
import 'screens/homescreen.dart';
import 'screens/orders_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cart_screen.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userService = UserService();
  await userService.loadUsers(); // Load users before running the app

  runApp(
    ProviderScope(
      overrides: [
        userServiceProvider.overrideWithValue(userService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User;
          return HomeScreen(
            orders: [],
            user: user,
            onCheckout: (orders) {
              // Define your checkout functionality here
              print("Checkout from main.dart: $orders");
            },
          );
        },
        '/orders': (context) => OrdersScreen(
              orders: ModalRoute.of(context)!.settings.arguments as List<Order>,
            ),
        '/cart': (context) => CartScreen(
              cartItems:
                  ModalRoute.of(context)!.settings.arguments as List<CartItem>,
              onCheckout: (orders) {
                // Define your checkout functionality here
              },
              user: ModalRoute.of(context)!.settings.arguments
                  as User, // Pass user
            ),
        '/profile': (context) => ProfileScreen(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
      },
    );
  }
}
