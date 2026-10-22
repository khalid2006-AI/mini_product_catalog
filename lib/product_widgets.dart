import 'package:flutter/material.dart';

typedef ProductTapCallback = void Function(int index);
typedef FavoriteCallback = void Function(int index);

class ProductsListView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final FavoriteCallback? onFavoritePressed;
  final ProductTapCallback? onProductTap;

  const ProductsListView({
    super.key,
    required this.products,
    this.onFavoritePressed,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(p["name"]),
            subtitle: Text("\$${p["price"]}"),
            onTap: () => onProductTap?.call(index),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => onFavoritePressed?.call(index),
            ),
          ),
        );
      },
    );
  }
}

class ProductsGridView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final FavoriteCallback? onFavoritePressed;
  final ProductTapCallback? onProductTap;
  final int crossAxisCount;

  const ProductsGridView({
    super.key,
    required this.products,
    this.onFavoritePressed,
    this.onProductTap,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          child: InkWell(
            onTap: () => onProductTap?.call(index),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p["name"],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("\$${p["price"]}"),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () => onFavoritePressed?.call(index),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}