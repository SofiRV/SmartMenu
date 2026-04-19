import 'package:flutter/material.dart';
import '../../../models/meal_item.dart';

class EatenTodayList extends StatelessWidget {
  final List<MealItem> items;

  const EatenTodayList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        "Aún no has registrado comidas hoy",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9E9EE)),
          ),
          child: Row(
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title),
                    Text(
                      item.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text("${item.kcal} kcal"),
            ],
          ),
        );
      }).toList(),
    );
  }
}