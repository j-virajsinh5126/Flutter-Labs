
import 'package:flutter/material.dart';

void main() {
  runApp(const ShopEaseApp());
}

// =====================================================
// PRODUCT MODEL
// =====================================================

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final IconData icon;
  final Color color;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// SAMPLE PRODUCTS

const List<Product> products = [
  Product(
    id: 1,
    name: 'Wireless Headphones',
    category: 'Electronics',
    price: 1999,
    description: 'Premium wireless headphones with clear sound, '
        'comfortable ear cushions and long battery life.',
    icon: Icons.headphones,
    color: Colors.deepPurple,
  ),
  Product(
    id: 2,
    name: 'Smart Watch',
    category: 'Electronics',
    price: 2499,
    description: 'A modern smartwatch with fitness tracking, '
        'notifications and health monitoring.',
    icon: Icons.watch,
    color: Colors.blue,
  ),
  Product(
    id: 3,
    name: 'Running Shoes',
    category: 'Fashion',
    price: 1599,
    description: 'Comfortable and lightweight running shoes '
        'for everyday use.',
    icon: Icons.directions_run,
    color: Colors.orange,
  ),
  Product(
    id: 4,
    name: 'Casual T-Shirt',
    category: 'Fashion',
    price: 599,
    description: 'Stylish cotton T-shirt suitable for casual wear.',
    icon: Icons.checkroom,
    color: Colors.teal,
  ),
  Product(
    id: 5,
    name: 'Laptop Backpack',
    category: 'Accessories',
    price: 999,
    description: 'Durable backpack with multiple compartments '
        'and laptop protection.',
    icon: Icons.backpack,
    color: Colors.brown,
  ),
  Product(
    id: 6,
    name: 'Sunglasses',
    category: 'Accessories',
    price: 799,
    description: 'Trendy sunglasses with UV protection.',
    icon: Icons.wb_sunny,
    color: Colors.indigo,
  ),
];

// =====================================================
// CART STORE
// =====================================================

class CartStore {
  static final ValueNotifier<List<Product>> cart =
      ValueNotifier<List<Product>>([]);

  static void add(Product product) {
    cart.value = [...cart.value, product];
  }

  static void remove(Product product) {
    final items = [...cart.value];
    items.remove(product);
    cart.value = items;
  }

  static double get total {
    return cart.value.fold(
      0,
      (sum, product) => sum + product.price,
    );
  }
}

// =====================================================
// MAIN APPLICATION
// =====================================================

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),

      home: const MainScreen(),
    );
  }
}

// =====================================================
// MAIN SCREEN WITH BOTTOM NAVIGATION
// =====================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  // Each tab has its own navigation stack.
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<String> titles = [
    'ShopEase',
    'Products',
    'My Cart',
    'My Profile',
  ];

  // BUILD INDIVIDUAL NAVIGATORS

  Widget buildNavigator(int index) {
    return Navigator(
      key: navigatorKeys[index],

      initialRoute: '/',

      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {

          case '/':
            switch (index) {
              case 0:
                page = HomePage(
                  onBrowse: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                );
                break;

              case 1:
                page = const ProductListPage();
                break;

              case 2:
                page = const CartPage();
                break;

              default:
                page = const ProfilePage();
            }
            break;

          case '/details':
            final product = settings.arguments as Product;
            page = ProductDetailsPage(product: product);
            break;

          case '/cart':
            final product = settings.arguments as Product?;
            page = CartPage(selectedProduct: product);
            break;

          case '/profile':
            page = const ProfilePage();
            break;

          case '/settings':
            page = const SettingsPage();
            break;

          default:
            page = const Center(
              child: Text('Page Not Found'),
            );
        }

        return MaterialPageRoute(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }

  // BOTTOM NAVIGATION

  void onTabSelected(int index) {
    if (selectedIndex == index) {
      navigatorKeys[index].currentState!
          .popUntil((route) => route.isFirst);
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  // DRAWER NAVIGATION

  void openDrawerPage(int index) {
    Navigator.pop(context);

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final currentNavigator =
            navigatorKeys[selectedIndex].currentState!;

        if (currentNavigator.canPop()) {
          currentNavigator.pop();
        } else if (selectedIndex != 0) {
          setState(() {
            selectedIndex = 0;
          });
        } else {
          // Exit handled by Android when on home screen.
        }
      },

      child: Scaffold(

        appBar: AppBar(
          title: Text(
            titles[selectedIndex],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        // DRAWER

        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [

              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.shopping_bag,
                        size: 35,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'ShopEase',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your Online Shopping App',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => openDrawerPage(0),
              ),

              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Products'),
                onTap: () => openDrawerPage(1),
              ),

              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('My Cart'),
                onTap: () => openDrawerPage(2),
              ),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () => openDrawerPage(3),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  navigatorKeys[3].currentState!
                      .pushNamed('/settings');
                  setState(() {
                    selectedIndex = 3;
                  });
                },
              ),
            ],
          ),
        ),

        // BODY WITH INDEPENDENT NAVIGATION STACKS

        body: IndexedStack(
          index: selectedIndex,
          children: List.generate(
            4,
            (index) => buildNavigator(index),
          ),
        ),

        // BOTTOM NAVIGATION BAR

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTabSelected,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// HOME PAGE
// =====================================================

class HomePage extends StatelessWidget {
  final VoidCallback onBrowse;

