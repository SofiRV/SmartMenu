import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_config.dart';
import 'register_extra_food_screen.dart';
import 'saved_recipes_screen.dart';
import 'details_recipe_screen.dart';
import 'home/models/meal_item.dart';
import 'search_recipe_screen.dart'; // ← añadido

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);
const Color textGrey = Color(0xFF5A5565);
const Color textDark = Color(0xFF1A1A1A);

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int? _accountId;
  bool _loadingAccount = true;

  // Fechas de la semana
  late DateTime _weekStart; // lunes de la semana actual
  DateTime? _selectedDate; // día seleccionado (por defecto hoy)

  // Cache de comidas por fecha: clave = "dd-MM-yyyy", valor = lista de MealItem
  final Map<String, List<MealItem>> _mealsCache = {};

  // Conteo de comidas por fecha
  final Map<String, int> _mealCounts = {};

  bool _loadingMeals = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initDates();
    _loadAccountId();
  }

  void _initDates() {
    final now = DateTime.now();
    // Calcular lunes de la semana actual
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _selectedDate = now;
  }

  Future<void> _loadAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accountId = prefs.getInt('accountId');
      _loadingAccount = false;
    });
    if (_accountId != null) {
      _loadWeekData();
    }
  }

  String _dateKey(DateTime date) => DateFormat('dd-MM-yyyy').format(date);

  /// Carga las comidas de cada día de la semana actual.
  Future<void> _loadWeekData() async {
    if (_accountId == null) return;
    setState(() {
      _loadingMeals = true;
      _error = null;
    });

    try {
      for (int i = 0; i < 7; i++) {
        final date = _weekStart.add(Duration(days: i));
        final key = _dateKey(date);
        // Si ya lo tenemos en caché, no lo volvemos a pedir
        if (_mealsCache.containsKey(key)) continue;

        final uri = Uri.parse(
            ApiConfig.url("/meal/account/$_accountId/date/$key"));
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final mealsList = (decoded['meals'] as List?)
                  ?.map((m) => MealItem.fromBackend(m))
                  .toList() ??
              [];
          _mealsCache[key] = mealsList;
          _mealCounts[key] = mealsList.length;
        } else {
          _mealCounts[key] = 0;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loadingMeals = false);
    }
  }

  /// Navega al detalle de una comida.
  Future<void> _openMealDetail(MealItem meal) async {
    if (meal.foodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se puede mostrar detalle de esta comida")),
      );
      return;
    }

    try {
      final uri = Uri.parse(ApiConfig.url("/food/${meal.foodId}"));
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsRecipeScreen(recipeData: data),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar detalle (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingAccount) {
      return const Scaffold(
        backgroundColor: screenBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_accountId == null) {
      return const Scaffold(
        backgroundColor: screenBg,
        body: Center(child: Text("No se encontró la cuenta. Inicia sesión.")),
      );
    }

    // Días de la semana
    final weekDays = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    // Obtener comidas del día seleccionado
    final selectedKey = _selectedDate != null ? _dateKey(_selectedDate!) : null;
    final List<MealItem> selectedMeals =
        selectedKey != null ? (_mealsCache[selectedKey] ?? []) : [];

    final int totalKcal = selectedMeals.fold(
        0, (sum, m) => sum + (int.tryParse(m.kcal) ?? 0));
    final int totalMeals = selectedMeals.length;

    // Nombre del mes en curso
    final monthLabel = DateFormat('MMMM yyyy', 'es').format(_weekStart);

    return Scaffold(
      backgroundColor: screenBg,
      body: Column(
        children: [
          // Header verde (mismo estilo que Home)
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
                          "Plan semanal 📅",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          monthLabel,
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
                      child: Icon(Icons.calendar_month_rounded,
                          color: primaryGreen, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: _loadingMeals
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      _mealsCache.clear();
                      _mealCounts.clear();
                      await _loadWeekData();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resumen del día seleccionado
                          if (_selectedDate != null) ...[
                            _summaryCard(
                              date: _selectedDate!,
                              mealsCount: totalMeals,
                              totalKcal: totalKcal,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Grid de días de la semana
                          _daysGrid(weekDays),
                          const SizedBox(height: 18),

                          // Comidas del día seleccionado
                          if (_selectedDate != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Comidas planeadas",
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Ver detalles",
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (selectedMeals.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    "No hay comidas registradas para este día.",
                                    style: TextStyle(color: textGrey),
                                  ),
                                ),
                              )
                            else
                              ...selectedMeals.map((meal) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _mealCardFromBackend(meal),
                                  )),
                          ],

                          const SizedBox(height: 10),

                          // Botones inferiores (iconos con tooltip)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Tooltip(
                                message: 'Recetas guardadas',
                                child: IconButton(
                                  icon: const Icon(Icons.bookmark, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SavedRecipesScreen()),
                                    );
                                  },
                                  style: IconButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14))),
                                ),
                              ),
                              Tooltip(
                                message: 'Buscar receta',
                                child: IconButton(
                                  icon: const Icon(Icons.search, color: Colors.white),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => SearchRecipeScreen(
                                                planDate: _selectedDate,
                                              )),
                                    );
                                    if (result == true) {
                                      _mealsCache.clear();
                                      _mealCounts.clear();
                                      _loadWeekData();
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14))),
                                ),
                              ),
                              Tooltip(
                                message: 'Añadir comida extra',
                                child: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => RegisterExtraFoodScreen(
                                              initialDate: _selectedDate)),
                                    );
                                    if (result == true) {
                                      _mealsCache.clear();
                                      _mealCounts.clear();
                                      _loadWeekData();
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ================== UI ==================

  Widget _summaryCard({
    required DateTime date,
    required int mealsCount,
    required int totalKcal,
  }) {
    final dayName = DateFormat('EEEE', 'es').format(date);
    final dayNumber = date.day;
    final monthShort = DateFormat('MMM', 'es').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(22, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Día seleccionado",
                  style: TextStyle(fontSize: 13, color: textGrey),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        "$dayNumber $monthShort",
                        style: const TextStyle(fontSize: 14, color: textGrey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFFF7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        "Total del día:",
                        style: TextStyle(fontSize: 13.5, color: textGrey),
                      ),
                      const Spacer(),
                      Text(
                        "$totalKcal",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryGreen),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "kcal",
                        style: TextStyle(fontSize: 13, color: textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFFFF7),
                ),
                child: const Icon(Icons.calendar_month,
                    color: primaryGreen, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                "$mealsCount comidas",
                style: const TextStyle(fontSize: 12.5, color: textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _daysGrid(List<DateTime> weekDays) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: weekDays.map((date) {
        final bool isSelected = _selectedDate != null &&
            _dateKey(date) == _dateKey(_selectedDate!);
        final bool isToday = _dateKey(date) == _dateKey(DateTime.now());
        final dayName = DateFormat('EEE', 'es').format(date);
        final dayNumber = date.day;
        final key = _dateKey(date);
        final mealCount = _mealCounts[key] ?? 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            width: (MediaQuery.of(context).size.width - 18 * 2 - 12 * 2) / 3,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? primaryGreen
                    : isToday
                        ? primaryGreen.withOpacity(0.5)
                        : const Color(0xFFE6E6E6),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(18, 0, 0, 0),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? Colors.white70 : textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$dayNumber",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mealCount == 0 ? "" : "$mealCount comidas",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? Colors.white : primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _mealCardFromBackend(MealItem meal) {
    return InkWell(
      onTap: () => _openMealDetail(meal),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E9EE), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3FBF7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(meal.icon, style: const TextStyle(fontSize: 20)),
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
                          color: _tagColor(meal.tag),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            meal.tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time,
                          size: 16, color: textGrey),
                      const SizedBox(width: 6),
                      Text(
                        meal.time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 16, color: Color(0xFFFF8A00)),
                      const SizedBox(width: 6),
                      Text(
                        "${meal.kcal} kcal",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Color(0xFF9AA0AA)),
          ],
        ),
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Desayuno':
        return const Color(0xFFFF8A00);
      case 'Snack':
        return const Color(0xFF8B3DFF);
      case 'Comida':
        return const Color(0xFF00A86B);
      case 'Merienda':
        return const Color(0xFF2F73FF);
      case 'Cena':
        return const Color(0xFF7C3AED);
      default:
        return primaryGreen;
    }
  }

  Widget _bottomActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}