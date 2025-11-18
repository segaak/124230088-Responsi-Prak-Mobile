import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cart = CartService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _cart.getCartItems();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _remove(int id) async {
    await _cart.removeFromCart(id);
    await _load();
  }

  Future<void> _changeQty(int id, int newQty) async {
    await _cart.updateQuantity(id, newQty);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Keranjang kosong'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final it = _items[idx];
                          final price = (it['price'] is num) ? (it['price'] as num).toDouble() : double.tryParse('${it['price']}') ?? 0.0;
                          final qty = it['quantity'] ?? 1;
                          return ListTile(
                            leading: it['imageUrl'] != null && it['imageUrl'].toString().isNotEmpty
                                ? Image.network(it['imageUrl'], width: 56, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.broken_image))
                                : const Icon(Icons.image),
                            title: Text(it['title'] ?? ''),
                            subtitle: Text('Rp ${price.toStringAsFixed(2)} x $qty'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _changeQty(it['id'], (it['quantity'] ?? 1) - 1),
                                ),
                                Text('${it['quantity'] ?? 1}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _changeQty(it['id'], (it['quantity'] ?? 1) + 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever),
                                  onPressed: () => _remove(it['id']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    FutureBuilder<double>(
                      future: _cart.totalPrice(),
                      builder: (context, snap) {
                        final total = snap.data ?? 0.0;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total: Rp ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
    );
  }
}
