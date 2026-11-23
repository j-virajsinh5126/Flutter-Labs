
import 'package:flutter/material.dart';

void main() {
  runApp(const AnimatedProductApp());
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

// =====================================================
// PRODUCT DATA
// =====================================================

const List<Product> products = [
  Product(
    id: 1,
    name: 'Wireless Headphones',
    category: 'Electronics',
    price: 1999,
    description: 'Premium wireless headphones with excellent sound '
        'quality, comfortable ear cushions and long battery life.',
    icon: Icons.headphones,
    color: Colors.deepPurple,
  ),
  Product(
    id: 2,
    name: 'Smart Watch',
    category: 'Electronics',
    price: 2499,
    description: 'Modern smartwatch with fitness tracking, '
        'notifications and health monitoring.',
    icon: Icons.watch,
    color: Colors.blue,
  ),
  Product(
    id: 3,
    name: 'Running Shoes',
    category: 'Fashion',
    price: 1599,
    description: 'Lightweight and comfortable running shoes '
        'for daily activities.',
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
// CART MANAGEMENT
// =====================================================

class CartStore {
  static final ValueNotifier<List<Product>> cart =
      ValueNotifier<List<Product>>([]);

  static void add(Product product) {
    cart.value = [...cart.value, product];
  }

  static void remove(Product product) {
    final updatedCart = [...cart.value];
    updatedCart.remove(product);
    cart.value = updatedCart;
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

class AnimatedProductApp extends StatelessWidget {
  const AnimatedProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animated Product Catalogue',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      ),

      home: const MainScreen(),
    );
  }
}

// =====================================================
// MAIN SCREEN
// =====================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  void openProductDetails(Product product) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProductDetailsPage(product: product);
        },

        // CUSTOM PAGE TRANSITION
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },

        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,

        title: Text(
          selectedIndex == 0
              ? 'Animated Products'
              : 'Shopping Cart',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          ValueListenableBuilder<List<Product>>(
            valueListenable: CartStore.cart,
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
                    icon: const Icon(Icons.shopping_cart),
                  ),

                  if (cart.isNotEmpty)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${cart.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      // SCREEN NAVIGATION
      body: IndexedStack(
        index: selectedIndex,
        children: [
          ProductCataloguePage(
            onProductTap: openProductDetails,
          ),
          const CartPage(),
        ],
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PRODUCT CATALOGUE SCREEN
// =====================================================

class ProductCataloguePage extends StatelessWidget {
  final Function(Product) onProductTap;

  const ProductCataloguePage({
    super.key,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // HEADER
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.indigo,
                Colors.deepPurple,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),

          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Products',
                style: TextStyle(
                  fontSize: 23,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Explore our latest collection',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // PRODUCT GRID
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),

            itemBuilder: (context, index) {
              return AnimatedProductCard(
                product: products[index],
                onTap: () {
                  onProductTap(products[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// =====================================================
// REUSABLE PRODUCT ARTWORK
// =====================================================

class ProductArtwork extends StatelessWidget {
  final Product product;
  final double iconSize;

  const ProductArtwork({
    super.key,
    required this.product,
    this.iconSize = 75,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: product.color.withValues(alpha: 0.12),
      child: Center(
        child: Icon(
          product.icon,
          size: iconSize,
          color: product.color,
        ),
      ),
    );
  }
}

// =====================================================
// ANIMATED PRODUCT CARD
// =====================================================

class AnimatedProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const AnimatedProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<AnimatedProductCard> createState() =>
      _AnimatedProductCardState();
}

class _AnimatedProductCardState
    extends State<AnimatedProductCard> {

  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
      },

      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },

      onTap: widget.onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        curve: Curves.easeInOutBack,

        transform: Matrix4.diagonal3Values(
          isPressed ? 0.96 : 1.0,
          isPressed ? 0.96 : 1.0,
          1.0,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isPressed ? 0.05 : 0.12,
              ),
              blurRadius: isPressed ? 4 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HERO ANIMATION
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),

                child: Hero(
                  tag: 'product-${product.id}',
                  child: ProductArtwork(
                    product: product,
                  ),
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
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
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
// PRODUCT DETAILS SCREEN
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

class _ProductDetailsPageState
    extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {

  bool isFavorite = false;

  late AnimationController favoriteController;

  late Animation<double> favoriteAnimation;

  @override
  void initState() {
    super.initState();

    // ANIMATION CONTROLLER
    favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // TWEEN AND ANIMATION CURVE
    favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(
      CurvedAnimation(
        parent: favoriteController,
        curve: Curves.elasticOut,
      ),
    );
  }

  // FAVORITE BUTTON ANIMATION
  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    favoriteController.forward(from: 0).then((_) {
      if (mounted) {
        favoriteController.reverse();
      }
    });
  }

  @override
  void dispose() {
    favoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HERO ANIMATION DESTINATION
            Hero(
              tag: 'product-${product.id}',

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: SizedBox(
                  height: 260,
                  child: ProductArtwork(
                    product: product,
                    iconSize: 130,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PRODUCT NAME AND FAVORITE
            Row(
              children: [

                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ANIMATED FAVORITE BUTTON
                ScaleTransition(
                  scale: favoriteAnimation,

                  child: IconButton(
                    onPressed: toggleFavorite,

                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                      size: 32,
                    ),
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

            const SizedBox(height: 25),

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
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            // ANIMATED ADD TO CART BUTTON
            CartAddButton(
              onAdd: () {
                CartStore.add(product);
              },
            ),

            const SizedBox(height: 15),

            // BACK BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// ANIMATED ADD TO CART BUTTON
// POST-EXPERIMENT TASK
// =====================================================

class CartAddButton extends StatefulWidget {
  final VoidCallback onAdd;

  const CartAddButton({
    super.key,
    required this.onAdd,
  });

  @override
  State<CartAddButton> createState() => _CartAddButtonState();
}

class _CartAddButtonState extends State<CartAddButton>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  late Animation<double> scaleAnimation;

  bool added = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.bounceOut,
      ),
    );
  }

  void addToCart() {
    widget.onAdd();

    setState(() {
      added = true;
    });

    controller.forward(from: 0).then((_) {
      if (mounted) {
        controller.reverse();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added to cart successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,

      child: SizedBox(
        width: double.infinity,
        height: 52,

        child: ElevatedButton.icon(
          onPressed: addToCart,

          icon: Icon(
            added
                ? Icons.check_circle
                : Icons.shopping_cart,
          ),

          label: Text(
            added ? 'Added to Cart!' : 'Add to Cart',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: added
                ? Colors.green
                : Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CART SCREEN
// =====================================================

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<List<Product>>(
      valueListenable: CartStore.cart,

      builder: (context, cartItems, child) {

        return Column(
          children: [

            // CART LIST
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
                          SizedBox(height: 15),
                          Text(
                            'Your Cart is Empty',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add some products to get started.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )

                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: cartItems.length,

                      itemBuilder: (context, index) {

                        final product = cartItems[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),

                          child: ListTile(
                            leading: Icon(
                              product.icon,
                              color: product.color,
                              size: 35,
                            ),

                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

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
                        );
                      },
                    ),
            ),

            // TOTAL PRICE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Order placed successfully!',
                                  ),
                                ),
                              );
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),

                      child: const Text('Checkout'),
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
