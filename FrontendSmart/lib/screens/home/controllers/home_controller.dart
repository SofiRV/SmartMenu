import 'package:flutter/material.dart';
import '../models/meal_item.dart';

class HomeController extends ChangeNotifier {
  // Demo data: próximas comidas y comidas ya consumidas.
  List<MealItem> _nextMeals = [
    MealItem(
      id: 'm1',
      icon: "🥗",
      title: "Ensalada César",
      tag: "Comida",
      time: "14:00",
      kcal: "320",
    ),
    MealItem(
      id: 'm2',
      icon: "☕",
      title: "Café con leche",
      tag: "Snack",
      time: "16:30",
      kcal: "120",
    ),
    MealItem(
      id: 'm3',
      icon: "🍝",
      title: "Pasta al pesto",
      tag: "Cena",
      time: "20:30",
      kcal: "600",
    ),
  ];

  List<MealItem> _eatenToday = [
    MealItem(
      id: 'e1',
      icon: "🥑",
      title: "Tostadas con aguacate",
      tag: "Desayuno",
      time: "08:30",
      kcal: "420",
      done: true,
    ),
  ];

  // Carrusel: ayer y mañana
  List<MiniMeal> yesterday = const [
    MiniMeal(
      icon: "🥑",
      title: "Tostadas",
      subtitle: "Ayer 08:30",
      kcal: "420",
    ),
    MiniMeal(
      icon: "🥤",
      title: "Smoothie",
      subtitle: "Ayer 11:00",
      kcal: "180",
    ),
  ];

  List<MiniMeal> tomorrow = const [
    MiniMeal(
      icon: "🍳",
      title: "Huevos",
      subtitle: "Mañana 09:00",
      kcal: "350",
    ),
    MiniMeal(
      icon: "🥗",
      title: "Ensalada",
      subtitle: "Mañana 14:00",
      kcal: "320",
    ),
    MiniMeal(
      icon: "🍝",
      title: "Pasta",
      subtitle: "Mañana 20:30",
      kcal: "600",
    ),
  ];

  // Getters para exponer la data
  List<MealItem> get nextMeals => _nextMeals;
  List<MealItem> get eatenToday => _eatenToday;

  // Métodos para modificar estado
  void reorderMeal(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _nextMeals.removeAt(oldIndex);
    _nextMeals.insert(newIndex, item);
    notifyListeners();
  }

  void deleteMeal(int index) {
    _nextMeals.removeAt(index);
    notifyListeners();
  }

  void toggleMealDone(int index) {
    _nextMeals[index] = _nextMeals[index].copyWith(done: !_nextMeals[index].done);
    if (_nextMeals[index].done) {
      final moved = _nextMeals.removeAt(index);
      _eatenToday.insert(0, moved.copyWith(tag: moved.tag));
    }
    notifyListeners();
  }

  // Puedes añadir métodos para agregar comidas, editar, registrar extra, etc.
}