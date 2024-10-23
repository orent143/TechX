import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/product_service.dart';
import '../services/providers.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'products_card.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final List<Order>? orders;
  final User user;
  final Function(List<Order>) onCheckout;

  const HomeScreen({
    super.key,
    this.orders,
    required this.user,
    required this.onCheckout,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  List<Order> _orders = []; // Initialize as mutable list
  final List<CartItem> _cartItems = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // If orders are provided, create a mutable copy
    _orders = widget.orders != null ? List.from(widget.orders!) : [];
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

    // Directly navigate to CartScreen after adding to cart
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
      _orders.addAll(orders); // Ensure orders is mutable
      _cartItems.clear(); // Clear cart items after checkout
    });

    // Navigate back to HomeScreen after successful checkout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          orders: _orders,
          user: widget.user,
          onCheckout: widget.onCheckout,
        ),
      ),
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
      case 0: // Products
        return Column(
          children: [
            _buildCategoryList(productService),
            Expanded(child: _buildProductGrid(productService)),
          ],
        );
      case 1: // Orders
        return OrdersScreen(orders: _orders);
      case 2: // Cart
        return CartScreen(
            cartItems: _cartItems, onCheckout: _checkout, user: widget.user);
      default: // Profile
        return ProfileScreen(user: widget.user);
    }
  }

  Widget _buildCategoryList(ProductService productService) {
    final categories = [
      'All',
      ...productService.getProducts().map((product) => product.name).toSet()
    ];

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory == category
                    ? Colors.blue
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _selectedCategory == category
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 13.0, vertical: 12.0),
              ),
              onPressed: () {
                setState(() {
                  _selectedCategory = category; // Update selected category
                });
              },
              child: Text(
                category,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(ProductService productService) {
    final filteredProducts = _selectedCategory == 'All'
        ? productService.getProducts()
        : productService
            .getProducts()
            .where((product) => product.name == _selectedCategory)
            .toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
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
