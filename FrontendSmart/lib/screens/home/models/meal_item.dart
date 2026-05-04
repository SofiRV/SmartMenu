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

  static String _mapMoment(String raw) {
    switch (raw) {
      case "breakfast":
        return "Desayuno";
      case "mid_morning_snack":
        return "Snack";
      case "lunch":
        return "Comida";
      case "afternoon_snack":
        return "Merienda";
      case "dinner":
        return "Cena";
      default:
        return raw;
    }
  }

  // Construir desde el backend
  factory MealItem.fromBackend(Map<String, dynamic> json) {
    final foods = (json['foods'] as List?) ?? [];
    final mainFood = foods.isNotEmpty ? foods.first : null;

    final String icon = "🍽️";
    final String foodName = mainFood != null && mainFood['name'] != null
        ? mainFood['name'] as String
        : "Comida";

    final String datetime = json['datetime'] ?? "";
    final String time =
        datetime.length >= 16 ? datetime.substring(11, 16) : "--:--";

    int? mealKcal = json['kcal'] is num ? (json['kcal'] as num).toInt() : null;

    if (mealKcal == null || mealKcal == 0) {
      int sum = 0;
      for (final food in foods) {
        final raw = (food as Map?)?['kcal'];
        final kcal = raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? "");
        if (kcal != null) sum += kcal;
      }
      mealKcal = sum > 0 ? sum : null;
    }

    final String kcal = mealKcal?.toString() ?? "--";
    final String moment = json['eatingMoment'] ?? "";

    return MealItem(
      id: json['id'].toString(),
      icon: icon,
      title: foodName,
      tag: _mapMoment(moment),
      time: time,
      kcal: kcal,
      done: json['eaten'] ?? false,
    );
  }
}