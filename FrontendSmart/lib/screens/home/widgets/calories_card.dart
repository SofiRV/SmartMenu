import 'package:flutter/material.dart';
import '/../constants/app_colors.dart';

class CaloriesCard extends StatelessWidget {
  final int consumed;
  final int goal;

  const CaloriesCard({
    super.key,
    required this.consumed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed;
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(18, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Comidas de hoy",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$consumed",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        "/ $goal kcal",
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.primaryGreen,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$remaining restantes",
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primaryGreen,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              "${(progress * 100).toInt()}% del objetivo diario",
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}