import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MealService {
  Future<List<dynamic>> getMealsByAccount(int accountId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.url("/meal/account/$accountId")),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["meals"] ?? [];
    } else {
      throw Exception("No se pudieron cargar las comidas");
    }
  }

  Future<Map<String, dynamic>> getMealById(int mealId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.url("/meal/$mealId")),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("No se pudo cargar la comida");
    }
  }

  Future<bool> deleteMeal(int mealId) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.url("/meal/$mealId")),
      headers: {
        "Content-Type": "application/json",
      },
    );

    return response.statusCode == 200;
  }
}