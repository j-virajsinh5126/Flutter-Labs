import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../screens/auth/auth_gate_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/products/product_catalogue_screen.dart';
import '../screens/products/product_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(path: '/', name: 'auth-gate', builder: (context, state) => const AuthGateScreen()),
    GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/products', name: 'products', builder: (context, state) => const ProductCatalogueScreen()),
    GoRoute(path: '/product/:id', name: 'product-detail', builder: (context, state) {
      final product = state.extra;
      if (product is! Product) return const ProductCatalogueScreen();
      return ProductDetailScreen(product: product);
    }),
  ],
);
