import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/user.dart'; // Import User model
import '../services/product_service.dart';
import '../services/providers.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'products_card.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final List<Order>? orders;
  final User user;
  final Function(List<Order>) onCheckout; // Add onCheckout parameter

  const HomeScreen({
    super.key,
    this.orders,
    required this.user,
    required this.onCheckout, // Add onCheckout to constructor
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  List<Order> _orders = [];
  final List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.orders != null) {
      _orders = widget.orders!;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addToCart(Product product, int quantity) {
    setState(() {
      final existingCartItem = _cartItems.firstWhere(
        (item) => item.product.id == product.id,
        orElse: () => CartItem(product, 0),
      );

      if (existingCartItem.quantity > 0) {
        existingCartItem.quantity += quantity;
      } else {
        _cartItems.add(CartItem(product, quantity));
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: _cartItems,
          onCheckout: _checkout,
          user: widget.user,
        ),
      ),
    );
  }

  void _checkout(List<Order> orders) {
    setState(() {
      _orders.addAll(orders);
      _cartItems.clear();
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrdersScreen(orders: _orders)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productService = ref.watch(productServiceProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Blue-Aesthetic-Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                  ['Products', 'Orders', 'Cart', 'Profile'][_selectedIndex]),
              automaticallyImplyLeading: false,
            ),
            Expanded(child: _buildBody(productService)),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ProductService productService) {
    switch (_selectedIndex) {
      case 0:
        return _buildProductGrid(productService);
      case 1:
        return OrdersScreen(orders: _orders);
      case 2:
        return CartScreen(
            cartItems: _cartItems, onCheckout: _checkout, user: widget.user);
      default:
        return ProfileScreen(user: widget.user);
    }
  }

  Widget _buildProductGrid(ProductService productService) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: productService.getProducts().length,
      itemBuilder: (context, index) {
        final product = productService.getProducts()[index];
        return ProductCard(product: product, addToCart: _addToCart);
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Products'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.transparent,
    );
  }
}
