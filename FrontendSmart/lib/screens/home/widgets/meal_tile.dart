import 'package:flutter/material.dart';
import '/../constants/app_colors.dart';
import '/../models/meal_item.dart';

class MealTile extends StatelessWidget {
  final MealItem item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  const MealTile({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  // ✅ checkbox / done
                  InkWell(
                    onTap: onToggleDone,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: item.done
                            ? AppColors.greenSoft
                            : const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: item.done
                              ? AppColors.primaryGreen
                              : AppColors.borderLight,
                          width: 1.4,
                        ),
                      ),
                      child: Icon(
                        item.done
                            ? Icons.check_rounded
                            : Icons.circle_outlined,
                        size: 20,
                        color: item.done
                            ? AppColors.primaryGreen
                            : AppColors.textLightGrey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // icon comida
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        item.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            decoration: item.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 12.8,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // kcal
                  Text(
                    "${item.kcal}\nkcal",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}