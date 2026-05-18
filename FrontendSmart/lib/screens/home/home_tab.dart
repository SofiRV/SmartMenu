import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

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
import '../../services/profile_service.dart';
import '../../navigation/route_observer.dart';
import '../search_recipe_screen.dart'; // ← nueva importación

class HomeTab extends StatefulWidget {
  final int accountId;
  const HomeTab({super.key, required this.accountId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with WidgetsBindingObserver, RouteAware {
  late Future<void> dataFuture;
  String? username;
  int? _caloriesGoal;

  DateTime _lastRefresh = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    dataFuture = _getAllData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      dataFuture = _getAllData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (now.difference(_lastRefresh).inMinutes >= 1) {
        setState(() {
          dataFuture = _getAllData();
        });
      }
    }
  }

  Future<void> _loadCaloriesGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getDouble('caloriesGoal');
    if (!mounted) return;
    setState(() {
      _caloriesGoal = goal?.round();
    });
  }

  int _sumCalories(List<MealItem> meals) {
    int total = 0;
    for (final meal in meals) {
      final parsed = int.tryParse(meal.kcal) ?? 0;
      total += parsed;
    }
    return total;
  }

  Future<void> _getAllData() async {
    final controller = Provider.of<HomeController>(context, listen: false);
    final mealService = MealService(ApiConfig.baseUrl);

    final now = DateTime.now();
    String format(DateTime d) => DateFormat('dd-MM-yyyy').format(d);

    await _getUsername();
    await _loadCaloriesGoal();

    final mealsToday = await mealService.fetchMealsByDate(widget.accountId, format(now));
    final eatenToday = mealsToday.where((m) => m.done).toList();
    final nextMeals = mealsToday.where((m) => !m.done).toList();
    controller.setTodayMeals(next: nextMeals, eaten: eatenToday);

    final mealsYesterday = await mealService.fetchMealsByDate(widget.accountId, format(now.subtract(const Duration(days: 1))));
    controller.setYesterday(mealsYesterday.map(MiniMeal.fromMealItem).toList());

    final mealsTomorrow = await mealService.fetchMealsByDate(widget.accountId, format(now.add(const Duration(days: 1))));
    controller.setTomorrow(mealsTomorrow.map(MiniMeal.fromMealItem).toList());

    _lastRefresh = DateTime.now();
  }

  Future<void> _getUsername() async {
    try {
      final service = ProfileService();
      final profiles = await service.getProfiles(accountId: widget.accountId);
      if (!mounted) return;
      setState(() {
        username = (profiles.isNotEmpty)
            ? (profiles.first['name'] ?? "Usuario")
            : "Usuario";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        username = "Usuario";
      });
    }
  }

  // ==================== NUEVA FUNCIONALIDAD DE CÁMARA ====================
  Future<void> _onInspirationCameraTap() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return;

    try {
      final uri = Uri.parse(ApiConfig.url("/specific-ingredient/ai-detect"));
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        photo.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> ingredients = decoded['ingredients'] ?? [];
        final List<String> detectedNames = ingredients
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (!mounted) return;

        // Navegar a la pantalla de búsqueda con los ingredientes detectados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchRecipeScreen(
              initialIngredients: detectedNames,
            ),
          ),
        );
      } else if (response.statusCode == 503) {
        debugPrint('Servicio IA no disponible (503): ${response.body}');
        _showError("El servicio de IA está saturado. Inténtalo de nuevo en unos momentos.");
      } else {
        debugPrint('Error ai-detect (${response.statusCode}): ${response.body}');
        _showError("Error al detectar ingredientes (${response.statusCode})");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  // =======================================================================

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

        final int caloriesConsumed = _sumCalories(controller.eatenToday);
        final int caloriesGoal = _caloriesGoal ?? 2000;

        final yesterday = controller.yesterday;
        final tomorrow = controller.tomorrow;
        final nextMeal = controller.nextMeals.isNotEmpty ? controller.nextMeals.first : null;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              dataFuture = _getAllData();
            });
            await dataFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          foodId: nextMeal.foodId,
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
                      InspirationCard(
                        onCameraTap: _onInspirationCameraTap, // ← conectado
                      ),
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
          ),
        );
      },
    );
  }
}