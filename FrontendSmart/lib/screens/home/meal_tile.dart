import 'package:flutter/material.dart';
import '../home/models/meal_item.dart';

class MealTile extends StatelessWidget {
  final MealItem item;
  final VoidCallback? onTap;
  final VoidCallback? onToggleDone;

  const MealTile({
    super.key,
    required this.item,
    this.onTap,
    this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
    const Color borderGrey = Color(0xFFE9E9EE);
    const Color bgIcon1 = Color(0xFFF3FBF7);
    const Color textGrey = Color(0xFF5A5565);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderGrey, width: 1.2),
        ),
        child: Row(
          children: [
            // Botón circular para marcar como hecho
            if (onToggleDone != null)
              InkWell(
                onTap: onToggleDone,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.done ? const Color(0xFFEAF7F2) : const Color(0xFFF4F6FA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: item.done ? primaryGreen : const Color(0xFFE0E5EE),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    item.done ? Icons.check_rounded : Icons.circle_outlined,
                    size: 20,
                    color: item.done ? primaryGreen : const Color(0xFF9AA3B2),
                  ),
                ),
              ),
            if (onToggleDone != null)
              const SizedBox(width: 10),

            // Emoji/Icono de la comida
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgIcon1,
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

            // Info principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      decoration: item.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w400,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Tag (comida/snack/cena...)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.tag,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textGrey,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Kcal
            Text(
              "${item.kcal}\nkcal",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w500,
                color: textGrey,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}