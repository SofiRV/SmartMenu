// lib/services/meal_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/home/models/meal_item.dart';
import 'api_config.dart';

class MealService {
  final String baseUrl; // ejemplo: "http://192.168.1.10:8000" o de tu .env

  MealService(this.baseUrl);

  Future<List<MealItem>> fetchMeals(int accountId) async {
    final url = Uri.parse(ApiConfig.url('meal/account/$accountId'));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Aquí depende de la estructura real,
      // normalmente las comidas vienen en decoded["meals"]
      final mealsList = decoded["meals"] as List;
      return mealsList
          .map((mealJson) => MealItem.fromBackend(mealJson))
          .toList();
    } else {
      throw Exception('Error cargando las comidas (${response.statusCode})');
    }
  }
}