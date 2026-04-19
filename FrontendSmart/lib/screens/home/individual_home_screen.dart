import 'package:flutter/material.dart';

import '../../screens/plan_screen.dart';
import '../../screens/search_recipe_screen.dart';
import '../../screens/shop_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/details_recipe_screen.dart';
import '../../screens/register_extra_food_screen.dart';

import '../../models/meal_item.dart';
import '../../models/mini_meal.dart';

import 'widgets/next_meals_list.dart';
import 'widgets/eaten_today_list.dart';

class IndividualHomeScreen extends StatefulWidget {
  const IndividualHomeScreen({super.key});

  @override
  State<IndividualHomeScreen> createState() => _IndividualHomeScreenState();
}

class _IndividualHomeScreenState extends State<IndividualHomeScreen> {
  static const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);

  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<MealItem> _nextMeals = [
    MealItem(
      id: 'm1',
      icon: "🥗",
      title: "Ensalada César",
      tag: "Comida",
      time: "14:00",
      kcal: "320",
    ),
    MealItem(
      id: 'm2',
      icon: "☕",
      title: "Café con leche",
      tag: "Snack",
      time: "16:30",
      kcal: "120",
    ),
    MealItem(
      id: 'm3',
      icon: "🍝",
      title: "Pasta al pesto",
      tag: "Cena",
      time: "20:30",
      kcal: "600",
    ),
  ];

  final List<MealItem> _eatenToday = [
    MealItem(
      id: 'e1',
      icon: "🥑",
      title: "Tostadas con aguacate",
      tag: "Desayuno",
      time: "08:30",
      kcal: "420",
      done: true,
    ),
  ];

  final List<MiniMeal> _yesterday = const [
    MiniMeal(
      icon: "🥑",
      title: "Tostadas",
      subtitle: "Ayer 08:30",
      kcal: "420",
    ),
    MiniMeal(
      icon: "🥤",
      title: "Smoothie",
      subtitle: "Ayer 11:00",
      kcal: "180",
    ),
  ];

  final List<MiniMeal> _tomorrow = const [
    MiniMeal(
      icon: "🍳",
      title: "Huevos",
      subtitle: "Mañana 09:00",
      kcal: "350",
    ),
    MiniMeal(
      icon: "🥗",
      title: "Ensalada",
      subtitle: "Mañana 14:00",
      kcal: "320",
    ),
  ];

  List<Widget> get _pages => [
        _buildHomePage(),
        const PlanScreen(),
        const SearchRecipeScreen(),
        const ShopScreen(),
        const SettingsScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _momentLabel() {
    final h = DateTime.now().hour;
    if (h < 11) return "Tu mañana";
    if (h < 16) return "Tu mediodía";
    if (h < 20) return "Tu tarde";
    return "Tu noche";
  }

  // ================= HOME =================
  Widget _buildHomePage() {
    const caloriesConsumed = 720;
    const caloriesGoal = 2100;
    final progress = caloriesConsumed / caloriesGoal;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 18),
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Hola 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _momentLabel(),
                    style: const TextStyle(color: Colors.white70),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CALORÍAS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Comidas de hoy"),
                        const SizedBox(height: 8),
                        Text(
                          "$caloriesConsumed / $caloriesGoal kcal",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: progress),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BOTÓN EXTRA
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterExtraFoodScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryGreen),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text("+ Registrar algo más que comí"),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CARRUSEL
                  _buildCarousel("Ayer", _yesterday),
                  const SizedBox(height: 12),
                  _buildCarousel("Mañana", _tomorrow),

                  const SizedBox(height: 16),

                  const Text(
                    "Próximas comidas",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  NextMealsList(
                    meals: _nextMeals,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _nextMeals.removeAt(oldIndex);
                        _nextMeals.insert(newIndex, item);
                      });
                    },
                    onToggleDone: (item) {
                      setState(() {
                        final index = _nextMeals.indexWhere((e) => e.id == item.id);
                          if (index == -1) return;

                        _nextMeals[index] = _nextMeals[index].copyWith(
                          done: !_nextMeals[index].done,
                        );

                        if (_nextMeals[index].done) {
                          _eatenToday.insert(0, _nextMeals[index]);
                        }
                      });
                    },
                    onTap: (item) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetailsRecipeScreen(),
                        ),
                      );
                    },
                    onDelete: (item) {
                      setState(() {
                        _nextMeals.removeWhere((e) => e.id == item.id);
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Comido hoy",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  EatenTodayList(items: _eatenToday),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(String title, List<MiniMeal> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final item = items[i];
              return Container(
                width: 180,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(item.icon),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.title)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= NAV =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
      ),
    );
  }
}