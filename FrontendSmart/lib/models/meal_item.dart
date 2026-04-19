class MealItem {
  final String id;
  final String icon;
  final String title;
  final String tag;
  final String time;
  final String kcal;
  final bool done;

  const MealItem({
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

  // 👇 IMPORTANTE PARA BACKEND DESPUÉS

  factory MealItem.fromMap(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'],
      icon: json['icon'],
      title: json['title'],
      tag: json['tag'],
      time: json['time'],
      kcal: json['kcal'],
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'tag': tag,
      'time': time,
      'kcal': kcal,
      'done': done,
    };
  }
}