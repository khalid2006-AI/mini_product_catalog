// ===== Part 1 =====
// a) initState -> didChangeDependencies -> build
// b) build only (setState)
// c) deactivate -> dispose. On return: initState -> didChangeDependencies -> build
// d) didChangeDependencies -> build (MediaQuery changed)
//
// ===== Part 4 =====
// 1) go replaces stack (Login->Products). push adds on top (Products->Details)
// 2) go: no back to Login. push: back to Products with result
// 3) Path: /details/Laptop/1200 | Query: /products?user=Guest

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'product_widgets.dart';

final List<Map<String, dynamic>> demoProducts = [
  {"name": "Laptop", "price": 1200},
  {"name": "Phone", "price": 800},
  {"name": "Headphones", "price": 150},
  {"name": "Keyboard", "price": 90},
  {"name": "Mouse", "price": 40},
  {"name": "Monitor", "price": 300},
];

final GoRouter appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: "/products",
      name: "products",
      builder: (context, state) {
        final user = state.uri.queryParameters["user"] ?? "Guest";
        return ProductsPage(username: user);
      },
    ),
    GoRoute(
      path: "/details/:name/:price",
      name: "details",
      builder: (context, state) {
        final name = state.pathParameters["name"]!;
        final price = int.parse(state.pathParameters["price"]!);
        return DetailsPage(name: name, price: price);
      },
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Mini Product Catalog",
      routerConfig: appRouter,
    );

    // Navigator version (commented out):
    // return MaterialApp(
    //   title: "Mini Product Catalog",
    //   routes: {
    //     "/": (context) => const LoginPage(),
    //     "/products": (context) {
    //       final args = ModalRoute.of(context)?.settings.arguments;
    //       final user = (args is String) ? args : "Guest";
    //       return ProductsPage(username: user);
    //     },
    //   },
    // );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    print("LoginPage: initState");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("LoginPage: didChangeDependencies");
  }

  @override
  Widget build(BuildContext context) {
    print("LoginPage: build");
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Welcome! Tap Login to continue as Guest."),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.goNamed("products", queryParameters: {"user": "Guest"});
                // Navigator.pushNamed(context, "/products", arguments: "Guest");
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    print("LoginPage: deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    print("LoginPage: dispose");
    super.dispose();
  }
}

class ProductsPage extends StatefulWidget {
  final String username;
  const ProductsPage({super.key, required this.username});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int favorites = 0;
  String? cartMessage;
  double screenWidth = 0;

  @override
  void initState() {
    super.initState();
    print("ProductsPage: initState");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    screenWidth = size.width;
    print(
        "ProductsPage: didChangeDependencies -> width: ${size.width}, height: ${size.height}");
  }

  @override
  Widget build(BuildContext context) {
    print("ProductsPage: build");
    final isWide = screenWidth >= 600;

    Future<void> openDetails(int index) async {
      final p = demoProducts[index];
      final result = await context.push<String>(
        "/details/${p["name"]}/${p["price"]}",
      );
      if (result != null && mounted) {
        setState(() => cartMessage = result);
      }

      // final result = await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => DetailsPage(
      //       name: p["name"],
      //       price: p["price"],
      //     ),
      //   ),
      // );
      // if (result != null) setState(() => cartMessage = result);
    }

    void onFavorite(int index) {
      setState(() => favorites++);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text("Welcome, ${widget.username}"),
                Text("Favorites: $favorites"),
                Text("Screen width: ${screenWidth.toStringAsFixed(1)}"),
                if (cartMessage != null)
                  Text(cartMessage!,
                      style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: isWide
                ? ProductsGridView(
              products: demoProducts,
              onFavoritePressed: onFavorite,
              onProductTap: openDetails,
            )
                : ProductsListView(
              products: demoProducts,
              onFavoritePressed: onFavorite,
              onProductTap: openDetails,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    print("ProductsPage: deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    print("ProductsPage: dispose");
    super.dispose();
  }
}

class DetailsPage extends StatefulWidget {
  final String name;
  final int price;
  const DetailsPage({super.key, required this.name, required this.price});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  void initState() {
    super.initState();
    print("DetailsPage: initState");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("DetailsPage: didChangeDependencies");
  }

  @override
  Widget build(BuildContext context) {
    print("DetailsPage: build");
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Product: ${widget.name}",
                style: const TextStyle(fontSize: 20)),
            Text("Price: \$${widget.price}"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.pop("${widget.name} added to cart");
                // Navigator.pop(context, "${widget.name} added to cart");
              },
              child: const Text("Add to Cart"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    print("DetailsPage: deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    print("DetailsPage: dispose");
    super.dispose();
  }
}