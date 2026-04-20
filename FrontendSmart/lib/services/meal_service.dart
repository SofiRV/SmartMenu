// lib/services/meal_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/home/models/meal_item.dart';
import 'api_config.dart';

class MealService {
  final String baseUrl; // ejemplo: "http://192.168.1.10:8000" o de tu .env

  MealService(this.baseUrl);

  // Método original (por si sigues usándolo en otros widgets)
  Future<List<MealItem>> fetchMeals(int accountId) async {
    final url = Uri.parse(ApiConfig.url('meal/account/$accountId'));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final mealsList = decoded["meals"] as List;
      return mealsList
          .map((mealJson) => MealItem.fromBackend(mealJson))
          .toList();
    } else {
      throw Exception('Error cargando las comidas (${response.statusCode})');
    }
  }

  // Nuevo método para buscar por fecha
  Future<List<MealItem>> fetchMealsByDate(int accountId, String date) async {
    final url = Uri.parse(ApiConfig.url('/meal/account/$accountId?date=$date'));
    print('Intentando fetch: $url');
    final response = await http.get(url);

    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey("meals")) {
        final mealsList = decoded["meals"] as List;
        print('Cantidad de meals: ${mealsList.length}');
        return mealsList
            .map((mealJson) => MealItem.fromBackend(mealJson))
            .toList();
      } else {
        print('No hay clave meals. Decoded: $decoded');
        return [];
      }
    } else {
      print('Error: código ${response.statusCode}, body: ${response.body}');
      throw Exception('Error cargando comidas (${response.statusCode}). Body: ${response.body}');
    }
  }
}