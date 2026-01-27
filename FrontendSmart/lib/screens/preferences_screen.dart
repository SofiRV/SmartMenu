import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

const Color textPrimary = Color(0xFF1A1A1A);
const Color textGrey = Color(0xFF5A5565);
const Color borderGrey = Color.fromARGB(255, 248, 240, 240);

const Color boxGreen = Color.fromARGB(255, 220, 245, 236);
const Color boxBlue = Color(0xFFEAF3FF);

const Color dangerRed = Color(0xFFE23B3B);
const Color dangerBg = Color(0xFFFFF1F1);

const Color blueAccent = Color(0xFF2F73FF);
const Color blueBorder = Color(0xFF2F73FF);
const Color blueBgSoft = Color(0xFFEFF5FF);

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  String selectedDiet = 'Vegetariana';

  final TextEditingController _customNameCtrl = TextEditingController();
  final TextEditingController _customDescCtrl = TextEditingController();
  String selectedEmoji = '🥗';

  // ✅ SOLO 1 meta física
  String selectedFitnessGoal = 'Mantenimiento';

  final TextEditingController _newAllergenCtrl = TextEditingController();
  final TextEditingController _newBlacklistCtrl = TextEditingController();

  final List<Map<String, dynamic>> diets = [
    {'name': 'Vegetariana', 'emoji': '🥗', 'desc': 'Sin carne ni pescado'},
    {'name': 'Vegana', 'emoji': '🌱', 'desc': 'Sin productos animales'},
    {'name': 'Omnívora', 'emoji': '🍖', 'desc': 'Todo tipo de alimentos'},
    {'name': 'Pescetariana', 'emoji': '🐟', 'desc': 'Sin carne, con pescado'},
    {'name': 'Keto', 'emoji': '🥑', 'desc': 'Baja en carbohidratos'},
    {
      'name': 'Mediterránea',
      'emoji': '🫒',
      'desc': 'Frutas, verduras, aceite de oliva',
    },
    {'name': 'Paleo', 'emoji': '🍖', 'desc': 'Como en la prehistoria'},
  ];

  final List<String> emojis = ['🥑', '🍊', '🦁', '🍱', '🥗', '🌮'];

  final List<Map<String, dynamic>> fitnessGoals = [
    {
      'name': 'Perder peso',
      'emoji': '📉',
      'desc': 'Reducirás 500 kcal del objetivo diario',
      'accent': dangerRed,
      'bg': const Color(0xFFFFF1F1),
      'border': const Color(0xFFFFC9C9),
    },
    {
      'name': 'Mantenimiento',
      'emoji': '💚',
      'desc': 'Mantén tu ingesta calórica actual',
      'accent': blueAccent,
      'bg': blueBgSoft,
      'border': blueBorder,
    },
    {
      'name': 'Ganar masa muscular',
      'emoji': '💪',
      'desc': 'Aumentarás 300 kcal del objetivo diario',
      'accent': const Color(0xFFF59E0B),
      'bg': const Color(0xFFFFF7E6),
      'border': const Color(0xFFFFE0A3),
    },
    {
      'name': 'Mejorar salud',
      'emoji': '❤️',
      'desc': 'Enfoque en nutrición balanceada',
      'accent': const Color(0xFFEC4899),
      'bg': const Color(0xFFFFF1F7),
      'border': const Color(0xFFFFC7DF),
    },
  ];

  final List<Map<String, dynamic>> allergens = [
    {'name': 'Gluten', 'emoji': '🌾', 'selected': false},
    {'name': 'Lácteos', 'emoji': '🥛', 'selected': false},
    {'name': 'Frutos secos', 'emoji': '🥜', 'selected': false},
    {'name': 'Huevos', 'emoji': '🥚', 'selected': false},
    {'name': 'Mariscos', 'emoji': '🦐', 'selected': false},
    {'name': 'Soja', 'emoji': '🌱', 'selected': false},
  ];

  final List<Map<String, dynamic>> blacklist = [
    {'name': 'Pimiento', 'emoji': '🫑'},
    {'name': 'Pescado azul', 'emoji': '🐟'},
    {'name': 'Champiñones', 'emoji': '🍄'},
    {'name': 'Espinacas', 'emoji': '🥬'},
    {'name': 'Remolacha', 'emoji': '🫒'},
  ];

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _customDescCtrl.dispose();
    _newAllergenCtrl.dispose();
    _newBlacklistCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // aquí guardarías en prefs / backend, etc.
    Navigator.pushReplacementNamed(context, '/individual_home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,

      // ✅ sin botón de volver
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          120,
        ), // un poquito más pequeña que 130
        child: Container(
          decoration: const BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 24, top: 26, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Preferencias",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26, // un poco más pequeña que 28
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Personaliza tu experiencia",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ✅ Botón SOLO al final de todo
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              "Tipo de dieta",
              "Selecciona tu estilo de alimentación",
            ),
            const SizedBox(height: 12),
            _dietGrid(),
            const SizedBox(height: 24),

            _sectionTitle(
              "Meta física",
              "Selecciona solo un objetivo. Esto ajustará tu ingesta calórica.",
            ),
            const SizedBox(height: 12),
            _fitnessGoalList(),
            const SizedBox(height: 26),

            _sectionTitle("Alérgenos", "Selecciona o añade tus alergias"),
            const SizedBox(height: 12),
            _allergensChips(),
            const SizedBox(height: 12),
            _addAllergenRow(),
            const SizedBox(height: 26),

            _sectionTitle("Lista negra", "Alimentos que no te gustan"),
            const SizedBox(height: 12),
            _blacklistList(),
            const SizedBox(height: 12),
            _addBlacklistRow(),
            const SizedBox(height: 26),

            // ✅ BOTÓN SOLO AL FINAL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Guardar preferencias",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== UI PIECES ==================

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textGrey,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(18, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ================== DIETS ==================

  Widget _dietGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: diets.map((diet) {
        final bool isSelected = diet['name'] == selectedDiet;

        return GestureDetector(
          onTap: () => setState(() => selectedDiet = diet['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: (MediaQuery.of(context).size.width - 18 * 2 - 12) / 2,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? primaryGreen : borderGrey,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(12, 0, 0, 0),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(diet['emoji'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 10),
                    Text(
                      diet['name'],
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? textPrimary : textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diet['desc'],
                      style: const TextStyle(
                        fontSize: 12.2,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? primaryGreen : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? primaryGreen
                            : const Color(0xFFC9CDD5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _customDietCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input(
            controller: _customNameCtrl,
            label: "Nombre de la dieta",
            hint: "Ej: Sin azúcar, Alta proteína…",
          ),
          const SizedBox(height: 12),
          _input(
            controller: _customDescCtrl,
            label: "Descripción breve (opcional)",
            hint: "Ej: Basada en alimentos integrales…",
          ),
          const SizedBox(height: 12),
          const Text(
            "Elige un emoji",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: emojis.map((e) {
              final bool isSelected = selectedEmoji == e;
              return GestureDetector(
                onTap: () => setState(() => selectedEmoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? boxGreen : const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? primaryGreen
                          : const Color(0xFFE3E6EA),
                      width: isSelected ? 1.6 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(e, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_customNameCtrl.text.trim().isEmpty) return;
                setState(() {
                  diets.add({
                    'name': _customNameCtrl.text.trim(),
                    'emoji': selectedEmoji,
                    'desc': _customDescCtrl.text.trim(),
                  });
                  selectedDiet = _customNameCtrl.text.trim();
                  _customNameCtrl.clear();
                  _customDescCtrl.clear();
                  selectedEmoji = '🥗';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Crear dieta personalizada",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: textGrey,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA3AE),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  // ================== FITNESS GOAL (1 solo) ==================

  Widget _fitnessGoalList() {
    return Column(
      children: fitnessGoals.map((g) {
        final bool isSelected = selectedFitnessGoal == g['name'];
        final Color accent = g['accent'];
        final Color bg = g['bg'];
        final Color border = g['border'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => selectedFitnessGoal = g['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? border : borderGrey,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(14, 0, 0, 0),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      g['emoji'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g['name'],
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g['desc'],
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: textGrey,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? accent : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? accent : const Color(0xFFC9CDD5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================== ALLERGENS (chips finitos y más circulares) ==================

  Widget _allergensChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: allergens.map((a) {
        final bool sel = a['selected'] == true;

        return GestureDetector(
          onTap: () => setState(() => a['selected'] = !sel),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? dangerBg : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: sel ? dangerRed : const Color(0xFFD7DDE3),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(a['emoji'], style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  a['name'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: sel ? dangerRed : textGrey,
                  ),
                ),
                if (sel) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: dangerRed,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _addAllergenRow() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Añadir otro alérgeno",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newAllergenCtrl,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ej: Cacahuetes, Mostaza…",
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA3AE),
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: borderGrey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 202, 25, 25),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final t = _newAllergenCtrl.text.trim();
                  if (t.isEmpty) return;
                  setState(() {
                    allergens.add({'name': t, 'emoji': '⚠️', 'selected': true});
                    _newAllergenCtrl.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "+",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== BLACKLIST (lista vertical tipo la imagen) ==================

  Widget _blacklistList() {
    return Column(
      children: blacklist.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _card(
            child: Row(
              children: [
                Text(item['emoji'], style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => blacklist.remove(item)),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE7E7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.close, size: 16, color: dangerRed),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _addBlacklistRow() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Añadir alimento que no te gusta",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newBlacklistCtrl,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ej: Brócoli, Cebolla…",
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA3AE),
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: borderGrey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 31, 114, 81),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final t = _newBlacklistCtrl.text.trim();
                  if (t.isEmpty) return;
                  setState(() {
                    blacklist.add({'name': t, 'emoji': '❌'});
                    _newBlacklistCtrl.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "+",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
