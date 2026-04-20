import 'package:flutter/material.dart';

class CaloriesCard extends StatelessWidget {
  final int caloriesConsumed;
  final int caloriesGoal;

  const CaloriesCard({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesGoal,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
    const Color textGrey = Color(0xFF5A5565);

    final int caloriesRemaining = caloriesGoal - caloriesConsumed;
    final double progress = caloriesGoal > 0
        ? caloriesConsumed / caloriesGoal
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: textGrey,
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
                      "$caloriesConsumed",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        "/ 2100 kcal",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: textGrey,
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
                      color: const Color(0xFFEAF7F2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: primaryGreen,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$caloriesRemaining restantes",
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: textGrey,
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
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: const Color(0xFFE9E9EE),
              valueColor: const AlwaysStoppedAnimation(primaryGreen),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "${(progress * 100).toInt()}% del objetivo diario",
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}