import 'package:amazonclone/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';


class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        leading: Image.network(product.imageUrl, width: 60, height: 50),
        title: Text(product.name),
        subtitle: Text('\$${product.price} - ${product.description}'),
        onTap: () {
          // Navigate to Product Detail Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
      ),
    );
  }
}
