import 'package:flutter/material.dart';
import 'plan_screen.dart';
import 'search_recipe_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';
import 'details_recipe_screen.dart';
import 'register_extra_food_screen.dart';

class IndividualHomeScreen extends StatefulWidget {
  const IndividualHomeScreen({super.key});

  @override
  State<IndividualHomeScreen> createState() => _IndividualHomeScreenState();
}

class _IndividualHomeScreenState extends State<IndividualHomeScreen> {
  static const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);

  int _selectedIndex = 0;
  late final PageController _pageController;

  // ✅ “Siguientes comidas” (plan de hoy) -> reordenable
  final List<_MealItem> _nextMeals = [
    _MealItem(
      id: 'm1',
      icon: "🥗",
      title: "Ensalada César",
      tag: "Comida",
      time: "14:00",
      kcal: "320",
    ),
    _MealItem(
      id: 'm2',
      icon: "☕",
      title: "Café con leche",
      tag: "Snack",
      time: "16:30",
      kcal: "120",
    ),
    _MealItem(
      id: 'm3',
      icon: "🍝",
      title: "Pasta al pesto",
      tag: "Cena",
      time: "20:30",
      kcal: "600",
    ),
  ];

  // ✅ “Ya comido” (demo). Aquí luego pondrás lo que el usuario registre.
  final List<_MealItem> _eatenToday = [
    _MealItem(
      id: 'e1',
      icon: "🥑",
      title: "Tostadas con aguacate",
      tag: "Desayuno",
      time: "08:30",
      kcal: "420",
      done: true,
    ),
  ];

  // ✅ Carrusel: Ayer / Mañana (cajas deslizable arriba)
  final List<_MiniMeal> _yesterday = const [
    _MiniMeal(
      icon: "🥑",
      title: "Tostadas",
      subtitle: "Ayer 08:30",
      kcal: "420",
    ),
    _MiniMeal(
      icon: "🥤",
      title: "Smoothie",
      subtitle: "Ayer 11:00",
      kcal: "180",
    ),
  ];

  final List<_MiniMeal> _tomorrow = const [
    _MiniMeal(
      icon: "🍳",
      title: "Huevos",
      subtitle: "Mañana 09:00",
      kcal: "350",
    ),
    _MiniMeal(
      icon: "🥗",
      title: "Ensalada",
      subtitle: "Mañana 14:00",
      kcal: "320",
    ),
    _MiniMeal(
      icon: "🍝",
      title: "Pasta",
      subtitle: "Mañana 20:30",
      kcal: "600",
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
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _onItemTapped(int index) => _goToTab(index);

  // ✅ “Home cambia según la hora” (texto rápido, sin romper tu UI)
  String _momentLabel() {
    final h = DateTime.now().hour;
    if (h < 11) return "Tu mañana";
    if (h < 16) return "Tu mediodía";
    if (h < 20) return "Tu tarde";
    return "Tu noche";
    // (si quieres: aquí después decides qué sección priorizar según la hora)
  }

  // ===================== HOME =====================
  Widget _buildHomePage() {
    const Color screenBg = Color(0xFFEFF7F5);
    const Color textGrey = Color(0xFF5A5565);
    const Color lineGrey = Color(0xFFE9E9EE);

    // Datos demo de calorías (luego lo conectas a tus comidas registradas)
    const int caloriesConsumed = 720;
    const int caloriesGoal = 2100;
    final int caloriesRemaining = caloriesGoal - caloriesConsumed;
    final double progress = caloriesConsumed / caloriesGoal;

    Widget sectionTitle(String t) => Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );

    Widget smallLink(String t, {VoidCallback? onTap}) => InkWell(
      onTap: onTap,
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: primaryGreen,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: screenBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= Header verde =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hola, María 👋",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _momentLabel(),
                            style: const TextStyle(
                              color: Color.fromARGB(190, 255, 255, 255),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Text("👩", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= Contenido =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --------- Comidas de hoy (ANTES “Calorías de hoy”) ----------
                  Container(
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
                            valueColor: const AlwaysStoppedAnimation(
                              primaryGreen,
                            ),
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
                  ),

                  // ✅ MOVIDO: Registrar algo más que comí (justo debajo del card)
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterExtraFoodScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFBF5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF7EE7C2),
                          width: 1.6,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "+   Registrar algo más que comí",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ✅ NUEVO: Carrusel arriba (Ayer / Mañana)
                  sectionTitle("Resumen rápido"),
                  const SizedBox(height: 10),
                  _dayCarousel(
                    title: "Ayer",
                    items: _yesterday,
                    onTap: () {
                      // si quieres: abrir historial
                    },
                  ),
                  const SizedBox(height: 10),
                  _dayCarousel(
                    title: "Mañana",
                    items: _tomorrow,
                    onTap: () => _goToTab(1), // plan
                  ),

                  // --------- Tu próxima comida ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      sectionTitle("Tu próxima comida"),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: smallLink(
                          "Ver plan completo",
                          onTap: () => _goToTab(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ✅ Card próxima comida (sin ojo) + abre DetailsRecipeScreen
                  InkWell(
                    onTap: () {
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
                            child: const Center(
                              child: Text("🥤", style: TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2F73FF),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(999),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          "Snack",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: textGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "11:00",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w400,
                                        color: textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Smoothie de frutas",
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 16,
                                      color: Color(0xFFFF8A00),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "180 kcal",
                                      style: TextStyle(
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
                  ),

                  // --------- Siguientes comidas (reorder + swipe delete) ----------
                  sectionTitle("Siguientes comidas de hoy"),
                  const SizedBox(height: 10),

                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false, // ✅ sin puntitos
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _nextMeals.removeAt(oldIndex);
                        _nextMeals.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (int i = 0; i < _nextMeals.length; i++)
                        _dismissibleMealTile(
                          key: ValueKey(_nextMeals[i].id),
                          item: _nextMeals[i],
                          index: i,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DetailsRecipeScreen(),
                              ),
                            );
                          },
                          onDelete: () =>
                              setState(() => _nextMeals.removeAt(i)),
                          onToggleDone: () {
                            setState(() {
                              _nextMeals[i] = _nextMeals[i].copyWith(
                                done: !_nextMeals[i].done,
                              );
                              if (_nextMeals[i].done) {
                                // opcional: mover a “comido hoy”
                                final moved = _nextMeals.removeAt(i);
                                _eatenToday.insert(
                                  0,
                                  moved.copyWith(tag: moved.tag),
                                );
                              }
                            });
                          },
                        ),
                    ],
                  ),

                  // --------- Inspiración (igual) ----------
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
                      color: textGrey,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(22, 0, 0, 0),
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Foto de tu nevera",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "La IA te sugiere recetas\ncon lo que tienes disponible",
                          style: TextStyle(
                            color: Color.fromARGB(220, 255, 255, 255),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(
                            Icons.photo_camera_rounded,
                            color: Color(0xFF6D28D9),
                          ),
                          label: const Text(
                            "Abrir cámara",
                            style: TextStyle(
                              color: Color(0xFF6D28D9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () => _goToTab(2),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFBFEBDD),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7F2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: primaryGreen,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Buscar recetas",
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Por nombre o ingrediente",
                                  style: TextStyle(
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w400,
                                    color: textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: primaryGreen,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --------- Lo que has comido hoy (ahora lista real) ----------
                  sectionTitle("Lo que has comido hoy"),
                  const SizedBox(height: 10),

                  for (final item in _eatenToday)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: lineGrey, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3FBF7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  item.icon,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                DecoratedBox(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF4F6FA),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(999),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
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
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${item.kcal}\nkcal",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: primaryGreen,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ✅ Mi lista de compras -> TAB SHOP (igual)
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _goToTab(3),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(22, 0, 0, 0),
                            blurRadius: 14,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mi lista de\ncompras",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "12 productos\npendientes",
                                  style: TextStyle(
                                    color: Color.fromARGB(220, 255, 255, 255),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF7C3AED),
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Carrusel horizontal (Ayer / Mañana)
  Widget _dayCarousel({
    required String title,
    required List<_MiniMeal> items,
    VoidCallback? onTap,
  }) {
    const Color textGrey = Color(0xFF5A5565);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
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
                    color: primaryGreen,
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
            itemBuilder: (_, i) {
              final it = items[i];
              return Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE9E9EE),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3FBF7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          it.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            it.subtitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${it.kcal}\nkcal",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12.6,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
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

  // ✅ Dismissible + reorder por long press (SIN iconos/puntitos)
  Widget _dismissibleMealTile({
    required Key key,
    required _MealItem item,
    required int index,
    required VoidCallback onDelete,
    required VoidCallback onTap,
    required VoidCallback onToggleDone,
  }) {
    return Dismissible(
      key: key,
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      onDismissed: (_) => onDelete(),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9E9EE), width: 1.2),
              ),
              child: Row(
                children: [
                  // ✅ Marcar como “ya comido”
                  InkWell(
                    onTap: onToggleDone,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: item.done
                            ? const Color(0xFFEAF7F2)
                            : const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: item.done
                              ? primaryGreen
                              : const Color(0xFFE0E5EE),
                          width: 1.4,
                        ),
                      ),
                      child: Icon(
                        item.done ? Icons.check_rounded : Icons.circle_outlined,
                        size: 20,
                        color: item.done
                            ? primaryGreen
                            : const Color(0xFF9AA3B2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3FBF7),
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
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF5A5565),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5A5565),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${item.kcal}\nkcal",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5A5565),
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

  // ===================== NAV BAR (NO TOCAR) + SWIPE =====================
  @override
  Widget build(BuildContext context) {
    final List<String> icons = [
      "home_ico.png",
      "plan_ico.png",
      "search_ico.png",
      "shop_ico.png",
      "settings_ico.png",
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: Colors.grey[300]),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: icons.map((iconPath) {
              final index = icons.indexOf(iconPath);
              final isSelected = index == _selectedIndex;

              return BottomNavigationBarItem(
                icon: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 1.0,
                    end: isSelected ? 1.25 : 1.0,
                  ),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Image.asset(
                        iconPath,
                        width: 26,
                        height: 26,
                        color: isSelected
                            ? Colors.green[300]
                            : Colors.grey[500],
                      ),
                    );
                  },
                ),
                label: "",
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MealItem {
  final String id;
  final String icon;
  final String title;
  final String tag;
  final String time;
  final String kcal;
  final bool done;

  _MealItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.tag,
    required this.time,
    required this.kcal,
    this.done = false,
  });

  _MealItem copyWith({
    String? id,
    String? icon,
    String? title,
    String? tag,
    String? time,
    String? kcal,
    bool? done,
  }) {
    return _MealItem(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      tag: tag ?? this.tag,
      time: time ?? this.time,
      kcal: kcal ?? this.kcal,
      done: done ?? this.done,
    );
  }
}

class _MiniMeal {
  final String icon;
  final String title;
  final String subtitle;
  final String kcal;

  const _MiniMeal({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.kcal,
  });
}
