import 'package:flutter/material.dart';
import '../models/store_model.dart';
import '../services/cart_service.dart';

class DetailPage extends StatelessWidget {
  final StoreModel store;
  final CartService _cart = CartService();

  DetailPage({super.key, required this.store});

  Future<void> _add(BuildContext context) async {
    await _cart.addToCart(store);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditambahkan ke keranjang')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(store.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  store.imageUrl,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                ),
              ),
              const SizedBox(height: 16),
              Text(store.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Rp ${store.price}', style: const TextStyle(fontSize: 16, color: Colors.green)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text('${store.score}'),
                ],
              ),
              const SizedBox(height: 12),
              Text(store.description),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _add(context),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}