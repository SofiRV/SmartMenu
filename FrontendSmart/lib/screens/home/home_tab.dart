import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
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
import '../../services/meal_service.dart';
import './models/mini_meal.dart';
import '../../services/api_config.dart';
import '../../services/profile_service.dart'; // <-- agrega este import

class HomeTab extends StatefulWidget {
  final int accountId;
  const HomeTab({super.key, required this.accountId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<void> dataFuture;
  String? username; // <-- variable para el nombre

  @override
  void initState() {
    super.initState();
    dataFuture = _getAllData();
  }

  Future<void> _getAllData() async {
    final controller = Provider.of<HomeController>(context, listen: false);
    final mealService = MealService(ApiConfig.baseUrl);

    final now = DateTime.now();
    String format(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

    // Carga el nombre de usuario
    await _getUsername();

    // HOY
    final mealsToday = await mealService.fetchMealsByDate(widget.accountId, format(now));
    final eatenToday = mealsToday.where((m) => m.done).toList();
    final nextMeals = mealsToday.where((m) => !m.done).toList();
    controller.setTodayMeals(next: nextMeals, eaten: eatenToday);

    // AYER
    final mealsYesterday = await mealService.fetchMealsByDate(widget.accountId, format(now.subtract(const Duration(days: 1))));
    controller.setYesterday(mealsYesterday.map(MiniMeal.fromMealItem).toList());

    // MAÑANA
    final mealsTomorrow = await mealService.fetchMealsByDate(widget.accountId, format(now.add(const Duration(days: 1))));
    controller.setTomorrow(mealsTomorrow.map(MiniMeal.fromMealItem).toList());
  }

  Future<void> _getUsername() async {
    try {
      final service = ProfileService();
      final profiles = await service.getProfiles(accountId: widget.accountId);
      setState(() {
        username = (profiles.isNotEmpty) ? (profiles.first['name'] ?? "Usuario") : "Usuario";
      });
    } catch (e) {
      setState(() {
        username = "Usuario";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error cargando datos: ${snapshot.error}'));
        }

        final controller = Provider.of<HomeController>(context);

        final String avatarEmoji = "👩";
        final String nameToShow = username ?? "Cargando...";

        // Calorías ejemplo (ajusta según tu lógica)
        const int caloriesConsumed = 720;
        const int caloriesGoal = 2100;

        final yesterday = controller.yesterday;
        final tomorrow = controller.tomorrow;
        final nextMeal = controller.nextMeals.isNotEmpty ? controller.nextMeals.first : null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(username: nameToShow, avatarEmoji: avatarEmoji),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CaloriesCard(
                      caloriesConsumed: caloriesConsumed,
                      caloriesGoal: caloriesGoal,
                    ),
                    const RegisterExtraFoodButton(),
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
                    ),
                    const SizedBox(height: 10),
                    QuickSummaryCarousel(
                      title: "Mañana",
                      items: tomorrow,
                    ),
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
                          onTap: () {},
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
                      )
                    else
                      const Text(
                        "No hay próximas comidas registradas.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A5565),
                        ),
                      ),
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
                      onTap: (index) {},
                    ),
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
                    const SearchRecipesCard(),
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
                    const SizedBox(height: 4),
                    const ShoppingListCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}