import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'scan_code_screen.dart';
import '../services/api_config.dart';
import '../services/catalog_service.dart';
import '../services/profile_service.dart';

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
  final TextEditingController _searchCtrl = TextEditingController();

  TimeOfDay? _selectedTime;

  // Catalog
  bool _loadingCatalog = true;
  List<GenericIngredientItem> _catalogItems = [];
  List<GenericIngredientItem> _filteredItems = [];
  List<FoodFamilyItem> _foodFamilies = [];
  GenericIngredientItem? _selectedCatalogItem;
  int? _selectedFoodFamilyId;

  // 🔁 Modo de cálculo
  bool _knowsGrams = true; // true = gramos + kcal/100g, false = kcal total

  // Lista de ingredientes del plato
  final List<_MealIngredient> _mealItems = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _searchCtrl.addListener(_filterCatalog);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kcalCtrl.dispose();
    _qtyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final catalogService = CatalogService();
      final ingredients = await catalogService.getAllGenericIngredients();
      final families = await catalogService.getAllFoodFamilies();

      if (!mounted) return;
      setState(() {
        _catalogItems = ingredients;
        _filteredItems = [];
        _foodFamilies = families;
        _loadingCatalog = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCatalog = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando catálogo: $e")),
      );
    }
  }

  void _filterCatalog() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredItems = []);
      return;
    }
    setState(() {
      _filteredItems = _catalogItems
          .where((i) => i.name.toLowerCase().contains(q))
          .toList();
    });
  }

  int? _estimateKcalPer100g(int foodFamilyId) {
    const map = {
      1: 55, // Frutas
      2: 30, // Verduras y Hortalizas
      3: 200, // Carnes Rojas
      4: 165, // Aves
      5: 140, // Pescados
      6: 100, // Mariscos
      7: 120, // Lácteos
      8: 120, // Legumbres
      9: 350, // Cereales
      10: 90, // Tubérculos
      11: 600, // Frutos Secos
      12: 880, // Aceites y Grasas
      13: 450, // Dulces y Procesados
    };

    return map[foodFamilyId];
  }

  void _clearItemInputs() {
    _nameCtrl.clear();
    _kcalCtrl.clear();
    _qtyCtrl.clear();
    _selectedFoodFamilyId = null;
    _selectedCatalogItem = null;
    _editingIndex = null;
  }

  void _addOrUpdateIngredient() {
    final name = _nameCtrl.text.trim();
    final kcalStr = _kcalCtrl.text.trim();
    final gramsStr = _qtyCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa el nombre.")),
      );
      return;
    }

    if (_selectedFoodFamilyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona la familia de alimentos.")),
      );
      return;
    }

    int? grams;
    if (_knowsGrams) {
      grams = int.tryParse(gramsStr);
      if (grams == null || grams <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gramos inválidos.")),
        );
        return;
      }
    }

    int? kcalInput = int.tryParse(kcalStr);
    bool usedEstimate = false;

    if (_knowsGrams) {
      if (kcalInput == null || kcalInput <= 0) {
        final estimated = _estimateKcalPer100g(_selectedFoodFamilyId!);
        if (estimated == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("No hay kcal estimadas para esa familia.")),
          );
          return;
        }
        kcalInput = estimated;
        usedEstimate = true;
      }
    } else {
      if (kcalInput == null || kcalInput <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Calorías inválidas.")),
        );
        return;
      }
    }

    final item = _MealIngredient(
      name: name,
      kcalInput: kcalInput,
      grams: grams,
      knowsGrams: _knowsGrams,
      foodFamilyId: _selectedFoodFamilyId!,
      fromCatalog: _selectedCatalogItem != null,
      usedEstimate: usedEstimate,
    );

    setState(() {
      if (_editingIndex != null) {
        _mealItems[_editingIndex!] = item;
      } else {
        _mealItems.add(item);
      }
      _clearItemInputs();
    });
  }

  void _editIngredient(int index) {
    final item = _mealItems[index];
    setState(() {
      _editingIndex = index;
      _knowsGrams = item.knowsGrams;
      _nameCtrl.text = item.name;
      _kcalCtrl.text = item.kcalInput.toString();
      _qtyCtrl.text = item.grams?.toString() ?? '';
      _selectedFoodFamilyId = item.foodFamilyId;
      _selectedCatalogItem = null;
    });
  }

  void _deleteIngredient(int index) {
    setState(() {
      _mealItems.removeAt(index);
      if (_editingIndex == index) {
        _clearItemInputs();
      } else if (_editingIndex != null && _editingIndex! > index) {
        _editingIndex = _editingIndex! - 1;
      }
    });
  }

  // ===================== CAMARA FOTO =====================
  Future<void> _openFoodCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (!mounted) return;

    if (file == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Foto tomada: ${file.name}")));
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
  }

  // ===================== PICKER HORA estilo iOS =====================
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
                      use24hFormat: true,
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

  String _mapEatingMoment(String type) {
    switch (type) {
      case "Desayuno":
        return "breakfast";
      case "Snack":
        return "mid_morning_snack";
      case "Comida":
        return "lunch";
      case "Merienda":
        return "afternoon_snack";
      case "Cena":
        return "dinner";
      default:
        return "lunch";
    }
  }

  Future<void> _submit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId');
      final profileName = prefs.getString('profileName') ?? '';

      if (accountId == null) {
        throw Exception("No se encontró accountId en SharedPreferences.");
      }
      if (_selectedTime == null) {
        throw Exception("Selecciona la hora de consumo.");
      }
      if (_mealItems.isEmpty) {
        throw Exception("Añade al menos un ingrediente.");
      }

      final profileId = await ProfileService().findOrCreateProfileId(
        accountId: accountId,
        profileName: profileName.isEmpty ? "Perfil" : profileName,
      );

      final List<int> foodIds = [];

      for (final item in _mealItems) {
        final uri = Uri.parse(ApiConfig.url("/specific-ingredient/"));
        final res = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": item.displayName,
            "food_family_id": item.foodFamilyId,
            "account_id": accountId,
            "kcal": item.totalKcal,
          }),
        );

        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw Exception("Crear ingrediente falló: ${res.body}");
        }

        final decoded = jsonDecode(res.body);
        final rawFoodId = decoded["foodId"];
        if (rawFoodId is num) {
          foodIds.add(rawFoodId.toInt());
        } else {
          throw Exception("No se pudo resolver foodId.");
        }
      }

      final now = DateTime.now();
      final mealTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final mealPayload = {
        "account_id": accountId,
        "profilIds": [profileId],
        "foodIds": foodIds,
        "eating_moment": _mapEatingMoment(selectedType),
        "eaten": true,
        "datetime": mealTime.toIso8601String(),
      };

      final mealUri = Uri.parse(ApiConfig.url("/meal/"));
      final mealRes = await http.post(
        mealUri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(mealPayload),
      );

      if (mealRes.statusCode < 200 || mealRes.statusCode >= 300) {
        throw Exception("Crear meal falló: ${mealRes.body}");
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comida registrada ✅")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _editingIndex != null;

    return Scaffold(
      backgroundColor: screenBg,
      body: Column(
        children: [
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
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: "Buscar comida o bebida...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

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

                  const SizedBox(height: 18),

                  const Text(
                    "Catálogo de ingredientes",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_loadingCatalog)
                    const Center(child: CircularProgressIndicator())
                  else if (_filteredItems.isEmpty)
                    const SizedBox.shrink()
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        itemCount: _filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFE6E6E6),
                              ),
                            ),
                            title: Text(item.name),
                            onTap: () {
                              setState(() {
                                _selectedCatalogItem = item;
                                _nameCtrl.text = item.name;
                                _selectedFoodFamilyId = item.foodFamilyId;
                                _filteredItems = [];
                              });
                            },
                          );
                        },
                      ),
                    ),

                  if (_selectedCatalogItem != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Seleccionado: ${_selectedCatalogItem!.name}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

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

                  const Text(
                    "Ingredientes del plato",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔁 TOGGLE
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderGreen, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _knowsGrams ? "Sé los gramos" : "Sé las calorías",
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: _knowsGrams,
                          activeThumbColor: primaryGreen,
                          onChanged: (v) {
                            setState(() {
                              _knowsGrams = v;
                              _nameCtrl.clear();
                              _kcalCtrl.clear();
                              _qtyCtrl.clear();
                              _selectedFoodFamilyId = null;
                              _selectedCatalogItem = null;
                              _editingIndex = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  _softInput(
                    controller: _nameCtrl,
                    hint: "Nombre de la comida",
                  ),

                  const SizedBox(height: 10),

                  if (_knowsGrams) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _softInput(
                            controller: _kcalCtrl,
                            hint: "Kcal por 100g (opcional)",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _softInput(
                            controller: _qtyCtrl,
                            hint: "Gramos",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _softInput(
                      controller: _kcalCtrl,
                      hint: "Calorías totales",
                      keyboardType: TextInputType.number,
                    ),
                  ],

                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    initialValue: _selectedFoodFamilyId,
                    decoration: _dropdownStyle(),
                    hint: const Text("Selecciona familia de alimentos"),
                    items: _foodFamilies.map((f) {
                      return DropdownMenuItem<int>(
                        value: f.id,
                        child: Text(f.name),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _selectedFoodFamilyId = v),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addOrUpdateIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditing ? "Actualizar ingrediente" : "Añadir ingrediente",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_mealItems.isEmpty)
                    const Text(
                      "No hay ingredientes añadidos.",
                      style: TextStyle(fontSize: 12.5, color: textGrey),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mealItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _mealItems[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE6E6E6)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Kcal: ${item.totalKcal} | ${item.knowsGrams ? '${item.kcalInput} kcal/100g' : 'kcal totales'}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    if (item.usedEstimate) ...[
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Estimado por familia",
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF9AA3B2),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _editIngredient(index),
                                icon: const Icon(Icons.edit, size: 20),
                              ),
                              IconButton(
                                onPressed: () => _deleteIngredient(index),
                                icon: const Icon(Icons.delete, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: ElevatedButton.icon(
          onPressed: _submit,
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
        color: Colors.white.withValues(alpha: 0.88),
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
}

class _MealIngredient {
  _MealIngredient({
    required this.name,
    required this.kcalInput,
    required this.knowsGrams,
    required this.foodFamilyId,
    this.grams,
    this.fromCatalog = false,
    this.usedEstimate = false,
  });

  final String name;
  final int kcalInput;
  final int? grams;
  final bool knowsGrams;
  final int foodFamilyId;
  final bool fromCatalog;
  final bool usedEstimate;

  int get totalKcal {
    if (!knowsGrams || grams == null || grams! <= 0) return kcalInput;
    return ((kcalInput * grams!) / 100).round();
  }

  String get displayName {
    if (grams == null || grams! <= 0) return name;
    return "$name (${grams}g)";
  }
}