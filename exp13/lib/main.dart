
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ============================================================
// MAIN
// ============================================================

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CompareProvider()),
      ],
      child: const ShoppingApp(),
    ),
  );
}

// ============================================================
// APPLICATION
// ============================================================

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEasy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      home: const MainScreen(),
    );
  }
}

// ============================================================
// PRODUCT MODEL
// ============================================================

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingData = json['rating'] as Map<String, dynamic>? ?? {};

    return Product(
      id: json['id'] as int,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? 'Other',
      image: json['image'] ?? '',
      rating: (ratingData['rate'] as num?)?.toDouble() ?? 0,
      ratingCount: (ratingData['count'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============================================================
// API SERVICE
// ============================================================

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  static Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('$baseUrl/products'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => Product.fromJson(item))
          .toList();
    }

    throw Exception(
      'Unable to fetch products. Status: ${response.statusCode}',
    );
  }

  static Future<List<String>> fetchCategories() async {
    final response = await http
        .get(Uri.parse('$baseUrl/products/categories'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item.toString()).toList();
    }

    throw Exception('Unable to fetch categories');
  }
}

// ============================================================
// PRODUCT PROVIDER
// ============================================================

class ProductProvider extends ChangeNotifier {
  List<Product> products = [];
  List<String> categories = [];

  bool isLoading = false;
  String? error;

  String searchQuery = '';
  String selectedCategory = 'All';

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              product.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

      final matchesCategory = selectedCategory == 'All' ||
          product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.fetchProducts(),
        ApiService.fetchCategories(),
      ]);

      products = results[0] as List<Product>;
      categories = results[1] as List<String>;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void filterCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }
}

// ============================================================
// CART PROVIDER
// ============================================================

class CartProvider extends ChangeNotifier {
  final Map<int, int> _items = {};

  Map<int, int> get items => Map.unmodifiable(_items);

  int get totalQuantity {
    return _items.values.fold(0, (sum, quantity) => sum + quantity);
  }

  int quantityOf(int productId) => _items[productId] ?? 0;

  bool contains(int productId) => _items.containsKey(productId);

  double subtotal(List<Product> products) {
    double total = 0;

    for (final entry in _items.entries) {
      final index = products.indexWhere(
        (product) => product.id == entry.key,
      );

      if (index != -1) {
        total += products[index].price * entry.value;
      }
    }

    return total;
  }

  double get deliveryCharge => _items.isEmpty ? 0 : 50;

  double total(List<Product> products) {
    return subtotal(products) + deliveryCharge;
  }

  void add(Product product) {
    _items[product.id] = quantityOf(product.id) + 1;
    notifyListeners();
  }

