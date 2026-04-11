import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color softGreen = Color.fromARGB(255, 220, 245, 236);

// 🎨 Colores
const Color inputGreyText = Color(0xFF5A5565);
const Color emojiGrey = Color(0xFFC9CDD5);
const Color recoBg = Color(0xFFEFF6FF);
const Color recoBorder = Color(0xFFBFD7FF);

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final TextEditingController _profileNameCtrl = TextEditingController();

  // birthDate se selecciona con DatePicker; este controller es solo para mostrar el string
  final TextEditingController _birthDateCtrl = TextEditingController();
  DateTime? _birthDate;

  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _waistCtrl = TextEditingController();
  final TextEditingController _hipsCtrl = TextEditingController();

  // Backend enums: Sex: male/female
  String selectedSexUi = "Mujer"; // UI
  String get selectedSexApi => selectedSexUi == "Mujer" ? "female" : "male";

  // Backend enums ActivityLevel:
  // very low | low | mid | high | very high
  String activityLevelApi = "mid";

  double? _bmi;
  double? _calories;

  int? _accountId;

  // Validación UI
  String? _profileNameError;
  String? _birthDateError;
  String? _numericError;

  final Map<String, String> _activityUiToApi = const {
    'Muy bajo (casi nada)': 'very low',
    'Bajo (poco)': 'low',
    'Medio (3-5 días/sem)': 'mid',
    'Alto (6-7 días/sem)': 'high',
    'Muy alto (doble sesión / trabajo físico)': 'very high',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();

    _profileNameCtrl.addListener(_validateAndSave);
    _weightCtrl.addListener(_validateAndRecalc);
    _heightCtrl.addListener(_validateAndRecalc);
    _waistCtrl.addListener(_validateAndRecalc);
    _hipsCtrl.addListener(_validateAndRecalc);
  }

  @override
  void dispose() {
    _profileNameCtrl.dispose();
    _birthDateCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _waistCtrl.dispose();
    _hipsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    final birthIso = prefs.getString('birthDate'); // YYYY-MM-DD
    DateTime? birth;
    if (birthIso != null && birthIso.trim().isNotEmpty) {
      birth = DateTime.tryParse(birthIso.trim());
    }

    setState(() {
      _accountId = prefs.getInt('accountId');

      _profileNameCtrl.text = prefs.getString('profileName') ?? '';

      _birthDate = birth;
      _birthDateCtrl.text = birth == null ? '' : _formatDate(birth);

      selectedSexUi = (prefs.getString('sexUi') ?? 'Mujer');
      activityLevelApi = (prefs.getString('activityLevelApi') ?? 'mid');

      _weightCtrl.text = prefs.getString('weight') ?? '';
      _heightCtrl.text = prefs.getString('height') ?? '';
      _waistCtrl.text = prefs.getString('waist') ?? '';
      _hipsCtrl.text = prefs.getString('hips') ?? '';
    });

    _validateAndRecalc();
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profileName', _profileNameCtrl.text.trim());
    await prefs.setString('sexUi', selectedSexUi);
    await prefs.setString('sexApi', selectedSexApi);

    await prefs.setString('activityLevelApi', activityLevelApi);

    await prefs.setString('weight', _weightCtrl.text.trim());
    await prefs.setString('height', _heightCtrl.text.trim());
    await prefs.setString('waist', _waistCtrl.text.trim());
    await prefs.setString('hips', _hipsCtrl.text.trim());

    // birthDate en ISO para backend
    await prefs.setString(
      'birthDate',
      _birthDate == null ? '' : _toIsoDate(_birthDate!),
    );
  }

  void _validateAndSave() {
    _validate();
    _saveDraft();
  }

  void _validateAndRecalc() {
    _validate();
    _recalculate();
    _saveDraft();
  }

  void _validate() {
    final name = _profileNameCtrl.text.trim();

    setState(() {
      _profileNameError = name.isEmpty ? "El nombre de perfil es obligatorio" : null;
      _birthDateError = _birthDate == null ? "La fecha de nacimiento es obligatoria" : null;

      _numericError = null;
      if (_parseDouble(_weightCtrl.text) == null ||
          _parseDouble(_heightCtrl.text) == null ||
          _parseDouble(_waistCtrl.text) == null ||
          _parseDouble(_hipsCtrl.text) == null) {
        _numericError = "Revisa los campos numéricos (peso/altura/cintura/cadera).";
      }
    });
  }

  int? _ageFromBirthDate(DateTime birth) {
    final now = DateTime.now();
    int age = now.year - birth.year;
    final hadBirthdayThisYear =
        (now.month > birth.month) || (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthdayThisYear) age -= 1;
    if (age < 0 || age > 120) return null;
    return age;
  }

  void _recalculate() {
    // Solo calculamos IMC/calorías si todo está presente
    if (_birthDate == null) {
      setState(() {
        _bmi = null;
        _calories = null;
      });
      return;
    }

    final age = _ageFromBirthDate(_birthDate!);
    final weight = _parseDouble(_weightCtrl.text);
    final heightCm = _parseDouble(_heightCtrl.text);

    if (age == null || weight == null || heightCm == null || heightCm == 0) {
      setState(() {
        _bmi = null;
        _calories = null;
      });
      return;
    }

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);

    // Mifflin-St Jeor BMR
    final bool isFemale = selectedSexApi == "female";
    final double bmr = isFemale
        ? 10 * weight + 6.25 * heightCm - 5 * age - 161
        : 10 * weight + 6.25 * heightCm - 5 * age + 5;

    final factor = _activityFactor(activityLevelApi);
    final calories = bmr * factor;

    setState(() {
      _bmi = double.parse(bmi.toStringAsFixed(1));
      _calories = double.parse(calories.toStringAsFixed(0));
    });
  }

  double _activityFactor(String apiValue) {
    // Aproximación clásica. Ajustable cuando queráis.
    switch (apiValue) {
      case "very low":
        return 1.2;
      case "low":
        return 1.375;
      case "mid":
        return 1.55;
      case "high":
        return 1.725;
      case "very high":
        return 1.9;
      default:
        return 1.55;
    }
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return "Peso insuficiente";
    if (bmi < 25) return "Peso normal";
    if (bmi < 30) return "Sobrepeso";
    return "Obesidad";
  }

  bool get _hasAllRequired {
    final nameOk = _profileNameCtrl.text.trim().isNotEmpty;
    final birthOk = _birthDate != null;

    final weightOk = _parseDouble(_weightCtrl.text) != null;
    final heightOk = _parseDouble(_heightCtrl.text) != null;
    final waistOk = _parseDouble(_waistCtrl.text) != null;
    final hipsOk = _parseDouble(_hipsCtrl.text) != null;

    return nameOk && birthOk && weightOk && heightOk && waistOk && hipsOk;
  }

  bool get _canContinue => _hasAllRequired;

  double? _parseDouble(String s) {
    final t = s.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/${d.year}";
  }

  String _toIsoDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${d.year}-${two(d.month)}-${two(d.day)}";
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: "Selecciona tu fecha de nacimiento",
      cancelText: "Cancelar",
      confirmText: "Aceptar",
    );

    if (picked == null) return;

    setState(() {
      _birthDate = picked;
      _birthDateCtrl.text = _formatDate(picked);
      _birthDateError = null;
    });

    _validateAndRecalc();
  }

  @override
  Widget build(BuildContext context) {
    final bool showResults = _bmi != null && _calories != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================== CABECERA + TARJETA AZUL SUPERPUESTA ==================
            Stack(
              clipBehavior: Clip.none,
              children: [
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
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -58,
                  child: _recommendationCard(fullWidth: true),
                ),
              ],
            ),

            const SizedBox(height: 75),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _formCard(),
            ),

            const SizedBox(height: 20),

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
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canContinue ? primaryGreen : Colors.grey,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _canContinue
                      ? () {
                          Navigator.pushNamed(context, '/preferences');
                        }
                      : null,
                  child: const Text(
                    "Siguiente",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Mensajes de error generales (si falta algo)
            if (!_canContinue) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (_profileNameError != null)
                      _errorText(_profileNameError!),
                    if (_birthDateError != null) _errorText(_birthDateError!),
                    if (_numericError != null) _errorText(_numericError!),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _errorText(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        t,
        style: const TextStyle(color: Colors.red, fontSize: 12.5),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ================= FORM =================
  Widget _formCard() {
    final activityUiValue = _activityUiToApi.entries
        .firstWhere((e) => e.value == activityLevelApi,
            orElse: () => const MapEntry('Medio (3-5 días/sem)', 'mid'))
        .key;

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
          _input(
            "Nombre de perfil",
            "",
            Icons.person,
            _profileNameCtrl,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 15),

          GestureDetector(
            onTap: _pickBirthDate,
            child: AbsorbPointer(
              child: _input(
                "Fecha de nacimiento",
                "",
                Icons.cake,
                _birthDateCtrl,
                keyboardType: TextInputType.datetime,
              ),
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            "Sexo",
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _sexButton("Mujer", "👩"),
              const SizedBox(width: 10),
              _sexButton("Hombre", "👨"),
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
            initialValue: activityUiValue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1A1A1A),
            ),
            items: _activityUiToApi.keys
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
            onChanged: (uiValue) {
              if (uiValue == null) return;
              final apiValue = _activityUiToApi[uiValue] ?? "mid";
              setState(() => activityLevelApi = apiValue);
              _validateAndRecalc();
            },
          ),

          const SizedBox(height: 20),

          _input(
            "Peso",
            "kg",
            Icons.monitor_weight,
            _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 15),
          _input(
            "Altura",
            "cm",
            Icons.height,
            _heightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 15),
          _input(
            "Cintura",
            "cm",
            Icons.straighten,
            _waistCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 15),
          _input(
            "Cadera",
            "cm",
            Icons.straighten,
            _hipsCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Widget _input(
    String label,
    String suffix,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color.fromARGB(255, 66, 66, 66),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: inputGreyText),
        suffixText: suffix.isEmpty ? null : suffix,
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

  Widget _sexButton(String text, String emoji) {
    final selected = selectedSexUi == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedSexUi = text);
          _validateAndRecalc();
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
  static Widget _recommendationCard({bool fullWidth = false}) {
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("💡", style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Estos datos nos ayudan a personalizar tu experiencia y ajustar tu plan.",
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
                            ? "Tu IMC indica un peso saludable."
                            : "Tu IMC indica $category.",
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
                  "Estimación basada en tus datos.",
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