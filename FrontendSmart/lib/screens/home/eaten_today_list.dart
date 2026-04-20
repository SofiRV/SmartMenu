import 'package:flutter/material.dart';
import '../home/models/meal_item.dart'; // Para usar MealItem
import 'meal_tile.dart';

class EatenTodayList extends StatelessWidget {
  final List<MealItem> eatenMeals;

  const EatenTodayList({
    super.key,
    required this.eatenMeals,
  });

  @override
  Widget build(BuildContext context) {
    if (eatenMeals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          "Aún no has registrado comidas hoy.",
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Color(0xFF5A5565),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in eatenMeals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MealTile(
              item: item,
              // No pasamos onToggleDone: desactiva el botón
              // Puedes pasar onTap si quieres abrir detalles
              // onTap: () => ...,
            ),
          ),
      ],
    );
  }
}