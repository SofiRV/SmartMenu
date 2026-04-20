import 'meal_item.dart';

class MiniMeal {
  final String icon;
  final String title;
  final String subtitle;
  final String kcal;

  const MiniMeal({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.kcal,
  });

  /// Construir a partir de MealItem (para usar con meals que ya tienes)
  factory MiniMeal.fromMealItem(MealItem meal) {
    return MiniMeal(
      icon: meal.icon,
      title: meal.title,
      subtitle: "${meal.tag} ${meal.time}",
      kcal: meal.kcal,
    );
  }

  /// Puedes agregar este método si el backend en un futuro devuelve algo con estructura directa para MiniMeal
  factory MiniMeal.fromBackend(Map<String, dynamic> json) {
    return MiniMeal(
      icon: json['icon'] ?? '🍽️',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      kcal: json['kcal']?.toString() ?? "--",
    );
  }
}