  void decrease(Product product) {
    if (!contains(product.id)) return;

    if (quantityOf(product.id) <= 1) {
      _items.remove(product.id);
    } else {
      _items[product.id] = quantityOf(product.id) - 1;
    }

    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ============================================================
// WISHLIST PROVIDER
// ============================================================

class WishlistProvider extends ChangeNotifier {
  final Set<int> _items = {};

  Set<int> get items => Set.unmodifiable(_items);

  bool contains(Product product) => _items.contains(product.id);

  void toggle(Product product) {
    if (_items.contains(product.id)) {
      _items.remove(product.id);
    } else {
      _items.add(product.id);
    }

    notifyListeners();
  }
}

// ============================================================
// COMPARE PROVIDER
// ============================================================

class CompareProvider extends ChangeNotifier {
  final Map<int, Product> _items = {};

  List<Product> get items => _items.values.toList();

  bool contains(Product product) => _items.containsKey(product.id);

  void toggle(Product product) {
    if (contains(product)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }

    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ============================================================
// MAIN SCREEN / NAVIGATION
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    CartScreen(),
    WishlistScreen(),
    CompareScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final compare = context.watch<CompareProvider>();

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: _navIcon(Icons.shopping_cart_outlined, cart.totalQuantity),
            selectedIcon: _navIcon(Icons.shopping_cart, cart.totalQuantity),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: _navIcon(Icons.favorite_border, wishlist.items.length),
            selectedIcon: _navIcon(Icons.favorite, wishlist.items.length),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: _navIcon(Icons.compare_arrows, compare.items.length),
            selectedIcon: _navIcon(Icons.compare_arrows, compare.items.length),
            label: 'Compare',
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int count) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: Icon(icon),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ShopEasy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => provider.loadProducts(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh products',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: provider.search,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          provider.search('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (!provider.isLoading && provider.categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _categoryChip('All', provider),
                  ...provider.categories.map(
                    (category) => _categoryChip(category, provider),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _buildProducts(provider),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String category, ProductProvider provider) {
    final selected = provider.selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(category),
        selected: selected,
        onSelected: (_) => provider.filterCategory(category),
      ),
    );
  }

  Widget _buildProducts(ProductProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 55,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text('Unable to load products'),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: provider.loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final products = provider.filteredProducts;

    if (products.isEmpty) {
      return const Center(
        child: Text('No products found.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

// ============================================================
// REUSABLE PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final compare = context.watch<CompareProvider>();

    final isFavorite = wishlist.contains(product);
    final isCompared = compare.contains(product);
    final quantity = cart.quantityOf(product.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => ProductDetailsDialog(product: product),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          size: 50,
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;

                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => wishlist.toggle(product),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 15,
                    color: Colors.orange,
                  ),
                  Text(
                    ' ${product.rating} (${product.ratingCount})',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () => cart.add(product),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          quantity > 0 ? 'Add More' : 'Add to Cart',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Compare product',
                    onPressed: () => compare.toggle(product),
                    icon: Icon(
                      Icons.compare_arrows,
                      color: isCompared ? Colors.deepPurple : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT DETAILS
// ============================================================

class ProductDetailsDialog extends StatelessWidget {
  final Product product;

  const ProductDetailsDialog({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        product.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              product.image,
              height: 150,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 60),
            ),
            const SizedBox(height: 15),
            Text(product.description),
            const SizedBox(height: 12),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 20,
              ),
            ),
            Text('Category: ${product.category}'),
            Text('Rating: ${product.rating} / 5'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<CartProvider>().add(product);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to cart')),
            );
          },
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}

// ============================================================
// CART SCREEN
// ============================================================

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = context.watch<ProductProvider>().products;

    final cartProducts = products.where(
      (product) => cart.contains(product.id),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: cartProducts.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add some products to get started!',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartProducts.length,
                    itemBuilder: (context, index) {
                      return CartItem(product: cartProducts[index]);
                    },
                  ),
                ),
                _buildSummary(context, cart, products),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Remove all products from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clear();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    CartProvider cart,
    List<Product> products,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          summaryRow('Items', '${cart.totalQuantity}'),
          summaryRow(
            'Subtotal',
            '\$${cart.subtotal(products).toStringAsFixed(2)}',
          ),
          summaryRow(
            'Delivery',
            '\$${cart.deliveryCharge.toStringAsFixed(2)}',
          ),
          const Divider(),
          summaryRow(
            'Total',
            '\$${cart.total(products).toStringAsFixed(2)}',
            bold: true,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Demo checkout completed successfully!',
                    ),
                  ),
                );
                cart.clear();
              },
              child: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: bold ? Colors.deepPurple : Colors.black87,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE CART ITEM
// ============================================================

class CartItem extends StatelessWidget {
  final Product product;

  const CartItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.quantityOf(product.id);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Image.network(
              product.image,
              height: 75,
              width: 65,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        onPressed: () => cart.decrease(product),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _quantityButton(
                        icon: Icons.add,
                        onPressed: () => cart.add(product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => cart.remove(product),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: Colors.deepPurple),
      ),
    );
  }
}

// ============================================================
// WISHLIST SCREEN
// ============================================================

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final products = context.watch<ProductProvider>().products;

    final savedProducts = products.where(
      (product) => wishlist.items.contains(product.id),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: savedProducts.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No wishlist products',
              subtitle: 'Save your favourite products here.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: savedProducts.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return ProductCard(product: savedProducts[index]);
              },
            ),
    );
  }
}

// ============================================================
// COMPARE SCREEN
// ============================================================

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compare = context.watch<CompareProvider>();
    final products = compare.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (products.isNotEmpty)
            IconButton(
              onPressed: compare.clear,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear comparison',
            ),
        ],
      ),
      body: products.length < 2
          ? EmptyState(
              icon: Icons.compare_arrows,
              title: 'Select at least 2 products',
              subtitle:
                  'Go to Shop and tap the compare icon on products. '
                  'Currently selected: ${products.length}',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Product Comparison',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                      ),
                      columns: [
                        const DataColumn(label: Text('Attribute')),
                        ...products.map(
                          (product) => DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                product.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        DataRow(
                          cells: [
                            const DataCell(Text('Image')),
                            ...products.map(
                              (product) => DataCell(
                                Image.network(
                                  product.image,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image),
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            const DataCell(Text('Price')),
                            ...products.map(
                              (product) => DataCell(
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            const DataCell(Text('Category')),
                            ...products.map(
                              (product) => DataCell(
                                Text(product.category),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            const DataCell(Text('Rating')),
                            ...products.map(
                              (product) => DataCell(
                                Text('${product.rating} / 5'),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            const DataCell(Text('Reviews')),
                            ...products.map(
                              (product) => DataCell(
                                Text('${product.ratingCount}'),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            const DataCell(Text('Action')),
                            ...products.map(
                              (product) => DataCell(
                                IconButton(
                                  onPressed: () => compare.remove(product),
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

// ============================================================
// EMPTY STATE WIDGET
// ============================================================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 75,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
