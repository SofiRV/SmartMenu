import 'package:flutter/material.dart';
import '../models/meal_item.dart';
import '../models/mini_meal.dart';

class HomeController extends ChangeNotifier {
  // Comidas de hoy
  List<MealItem> _nextMeals = [];
  List<MealItem> _eatenToday = [];

  // Carruseles para "ayer" y "mañana"
  List<MiniMeal> _yesterday = [];
  List<MiniMeal> _tomorrow = [];

  // Getters
  List<MealItem> get nextMeals => _nextMeals;
  List<MealItem> get eatenToday => _eatenToday;
  List<MiniMeal> get yesterday => _yesterday;
  List<MiniMeal> get tomorrow => _tomorrow;

  // Setters de datos desde backend:
  void setTodayMeals({required List<MealItem> next, required List<MealItem> eaten}) {
    _nextMeals = next;
    _eatenToday = eaten;
    notifyListeners();
  }

  void setYesterday(List<MiniMeal> list) {
    _yesterday = list;
    notifyListeners();
  }

  void setTomorrow(List<MiniMeal> list) {
    _tomorrow = list;
    notifyListeners();
  }

  // Métodos UX
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
}