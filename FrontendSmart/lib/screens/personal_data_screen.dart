import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color softGreen = Color.fromARGB(255, 220, 245, 236);

// 🎨 Colores
const Color inputGreyText = Color(0xFF5A5565);
const Color emojiGrey = Color(0xFFC9CDD5);
const Color recoTextBlue = Color(0xFF1B44BF);
const Color recoBg = Color(0xFFEFF6FF);
const Color recoBorder = Color(0xFFBFD7FF);

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();

  String selectedGender = "Mujer";
  String activityLevel = "Ligero (ejercicio 1-3 día)";
  double? _bmi;
  double? _calories;

  final Map<String, double> _activityFactors = {
    'Bajo (poco o nada)': 1.2,
    'Ligero (ejercicio 1-3 día)': 1.375,
    'Moderado (ejercicio 3-5 día)': 1.55,
    'Alto (ejercicio 6-7 día)': 1.725,
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();

    _ageCtrl.addListener(_autoCalculate);
    _weightCtrl.addListener(_autoCalculate);
    _heightCtrl.addListener(_autoCalculate);
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ageCtrl.text = prefs.getString('age') ?? '';
      _weightCtrl.text = prefs.getString('weight') ?? '';
      _heightCtrl.text = prefs.getString('height') ?? '';
      selectedGender = prefs.getString('gender') ?? 'Mujer';
      activityLevel =
          prefs.getString('activity') ?? 'Ligero (ejercicio 1-3 día)';
    });
    _autoCalculate();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('age', _ageCtrl.text.trim());
    await prefs.setString('weight', _weightCtrl.text.trim());
    await prefs.setString('height', _heightCtrl.text.trim());
    await prefs.setString('gender', selectedGender);
    await prefs.setString('activity', activityLevel);
  }

  void _autoCalculate() {
    if (_ageCtrl.text.trim().isEmpty ||
        _weightCtrl.text.trim().isEmpty ||
        _heightCtrl.text.trim().isEmpty) {
      setState(() {
        _bmi = null;
        _calories = null;
      });
      return;
    }

    final age = int.tryParse(_ageCtrl.text.trim());
    final weight = double.tryParse(
      _weightCtrl.text.trim().replaceAll(',', '.'),
    );
    final heightCm = double.tryParse(
      _heightCtrl.text.trim().replaceAll(',', '.'),
    );

    if (age == null || weight == null || heightCm == null || heightCm == 0) {
      setState(() {
        _bmi = null;
        _calories = null;
      });
      return;
    }

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);

    double bmr = selectedGender == "Mujer"
        ? 10 * weight + 6.25 * heightCm - 5 * age - 161
        : 10 * weight + 6.25 * heightCm - 5 * age + 5;

    final calories = bmr * (_activityFactors[activityLevel] ?? 1.375);

    setState(() {
      _bmi = double.parse(bmi.toStringAsFixed(1));
      _calories = double.parse(calories.toStringAsFixed(0));
    });

    _saveData();
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return "Peso insuficiente";
    if (bmi < 25) return "Peso normal";
    if (bmi < 30) return "Sobrepeso";
    return "Obesidad";
  }

  @override
  Widget build(BuildContext context) {
    final bool showResults = _bmi != null && _calories != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),

      // ✅ SIN APPBAR -> ahora TODO hace scroll
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================== CABECERA + TARJETA AZUL SUPERPUESTA ==================
            Stack(
              clipBehavior:
                  Clip.none, // ✅ permite que la tarjeta “salga” del verde
              children: [
                // CABECERA VERDE (se mueve con el scroll)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 60,
                    bottom: 36,
                  ),
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tus datos personales",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Para personalizar tu experiencia",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // TARJETA AZUL “encima” del verde
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -58, // ✅ sube y tapa el verde (ajusta -20/-30/-35)
                  child: _recommendationCard(fullWidth: true),
                ),
              ],
            ),

            // Este espacio compensa el "bottom:-28" para que no se monte con el siguiente contenido
            const SizedBox(height: 75),

            // ================== FORM ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _formCard(),
            ),

            const SizedBox(height: 20),

            // ================== RESULTADOS ==================
            if (showResults) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _bmiCard(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _caloriesCard(),
              ),
              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/account_type');
                  },
                  child: const Text(
                    "Continuar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ],
        ),
      ),
    );
  }

  // ================= FORM =================
  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(31, 60, 60, 60), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input("Edad", "años", Icons.cake, _ageCtrl),
          const SizedBox(height: 15),
          _input("Peso", "kg", Icons.monitor_weight, _weightCtrl),
          const SizedBox(height: 15),
          _input("Altura", "cm", Icons.height, _heightCtrl),
          const SizedBox(height: 20),

          const Text(
            "Género",
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _genderButton("Mujer", "👩"),
              const SizedBox(width: 10),
              _genderButton("Hombre", "👨"),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            "Nivel de actividad física",
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: activityLevel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A1A1A),
            ),
            items: _activityFactors.keys
                .map(
                  (k) => DropdownMenuItem<String>(
                    value: k,
                    child: Text(
                      k,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),
                  ),
                )
                .toList(),
            decoration: _dropdownStyle(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => activityLevel = v);
              _autoCalculate();
            },
          ),
        ],
      ),
    );
  }

  Widget _input(
    String label,
    String suffix,
    IconData icon,
    TextEditingController ctrl,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: Color.fromARGB(255, 66, 66, 66),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: inputGreyText),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: inputGreyText),
        prefixIcon: Icon(icon, color: inputGreyText),
        floatingLabelStyle: const TextStyle(color: primaryGreen),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  InputDecoration _dropdownStyle() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 219, 218, 218),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 219, 218, 218),
          width: 1,
        ),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _genderButton(String text, String emoji) {
    final selected = selectedGender == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedGender = text);
          _autoCalculate();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 231, 255, 246)
                : const Color.fromARGB(255, 248, 244, 244),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? primaryGreen : const Color(0xFFE6E6E6),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: selected
                      ? Colors.black
                      : const Color.fromARGB(255, 75, 75, 75),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= RECOMENDACIÓN =================
  Widget _recommendationCard({bool fullWidth = false}) {
    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: recoBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: recoBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(18, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("💡", style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Estos datos nos ayudan a calcular tus necesidades calóricas y recomendarte recetas adecuadas para ti.",
              style: TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: Color.fromARGB(255, 71, 108, 220),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (fullWidth) return card;

    return FractionallySizedBox(widthFactor: 0.92, child: card);
  }

  // ================= RESULTS =================
  Widget _bmiCard() {
    final category = _bmiCategory(_bmi!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 253, 247),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tu Índice de Masa Corporal\n(IMC)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5A5565),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.normal,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text("💪", style: TextStyle(fontSize: 52)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 50, 196, 142),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category == "Peso normal"
                            ? "Peso normal (18.5 - 24.9)"
                            : category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 52, 51, 51),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category == "Peso normal"
                            ? "Tu IMC indica un peso saludable.\n¡Sigue así! 🎉"
                            : "Tu IMC indica $category.\nTe recomendamos consultar con un profesional.",
                        style: const TextStyle(
                          fontSize: 12.8,
                          height: 1.25,
                          color: inputGreyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _caloriesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_fire_department, color: primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Calorías recomendadas",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 6),
                Text(
                  "${_calories!.toStringAsFixed(0)} kcal/día",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Basado en tu edad, peso, altura y nivel de actividad física",
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.25,
                    color: inputGreyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
