import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/store_model.dart';

class CartService {
  static const _key = 'cart_items';

  Future<List<Map<String, dynamic>>> _loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return [];
    final List<dynamic> list = json.decode(s);
    return List<Map<String, dynamic>>.from(
        list.map((e) => Map<String, dynamic>.from(e)));
  }

  Future<void> _saveRaw(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(list));
  }

  Future<void> addToCart(StoreModel item) async {
    final raw = await _loadRaw();
    final idx = raw.indexWhere((e) => e['id'] == item.id);
    if (idx >= 0) {
      raw[idx]['quantity'] = (raw[idx]['quantity'] ?? 1) + 1;
    } else {
      raw.add({
        'id': item.id,
        'title': item.title,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'description': item.description,
        'quantity': 1,
      });
    }
    await _saveRaw(raw);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    return await _loadRaw();
  }

  Future<void> removeFromCart(int id) async {
    final raw = await _loadRaw();
    raw.removeWhere((e) => e['id'] == id);
    await _saveRaw(raw);
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final raw = await _loadRaw();
    final idx = raw.indexWhere((e) => e['id'] == id);
    if (idx >= 0) {
      raw[idx]['quantity'] = quantity;
      if (quantity <= 0) raw.removeAt(idx);
      await _saveRaw(raw);
    }
  }

  Future<double> totalPrice() async {
    final raw = await _loadRaw();
    double total = 0.0;
    for (var item in raw) {
      final price = (item['price'] is num)
          ? (item['price'] as num).toDouble()
          : double.tryParse('${item['price']}') ?? 0.0;
      final qty = item['quantity'] ?? 1;
      total += price * qty;
    }
    return total;
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
