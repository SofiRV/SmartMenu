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
}

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
}