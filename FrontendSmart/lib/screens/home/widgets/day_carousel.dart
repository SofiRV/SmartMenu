import 'package:flutter/material.dart';
import '/../constants/app_colors.dart';
import '/../models/mini_meal.dart';

class DayCarousel extends StatelessWidget {
  final String title;
  final List<MiniMeal> items;
  final VoidCallback? onTap;

  const DayCarousel({
    super.key,
    required this.title,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (onTap != null)
              InkWell(
                onTap: onTap,
                child: const Text(
                  "Ver",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = items[i];

              return Container(
                width: 200,
                padding: const EdgeInsets.all(12),
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
                    // icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          item.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // kcal
                    Text(
                      "${item.kcal}\nkcal",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12.6,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}