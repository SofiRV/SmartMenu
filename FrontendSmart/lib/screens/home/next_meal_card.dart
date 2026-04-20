import 'package:flutter/material.dart';
import '../details_recipe_screen.dart'; // Ajusta ruta si está en otro lado

class NextMealCard extends StatelessWidget {
  final String emoji;
  final String tag;
  final String time;
  final String title;
  final String kcal;
  final VoidCallback? onTapDetails;

  const NextMealCard({
    super.key,
    required this.emoji,
    required this.tag,
    required this.time,
    required this.title,
    required this.kcal,
    this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    const Color textGrey = Color(0xFF5A5565);

    return InkWell(
      onTap: onTapDetails ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DetailsRecipeScreen(),
              ),
            );
          },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFCFE0FF),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F73FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: textGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: Color(0xFFFF8A00),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$kcal kcal",
                        style: const TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w400,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF2F73FF),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}