// lib/models/meal_item.dart

class MealItem {
  final String id;
  final String icon;
  final String title;
  final String tag;
  final String time;
  final String kcal;
  final bool done;

  MealItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.tag,
    required this.time,
    required this.kcal,
    this.done = false,
  });

  MealItem copyWith({
    String? id,
    String? icon,
    String? title,
    String? tag,
    String? time,
    String? kcal,
    bool? done,
  }) {
    return MealItem(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      tag: tag ?? this.tag,
      time: time ?? this.time,
      kcal: kcal ?? this.kcal,
      done: done ?? this.done,
    );
  }

  /// Construir desde la respuesta del backend
  factory MealItem.fromBackend(Map<String, dynamic> json) {
    final foods = (json['foods'] as List?) ?? [];
    final mainFood = foods.isNotEmpty ? foods.first : null;

    final String icon = "assets/icons/default_food.png"; // Cambia el path y elige según momento o tipo si tienes
    final String tag = mainFood != null && mainFood['name'] != null
        ? mainFood['name'] as String
        : "";

    // Obtén la hora solamente (asume formato ISO 8601)
    final String datetime = json['datetime'] ?? "";
    final String time =
        datetime.length > 10 ? datetime.substring(11, 16) : "--:--";

    // Si tu food tiene calorías en el backend, ponlo aquí, si no, "--"
    final String kcal =
        mainFood != null && mainFood['kcal'] != null ? mainFood['kcal'].toString() : "--";

    return MealItem(
      id: json['id'].toString(),
      icon: icon,
      title: json['eatingMoment'] ?? "",
      tag: tag,
      time: time,
      kcal: kcal,
      done: json['eaten'] ?? false,
    );
  }
}