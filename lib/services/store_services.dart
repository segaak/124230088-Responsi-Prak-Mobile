import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/store_model.dart';

class StoreServices {
  final String _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<StoreModel>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    // Debug: log status
    // ignore: avoid_print
    print('StoreServices: GET $_baseUrl -> ${response.statusCode}');

    if (response.statusCode == 200) {
     final data = json.decode(response.body);

     List<dynamic> productsJson;
     if (data is List) {
       productsJson = data;
     } else if (data is Map<String, dynamic>) {
       if (data['data'] is List) {
         productsJson = data['data'];
       } else if (data['products'] is List) {
         productsJson = data['products'];
       } else {
         // Sometimes API returns a map with numeric keys or single object
         throw Exception('Unexpected JSON shape for products');
       }
     } else {
       throw Exception('Unexpected JSON type');
     }

    final list = productsJson.map((json) => StoreModel.fromJson(json as Map<String, dynamic>)).toList();
    // ignore: avoid_print
    print('StoreServices: parsed ${list.length} products');
    return list;

    } else {
      throw Exception('Failed to load products');
    }
    
  }
}