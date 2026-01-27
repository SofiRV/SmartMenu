import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFEFF7F5);

class DetailsRecipeScreen extends StatefulWidget {
  const DetailsRecipeScreen({super.key});

  @override
  State<DetailsRecipeScreen> createState() => _DetailsRecipeScreenState();
}

class _DetailsRecipeScreenState extends State<DetailsRecipeScreen> {
  bool isFavorite = false;

  final List<_IngredientRow> ingredients = const [
    _IngredientRow(emoji: "🥬", name: "Lechuga romana", amount: "1 unidad"),
    _IngredientRow(emoji: "🍗", name: "Pollo", amount: "300 g"),
    _IngredientRow(emoji: "🥖", name: "Pan", amount: "100 g"),
    _IngredientRow(emoji: "🧀", name: "Queso parmesano", amount: "50 g"),
    _IngredientRow(emoji: "🥫", name: "Salsa César", amount: "100 ml"),
  ];

  final List<String> steps = const [
    "Lava y corta la lechuga en trozos medianos",
    "Cocina el pollo a la plancha con sal y pimienta",
    "Tuesta el pan y córtalo en cubos",
    "Mezcla la lechuga con la salsa César",
    "Añade el pollo troceado y el pan tostado",
    "Finaliza con queso parmesano rallado",
  ];

  int checkedCount = 0; // demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      body: Stack(
        children: [
          Container(
            height: 340,
            width: double.infinity,
            decoration: const BoxDecoration(color: primaryGreen),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      _circleButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      _circleButton(
                        icon: isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        onTap: () => setState(() => isFavorite = !isFavorite),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text("🥗", style: TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    child: Column(
                      children: [
                        _mainInfoCard(),
                        const SizedBox(height: 14),
                        _nutritionCard(),
                        const SizedBox(height: 14),
                        _ingredientsCard(),
                        const SizedBox(height: 14),
                        _stepsCard(),
                        const SizedBox(height: 14),
                        _chefTipCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Añadir al plan semanal",
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(18, 0, 0, 0),
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ensalada César",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Pill(
                text: "Fácil",
                bg: Color(0xFFDDF7EE),
                fg: Color(0xFF0B9965),
              ),
              _Pill(
                text: "Ensaladas",
                bg: Color(0xFFEAF3FF),
                fg: Color(0xFF2F73FF),
              ),
              _Pill(
                text: "Vegetariano",
                bg: Color(0xFFF2E9FF),
                fg: Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _StatBox(
                  icon: Icons.access_time_rounded,
                  title: "Tiempo",
                  value: "20 min",
                  bg: Color(0xFFEAF3FF),
                  iconColor: Color(0xFF2F73FF),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.groups_rounded,
                  title: "Porciones",
                  value: "2 personas",
                  bg: Color(0xFFF2E9FF),
                  iconColor: Color(0xFF7C3AED),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.local_fire_department_rounded,
                  title: "Calorías",
                  value: "320 kcal",
                  bg: Color(0xFFFFF3D9),
                  iconColor: Color(0xFFFF8A00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutritionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(14, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Información nutricional (por porción)",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _MiniNutrition(
                  bg: Color(0xFFEAF3FF),
                  emoji: "🍗",
                  label: "Proteínas",
                  value: "18 g",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniNutrition(
                  bg: Color(0xFFDDF7EE),
                  emoji: "🌾",
                  label: "Carbohidratos",
                  value: "12 g",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniNutrition(
                  bg: Color(0xFFFFF3D9),
                  emoji: "🥑",
                  label: "Grasas",
                  value: "22 g",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MiniNutrition(
                  bg: Color(0xFFF2E9FF),
                  emoji: "🥕",
                  label: "Fibra",
                  value: "4 g",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ingredientsCard() {
    final total = ingredients.length;
    final done = checkedCount.clamp(0, total);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(14, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Ingredientes",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Text(
                "$done/$total listos",
                style: const TextStyle(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ingredients.map((it) => _ingredientTile(it)).toList(),
        ],
      ),
    );
  }

  // ✅ ESTE ES EL MÉTODO QUE TE FALTA
  Widget _ingredientTile(_IngredientRow item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC9CDD5), width: 2),
            ),
          ),
          const SizedBox(width: 10),
          Text(item.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 13.8,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            item.amount,
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A5565),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(14, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Paso a paso",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.25,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _chefTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFD7FF), width: 1.2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("💡", style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Consejo del chef\nPara más sabor, añade trocitos de bacon crujiente o anchoas. También puedes usar pollo asado del día anterior para ahorrar tiempo.",
              style: TextStyle(
                fontSize: 13.5,
                height: 1.25,
                color: Color(0xFF1B44BF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

// ✅ ESTE TIPO TAMBIÉN TE FALTA (por eso te da el error)
class _IngredientRow {
  final String emoji;
  final String name;
  final String amount;
  const _IngredientRow({
    required this.emoji,
    required this.name,
    required this.amount,
  });
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color bg;
  final Color iconColor;

  const _StatBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.2,
              color: Color(0xFF5A5565),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniNutrition extends StatelessWidget {
  final Color bg;
  final String emoji;
  final String label;
  final String value;

  const _MiniNutrition({
    required this.bg,
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.2,
              color: Color(0xFF5A5565),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
