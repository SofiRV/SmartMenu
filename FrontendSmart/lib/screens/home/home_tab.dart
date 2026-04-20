import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/models/meal_item.dart';
import '../home/controllers/home_controller.dart';
import '../home/header.dart';
import '../home/calories_card.dart';
import '../home/register_extra_food_button.dart';
import '../home/quick_summary_carousel.dart';
import '../home/next_meal_card.dart';
import '../home/meals_reorderable_list.dart';
import '../home/eaten_today_list.dart';
import '../home/inspiration_card.dart';
import '../home/search_recipes_card.dart';
import '../home/shopping_list_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);

    // Puedes reemplazar estos datos con reales del backend
    final String username = "María";
    final String avatarEmoji = "👩";

    // Calorías demo (ajusta cuando tengas backend)
    const int caloriesConsumed = 720;
    const int caloriesGoal = 2100;

    // Para el carrusel resumen rápido
    final yesterday = controller.yesterday;
    final tomorrow = controller.tomorrow;

    // "Tu próxima comida": saca la primera de las próximas comidas
    final MealItem? nextMeal = controller.nextMeals.isNotEmpty ? controller.nextMeals.first : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(username: username, avatarEmoji: avatarEmoji),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calorías card
                CaloriesCard(
                  caloriesConsumed: caloriesConsumed,
                  caloriesGoal: caloriesGoal,
                ),
                // "+ Registrar extra"
                const RegisterExtraFoodButton(),

                // Resumen rápido -> Carrusel ayer/mañana
                const SizedBox(height: 14),
                const Text(
                  "Resumen rápido",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                QuickSummaryCarousel(
                  title: "Ayer",
                  items: yesterday,
                  // onTap: () {}, // pon tu acción si quieres
                ),
                const SizedBox(height: 10),
                QuickSummaryCarousel(
                  title: "Mañana",
                  items: tomorrow,
                  // onTap: () {},
                ),

                // Próxima comida
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tu próxima comida",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        // Aquí podrías navegar al plan completo
                      },
                      child: const Text(
                        "Ver plan completo",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 11, 153, 101),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (nextMeal != null)
                  NextMealCard(
                    emoji: nextMeal.icon,
                    tag: nextMeal.tag,
                    time: nextMeal.time,
                    title: nextMeal.title,
                    kcal: nextMeal.kcal,
                    // Puedes manejar la navegación personalizada aquí si quieres
                  )
                else
                  const Text(
                    "No hay próximas comidas registradas.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A5565),
                    ),
                  ),

                // Siguientes comidas de hoy
                const SizedBox(height: 18),
                const Text(
                  "Siguientes comidas de hoy",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                MealsReorderableList(
                  meals: controller.nextMeals,
                  onReorder: controller.reorderMeal,
                  onDelete: controller.deleteMeal,
                  onToggleDone: controller.toggleMealDone,
                  onTap: (index) {
                    // Navegar a detalles, si quieres
                  },
                ),

                // Inspiración
                const SizedBox(height: 18),
                const Text(
                  "¿Buscas inspiración?",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Descubre nuevas recetas para añadir a tu plan",
                  style: TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5A5565),
                  ),
                ),
                const SizedBox(height: 10),
                const InspirationCard(),

                // Buscar recetas
                const SearchRecipesCard(),

                // Lo que has comido hoy
                const SizedBox(height: 18),
                const Text(
                  "Lo que has comido hoy",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                EatenTodayList(
                  eatenMeals: controller.eatenToday,
                ),

                // Mi lista de compras
                const SizedBox(height: 4),
                const ShoppingListCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}