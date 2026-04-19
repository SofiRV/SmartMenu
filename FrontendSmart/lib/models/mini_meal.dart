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

  factory MiniMeal.fromMap(Map<String, dynamic> json) {
    return MiniMeal(
      icon: json['icon'],
      title: json['title'],
      subtitle: json['subtitle'],
      kcal: json['kcal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
      'kcal': kcal,
    };
  }
}