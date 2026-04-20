import 'package:flutter/material.dart';
import '../home/models/meal_item.dart'; // Usa MealItem
import 'meal_tile.dart'; // Lo creamos después

class MealsReorderableList extends StatelessWidget {
  final List<MealItem> meals;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onDelete;
  final void Function(int index) onToggleDone;
  final void Function(int index)? onTap;

  const MealsReorderableList({
    super.key,
    required this.meals,
    required this.onReorder,
    required this.onDelete,
    required this.onToggleDone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false, // SIN icono de puntitos
      onReorder: onReorder,
      children: [
        for (int i = 0; i < meals.length; i++)
          Dismissible(
            key: ValueKey(meals[i].id),
            direction: DismissDirection.startToEnd,
            background: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
            ),
            onDismissed: (_) => onDelete(i),
            child: ReorderableDelayedDragStartListener(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MealTile(
                  item: meals[i],
                  onTap: onTap != null ? () => onTap!(i) : null,
                  onToggleDone: () => onToggleDone(i),
                ),
              ),
            ),
          ),
      ],
    );
  }
}