import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'scan_code_screen.dart';

class RegisterExtraFoodScreen extends StatefulWidget {
  const RegisterExtraFoodScreen({super.key});

  @override
  State<RegisterExtraFoodScreen> createState() =>
      _RegisterExtraFoodScreenState();
}

class _RegisterExtraFoodScreenState extends State<RegisterExtraFoodScreen> {
  static const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
  static const Color screenBg = Color(0xFFF6F9F8);
  static const Color softGreen = Color(0xFFE9F9F2);
  static const Color borderGreen = Color(0xFF7EE7C2);
  static const Color textGrey = Color(0xFF5A5565);

  final _picker = ImagePicker();

  String selectedType = "Snack";

  // inputs
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _kcalCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController();

  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kcalCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  // ===================== CAMARA FOTO =====================
  Future<void> _openFoodCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (!mounted) return;

    if (file == null) return; // cancelado

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Foto tomada: ${file.name}")));

    // ✅ aquí luego lo mandas a tu backend/IA si quieres
  }

  // ===================== CAMARA ESCANEO =====================
  Future<void> _openScanCamera() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const ScanCodeScreen()),
    );

    if (!mounted) return;
    if (result == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Código detectado: $result")));

    // ✅ aquí luego consultas API con el barcode (OpenFoodFacts o tu backend)
  }

  // ===================== PICKER HORA estilo iOS (TU APP) =====================
  Future<void> _pickTimeIOS() async {
    final now = DateTime.now();
    DateTime temp = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime?.hour ?? now.hour,
      _selectedTime?.minute ?? now.minute,
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            height: 320,
            decoration: const BoxDecoration(
              color: screenBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                // Barra superior (estilo tu app)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryGreen,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text("Cancelar"),
                      ),
                      const Spacer(),
                      const Text(
                        "Hora de consumo",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedTime = TimeOfDay(
                              hour: temp.hour,
                              minute: temp.minute,
                            );
                          });
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primaryGreen,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: const Text("Listo"),
                      ),
                    ],
                  ),
                ),

                Container(height: 1, color: const Color(0xFFE9E9EE)),

                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      primaryColor: primaryGreen,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: temp,
                      use24hFormat: true, // si quieres AM/PM -> pon false
                      onDateTimeChanged: (d) => temp = d,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeLabel() {
    if (_selectedTime == null) return "¿A qué hora comiste?";
    final h = _selectedTime!.hour.toString().padLeft(2, '0');
    final m = _selectedTime!.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,

      // ================= HEADER + BODY =================
      body: Column(
        children: [
          // HEADER
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Registrar comida",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Añade lo que has comido hoy",
                          style: TextStyle(
                            color: Color.fromARGB(200, 255, 255, 255),
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENIDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 BUSCADOR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(18, 0, 0, 0),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: "Buscar comida o bebida...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 📷 ACCIONES RÁPIDAS
                  Row(
                    children: [
                      _actionButton(
                        text: "Escanear\ncódigo",
                        icon: Icons.qr_code_rounded,
                        color: const Color(0xFF8B5CF6),
                        onTap: _openScanCamera,
                      ),
                      const SizedBox(width: 12),
                      _actionButton(
                        text: "Foto de\ncomida",
                        icon: Icons.camera_alt_rounded,
                        color: const Color(0xFF2563EB),
                        onTap: _openFoodCamera,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 🍽️ TIPO DE COMIDA
                  const Text(
                    "Tipo de comida",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _typeChip("Desayuno", "🍳"),
                      _typeChip("Snack", "🍎"),
                      _typeChip("Comida", "🍝"),
                      _typeChip("Merienda", "☕"),
                      _typeChip("Cena", "🌙"),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 🕒 HORA (estilo como tu imagen)
                  const Text(
                    "Hora de consumo",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  InkWell(
                    onTap: _pickTimeIOS,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(14, 0, 0, 0),
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF2F73FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _timeLabel(),
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedTime == null
                                    ? textGrey
                                    : const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF9AA3B2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 🧩 ENTRADA PERSONALIZADA (redondeado como imagen)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderGreen, width: 1.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDF7EE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: primaryGreen,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Entrada personalizada",
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Añade manualmente el nombre\ny calorías",
                                    style: TextStyle(
                                      fontSize: 12.8,
                                      height: 1.2,
                                      color: textGrey,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _softInput(
                          controller: _nameCtrl,
                          hint: "Nombre de la comida",
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _softInput(
                                controller: _kcalCtrl,
                                hint: "Calorías",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _softInput(
                                controller: _qtyCtrl,
                                hint: "Cantidad",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= BOTÓN FIJO =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: ElevatedButton.icon(
          onPressed: () {
            debugPrint(
              "tipo=$selectedType time=${_timeLabel()} nombre=${_nameCtrl.text} kcal=${_kcalCtrl.text} qty=${_qtyCtrl.text}",
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text(
            "Añadir a mi registro",
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTES =================

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(20, 0, 0, 0),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String emoji) {
    final bool selected = selectedType == label;

    return InkWell(
      onTap: () => setState(() => selectedType = label),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? softGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primaryGreen : const Color(0xFFE6E6E6),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _softInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderGreen, width: 1.6),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9AA3B2)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
