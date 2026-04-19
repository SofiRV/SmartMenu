import 'package:flutter/material.dart';
import '../../../models/meal_item.dart';

class NextMealsList extends StatelessWidget {
  final List<MealItem> meals;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(MealItem item) onToggleDone;
  final Function(MealItem item) onTap;
  final Function(MealItem item) onDelete;

  const NextMealsList({
    super.key,
    required this.meals,
    required this.onReorder,
    required this.onToggleDone,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      onReorder: onReorder,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final item = meals[index];

        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.startToEnd,
          onDismissed: (_) => onDelete(item),
          background: Container(
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ReorderableDelayedDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onTap(item),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE9E9EE)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => onToggleDone(item),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.done
                                ? const Color(0xFFEAF7F2)
                                : const Color(0xFFF4F6FA),
                            border: Border.all(
                              color: item.done
                                  ? Colors.green
                                  : const Color(0xFFB0B7C3),
                            ),
                          ),
                          child: Icon(
                            item.done
                                ? Icons.check
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: item.done
                                ? Colors.green
                                : const Color(0xFFB0B7C3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(item.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: item.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}