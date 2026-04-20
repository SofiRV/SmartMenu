import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/home/models/meal_item.dart';

class MealsService {
  // Cambia la URL por la del backend real
  static const String baseUrl = 'https://tu-backend.com/api/meals';

  Future<List<MealItem>> fetchNextMeals() async {
    final response = await http.get(Uri.parse('$baseUrl/next'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MealItem(
        id: e['id'],
        icon: e['icon'],
        title: e['title'],
        tag: e['tag'],
        time: e['time'],
        kcal: e['kcal'].toString(),
        done: e['done'] ?? false,
      )).toList();
    } else {
      throw Exception('No se pudieron cargar las comidas');
    }
  }

  Future<List<MealItem>> fetchEatenToday() async {
    final response = await http.get(Uri.parse('$baseUrl/eaten_today'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MealItem(
        id: e['id'],
        icon: e['icon'],
        title: e['title'],
        tag: e['tag'],
        time: e['time'],
        kcal: e['kcal'].toString(),
        done: e['done'] ?? true,
      )).toList();
    } else {
      throw Exception('No se pudieron cargar las comidas ya comidas');
    }
  }

  // Puedes agregar más: fetchYesterday(), fetchTomorrow(), etc.
}