  const HomePage({
    super.key,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // BANNER

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.indigo,
                  Colors.deepPurple,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to ShopEase!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Discover amazing products at great prices.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 15),
                Icon(
                  Icons.shopping_bag,
                  size: 55,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Shop by Category',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              CategoryIcon(
                icon: Icons.devices,
                title: 'Electronics',
              ),
              CategoryIcon(
                icon: Icons.checkroom,
                title: 'Fashion',
              ),
              CategoryIcon(
                icon: Icons.backpack,
                title: 'Accessories',
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            'Featured Products',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...products.take(2).map(
            (product) => ProductCard(product: product),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Explore All Products'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CATEGORY ICON WIDGET
// =====================================================

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.indigo.shade50,
          child: Icon(
            icon,
            color: Colors.indigo,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

// =====================================================
// PRODUCT LIST PAGE WITH TABBAR AND TABBARVIEW
// =====================================================

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Electronics',
      'Fashion',
      'Accessories',
    ];

    return DefaultTabController(
      length: categories.length,

      child: Column(
        children: [

          Material(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,

              tabs: categories.map(
                (category) => Tab(text: category),
              ).toList(),
            ),
          ),

          Expanded(
            child: TabBarView(
              children: categories.map((category) {

                final filteredProducts = category == 'All'
                    ? products
                    : products.where(
                        (product) =>
                            product.category == category,
                      ).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('No products found'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredProducts.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),

                  itemBuilder: (context, index) {
                    return ProductGridCard(
                      product: filteredProducts[index],
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PRODUCT CARD
// =====================================================

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          product.icon,
          color: product.color,
          size: 40,
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('₹${product.price.toStringAsFixed(0)}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),

        onTap: () {
          Navigator.of(context).pushNamed(
            '/details',
            arguments: product,
          );
        },
      ),
    );
  }
}

// =====================================================
// PRODUCT GRID CARD WITH GESTURES
// =====================================================

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      // TAP TO OPEN DETAILS
      onTap: () {
        Navigator.of(context).pushNamed(
          '/details',
          arguments: product,
        );
      },

      // LONG PRESS TO ADD TO CART
      onLongPress: () {
        CartStore.add(product);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
      },

      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Container(
                width: double.infinity,
                color: product.color.withValues(alpha: 0.12),
                child: Icon(
                  product.icon,
                  size: 75,
                  color: product.color,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Tap for details • Hold to add',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PRODUCT DETAILS PAGE
// =====================================================

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {

    final product = widget.product;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // PRODUCT IMAGE / ICON

          GestureDetector(
            onDoubleTap: () {
              setState(() {
                isFavorite = !isFavorite;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                  ),
                ),
              );
            },

            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: product.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Icon(
                product.icon,
                size: 120,
                color: product.color,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          Text(
            product.category,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            '₹${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Product Description',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            product.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 30),

          // ADD TO CART

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton.icon(
              onPressed: () {
                CartStore.add(product);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added to cart'),
                  ),
                );
              },

              icon: const Icon(Icons.shopping_cart),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 17),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/cart',
                  arguments: product,
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text('View Cart'),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CART PAGE
// =====================================================

class CartPage extends StatelessWidget {
  final Product? selectedProduct;

  const CartPage({
    super.key,
    this.selectedProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: CartStore.cart,

      builder: (context, cartItems, child) {

        return Column(
          children: [

            // CART HEADER

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: Colors.indigo.shade50,

              child: Column(
                children: [
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${cartItems.length} Items',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // CART ITEMS

            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Your cart is empty!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )

                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: cartItems.length,

                      itemBuilder: (context, index) {
                        final product = cartItems[index];

                        return Dismissible(
                          key: ValueKey(
                            '${product.id}_$index',
                          ),

                          direction: DismissDirection.endToStart,

                          background: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          onDismissed: (direction) {
                            CartStore.remove(product);
                          },

                          child: Card(
                            child: ListTile(
                              leading: Icon(
                                product.icon,
                                size: 35,
                                color: product.color,
                              ),

                              title: Text(product.name),

                              subtitle: Text(
                                '₹${product.price.toStringAsFixed(2)}',
                              ),

                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  CartStore.remove(product);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // TOTAL AND CHECKOUT

            Container(
              padding: const EdgeInsets.all(18),
              color: Colors.white,

              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '₹${CartStore.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: cartItems.isEmpty
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Order Placed'),
                                    content: const Text(
                                      'Thank you for shopping with ShopEase!',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),

                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// PROFILE PAGE
// =====================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [

          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.indigo,
            child: Icon(
              Icons.person,
              size: 65,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Virajsinh Jadeja',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            'virajsinh@example.com',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 30),

          profileOption(
            icon: Icons.shopping_bag,
            title: 'My Orders',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No previous orders'),
                ),
              );
            },
          ),

          profileOption(
            icon: Icons.favorite,
            title: 'My Favorites',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Favorites feature'),
                ),
              );
            },
          ),

          profileOption(
            icon: Icons.location_on,
            title: 'My Addresses',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address section'),
                ),
              );
            },
          ),

          profileOption(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),

          profileOption(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout clicked'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget profileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.indigo,
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// =====================================================
// SETTINGS PAGE
// =====================================================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),

      children: [

        const Text(
          'Application Settings',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Receive shopping notifications'),
          value: notifications,
          onChanged: (value) {
            setState(() {
              notifications = value;
            });
          },
        ),

        const Divider(),

        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Change application appearance preference'),
          value: darkMode,
          onChanged: (value) {
            setState(() {
              darkMode = value;
            });
          },
        ),

        const Divider(),

        const ListTile(
          leading: Icon(Icons.info),
          title: Text('About ShopEase'),
          subtitle: Text('Version 1.0.0'),
        ),
      ],
    );
  }
}
