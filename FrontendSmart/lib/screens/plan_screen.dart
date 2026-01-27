import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int selectedDay = 18; // Mié 18 Oct (como la imagen)
  final String monthLabel = "Octubre 2025";

  // Ejemplo de días del grid (como la imagen)
  final List<_DayItem> days = const [
    _DayItem(dayName: "Lun", dayNumber: 16, meals: 3),
    _DayItem(dayName: "Mar", dayNumber: 17, meals: 3),
    _DayItem(dayName: "Mié", dayNumber: 18, meals: 4),
    _DayItem(dayName: "Jue", dayNumber: 19, meals: 1),
    _DayItem(dayName: "Vie", dayNumber: 20, meals: 2),
    _DayItem(dayName: "Sáb", dayNumber: 21, meals: 0),
    _DayItem(dayName: "Dom", dayNumber: 22, meals: 0, fullWidth: true),
  ];

  // Comidas del día seleccionado (como la imagen)
  final List<_MealItem> meals = const [
    _MealItem(
      tag: "Desayuno",
      time: "08:00",
      title: "Avena con plátano",
      kcal: 350,
      borderColor: Color(0xFFFFC17A),
      bgColor: Color(0xFFFFF6E9),
      tagColor: Color(0xFFFF8A00),
      asset: "breakfast.png",
    ),
    _MealItem(
      tag: "Snack",
      time: "11:00",
      title: "Smoothie de frutas",
      kcal: 180,
      borderColor: Color(0xFFD7B8FF),
      bgColor: Color(0xFFF6EDFF),
      tagColor: Color(0xFF8B3DFF),
      asset: "snack.png",
    ),
    _MealItem(
      tag: "Comida",
      time: "14:00",
      title: "Arroz con pollo",
      kcal: 520,
      borderColor: Color(0xFF9FE7C6),
      bgColor: Color(0xFFEFFFF7),
      tagColor: Color(0xFF00A86B),
      asset: "lunch.png",
    ),
    _MealItem(
      tag: "Cena",
      time: "20:00",
      title: "Sopa de verduras",
      kcal: 280,
      borderColor: Color(0xFFAFCBFF),
      bgColor: Color(0xFFEEF5FF),
      tagColor: Color(0xFF2F73FF),
      asset: "dinner.png",
    ),
  ];

  int get totalKcal => meals.fold(0, (sum, m) => sum + m.kcal);
  int get totalMeals => meals.length;

  @override
  Widget build(BuildContext context) {
    final selected = days.firstWhere((d) => d.dayNumber == selectedDay);

    return Scaffold(
      backgroundColor: screenBg,

      // ✅ SIN APPBAR: usamos header idéntico al Home
      body: Column(
        children: [
          // ================= Header verde (MISMO que Home) =================
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

                  // (opcional) circulito a la derecha como Home
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: primaryGreen,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= Contenido scroll =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(
                    dayName: selected.dayName,
                    dayNumber: selected.dayNumber,
                    monthShort: "Oct",
                    mealsCount: totalMeals,
                    totalKcal: totalKcal,
                  ),
                  const SizedBox(height: 16),

                  _daysGrid(),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Comidas planeadas",
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
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

                  ...meals.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _mealCard(m),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _bottomActionButton(
                          text: "Receta\nguardada",
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _bottomActionButton(
                          text: "Nueva\nreceta",
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== UI ==================

  Widget _summaryCard({
    required String dayName,
    required int dayNumber,
    required String monthShort,
    required int mealsCount,
    required int totalKcal,
  }) {
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5A5565),
                  ),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF5A5565),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFFF7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: primaryGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Total del día:",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF5A5565),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "$totalKcal",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "kcal",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF5A5565),
                        ),
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
                child: const Icon(
                  Icons.calendar_month,
                  color: primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$mealsCount comidas",
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5A5565),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _daysGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: days.map((d) {
        final bool isSelected = d.dayNumber == selectedDay;

        final card = GestureDetector(
          onTap: () => setState(() => selectedDay = d.dayNumber),
          child: Container(
            width: d.fullWidth
                ? double.infinity
                : (MediaQuery.of(context).size.width - 18 * 2 - 12 * 2) / 3,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? primaryGreen : const Color(0xFFE6E6E6),
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
                  d.dayName,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? Colors.white70
                        : const Color(0xFF5A5565),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${d.dayNumber}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  d.meals == 0 ? "" : "${d.meals} comidas",
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

        return card;
      }).toList(),
    );
  }

  Widget _mealCard(_MealItem m) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: m.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: m.borderColor, width: 1.6),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Image.asset(
                m.asset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.restaurant, color: Color(0xFF5A5565)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: m.tagColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        m.tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF5A5565),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m.time,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5A5565),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  m.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Color(0xFFFF8A00),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${m.kcal} kcal",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5A5565),
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
    );
  }

  Widget _bottomActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== MODELOS ==================

class _DayItem {
  final String dayName;
  final int dayNumber;
  final int meals;
  final bool fullWidth;
  const _DayItem({
    required this.dayName,
    required this.dayNumber,
    required this.meals,
    this.fullWidth = false,
  });
}

class _MealItem {
  final String tag;
  final String time;
  final String title;
  final int kcal;
  final Color borderColor;
  final Color bgColor;
  final Color tagColor;
  final String asset;

  const _MealItem({
    required this.tag,
    required this.time,
    required this.title,
    required this.kcal,
    required this.borderColor,
    required this.bgColor,
    required this.tagColor,
    required this.asset,
  });
}
