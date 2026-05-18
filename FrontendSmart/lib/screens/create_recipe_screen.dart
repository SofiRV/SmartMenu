import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_config.dart';
import '../services/catalog_service.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);
const Color textDark = Color(0xFF1A1A1A);
const Color textGrey = Color(0xFF5A5565);

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _adviceCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();
  bool _autoCalcKcal = true;

  List<GenericIngredientItem> _allGenericIngredients = [];
  List<Map<String, dynamic>> _allSpecificIngredients = [];
  bool _loadingCatalogs = true;

  final TextEditingController _genericSearchCtrl = TextEditingController();
  List<GenericIngredientItem> _genericSearchResults = [];

  final TextEditingController _specificSearchCtrl = TextEditingController();
  List<Map<String, dynamic>> _specificSearchResults = [];

  final Set<int> _selectedGenericIngredientIds = {};
  final Set<int> _selectedSpecificIngredientIds = {};
  final List<_SpecificIngredient> _selectedSpecificIngredients = [];

  final List<_RecipeStep> _steps = [
    _RecipeStep(stepNumber: 1, instruction: '', estimatedTime: 0),
  ];

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _genericSearchCtrl.addListener(_onGenericSearchChanged);
    _specificSearchCtrl.addListener(_onSpecificSearchChanged);
    _loadCatalogs();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _adviceCtrl.dispose();
    _kcalCtrl.dispose();
    _genericSearchCtrl.dispose();
    _specificSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final catalog = CatalogService();
      final ingredients = await catalog.getAllGenericIngredients();
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId');
      if (accountId != null) {
        final uri = Uri.parse(ApiConfig.url("/specific-ingredient/account/$accountId"));
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          _allSpecificIngredients = (jsonDecode(response.body) as List)
              .cast<Map<String, dynamic>>();
        }
      }
      if (!mounted) return;
      setState(() {
        _allGenericIngredients = ingredients;
        _loadingCatalogs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCatalogs = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar catálogos: $e")),
      );
    }
  }

  void _onGenericSearchChanged() {
    final query = _genericSearchCtrl.text.trim().toLowerCase();
    setState(() {
      _genericSearchResults = query.isEmpty
          ? []
          : _allGenericIngredients
              .where((i) => i.name.toLowerCase().contains(query))
              .toList();
    });
  }

  void _addGenericIngredient(GenericIngredientItem item) {
    _genericSearchCtrl.clear();
    setState(() {
      _selectedGenericIngredientIds.add(item.id);
      _genericSearchResults = [];
    });
  }

  void _removeGenericIngredient(int id) {
    setState(() => _selectedGenericIngredientIds.remove(id));
  }

  void _onSpecificSearchChanged() {
    final query = _specificSearchCtrl.text.trim().toLowerCase();
    setState(() {
      _specificSearchResults = query.isEmpty
          ? []
          : _allSpecificIngredients.where((i) {
              final name = (i['name'] ?? '').toLowerCase();
              return name.contains(query);
            }).toList();
    });
  }

  void _addSpecificIngredient(Map<String, dynamic> ingredient) {
    final id = ingredient['id'] is int
        ? ingredient['id']
        : int.parse(ingredient['id'].toString());
    if (_selectedSpecificIngredientIds.contains(id)) return;
    _specificSearchCtrl.clear();
    setState(() {
      _selectedSpecificIngredientIds.add(id);
      _selectedSpecificIngredients.add(_SpecificIngredient(
        id: id,
        name: ingredient['name'] ?? '',
        foodFamilyId: ingredient['food_family_id'] ?? 0,
        kcal: ingredient['kcal'] is int ? ingredient['kcal'] : null,
      ));
      _specificSearchResults = [];
    });
  }

  void _removeSpecificIngredient(int id) {
    setState(() {
      _selectedSpecificIngredientIds.remove(id);
      _selectedSpecificIngredients.removeWhere((s) => s.id == id);
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(_RecipeStep(
        stepNumber: _steps.length + 1,
        instruction: '',
        estimatedTime: 0,
      ));
    });
  }

  void _removeStep(int index) {
    if (_steps.length == 1) return;
    setState(() {
      _steps.removeAt(index);
      for (int i = 0; i < _steps.length; i++) {
        _steps[i].stepNumber = i + 1;
      }
    });
  }

  int _calcTotalKcal() {
    int total = 0;
    for (final id in _selectedGenericIngredientIds) {
      final ing = _allGenericIngredients.firstWhere((i) => i.id == id);
      total += ing.kcal ?? 0;
    }
    for (final s in _selectedSpecificIngredients) {
      total += s.kcal ?? 0;
    }
    return total;
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_steps.any((s) => s.instruction.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todas las instrucciones de los pasos.")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId');
      if (accountId == null) {
        _showError("No se encontró la cuenta.");
        return;
      }

      final int kcal = _autoCalcKcal
          ? _calcTotalKcal()
          : (int.tryParse(_kcalCtrl.text.trim()) ?? 0);

      // 1. Crear receta
      final createUri = Uri.parse(ApiConfig.url("/specific-recipe/"));
      final createRes = await http.post(createUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": _nameCtrl.text.trim(),
            "cheff_advice": _adviceCtrl.text.trim(),
            "account_id": accountId,
            "kcal": kcal,
          }));
      if (createRes.statusCode < 200 || createRes.statusCode >= 300) {
        throw Exception("Error al crear receta: ${createRes.body}");
      }
      final decoded = jsonDecode(createRes.body);
      final recipeId = decoded['id'] is int
          ? decoded['id']
          : int.parse(decoded['id'].toString());

      // 2. Asociar ingredientes
      if (_selectedGenericIngredientIds.isNotEmpty ||
          _selectedSpecificIngredientIds.isNotEmpty) {
        final ingUri = Uri.parse(
            ApiConfig.url("/specific-recipe/$recipeId/ingredients"));
        final ingRes = await http.post(ingUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "genericIngredients": {
                "ids": _selectedGenericIngredientIds.toList()
              },
              "specificIngredients": {
                "ids": _selectedSpecificIngredientIds.toList()
              },
            }));
        if (ingRes.statusCode < 200 || ingRes.statusCode >= 300) {
          debugPrint("Aviso: no se asociaron ingredientes: ${ingRes.body}");
        }
      }

      // 3. Asociar pasos
      final stepsUri = Uri.parse(ApiConfig.url("/specific-recipe/$recipeId/steps"));
      final stepsBody = jsonEncode({
        "steps": _steps
            .where((s) => s.instruction.trim().isNotEmpty)
            .map((s) => {
                  "specific_recipe_id": recipeId,
                  "step_number": s.stepNumber,
                  "instruction": s.instruction.trim(),
                  "estimated_time": s.estimatedTime,
                })
            .toList(),
      });

      debugPrint("Enviando pasos: $stepsBody");

      final stepsRes = await http.post(stepsUri,
          headers: {'Content-Type': 'application/json'},
          body: stepsBody);

      if (stepsRes.statusCode < 200 || stepsRes.statusCode >= 300) {
        String errorMsg = "Error al guardar pasos (${stepsRes.statusCode})";
        if (stepsRes.statusCode == 422) {
          try {
            final errBody = jsonDecode(stepsRes.body);
            errorMsg += ": ${errBody['detail'] ?? stepsRes.body}";
          } catch (_) {
            errorMsg += ": ${stepsRes.body}";
          }
        }
        throw Exception(errorMsg);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receta guardada con éxito ✅")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError("$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 18, top: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Crear receta",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _loadingCatalogs
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _inputDecoration("Nombre de la receta"),
                      validator: (v) => v?.trim().isEmpty == true ? "Requerido" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _adviceCtrl,
                      decoration: _inputDecoration("Consejo del chef (opcional)"),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _kcalCtrl,
                            decoration: _inputDecoration("Kcal totales"),
                            keyboardType: TextInputType.number,
                            enabled: !_autoCalcKcal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const Text("Auto", style: TextStyle(fontSize: 12)),
                            Switch(
                              value: _autoCalcKcal,
                              onChanged: (v) => setState(() => _autoCalcKcal = v),
                              activeThumbColor: primaryGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Ingredientes genéricos",
                        style: TextStyle(fontWeight: FontWeight.w600, color: textDark)),
                    const SizedBox(height: 8),
                    _buildSearchBar(_genericSearchCtrl, "Buscar genérico..."),
                    if (_genericSearchResults.isNotEmpty)
                      _buildSuggestionsList(
                        _genericSearchResults
                            .map((i) => ListTile(
                                  title: Text(i.name),
                                  onTap: () => _addGenericIngredient(i),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    if (_selectedGenericIngredientIds.isNotEmpty)
                      _buildChipSection(
                        _selectedGenericIngredientIds.map((id) {
                          final item = _allGenericIngredients.firstWhere((i) => i.id == id);
                          return Chip(
                            label: Text(item.name),
                            onDeleted: () => _removeGenericIngredient(id),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    const Text("Tus ingredientes personalizados",
                        style: TextStyle(fontWeight: FontWeight.w600, color: textDark)),
                    const SizedBox(height: 8),
                    _buildSearchBar(_specificSearchCtrl, "Buscar personalizado..."),
                    if (_specificSearchResults.isNotEmpty)
                      _buildSuggestionsList(
                        _specificSearchResults
                            .map((i) => ListTile(
                                  title: Text(i['name'] ?? ''),
                                  onTap: () => _addSpecificIngredient(i),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    if (_selectedSpecificIngredients.isNotEmpty)
                      _buildChipSection(
                        _selectedSpecificIngredients.map((s) {
                          return Chip(
                            label: Text(s.name),
                            onDeleted: () => _removeSpecificIngredient(s.id!),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Pasos", style: TextStyle(fontWeight: FontWeight.w600, color: textDark)),
                        TextButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add),
                          label: const Text("Añadir paso"),
                          style: TextButton.styleFrom(foregroundColor: primaryGreen),
                        ),
                      ],
                    ),
                    ..._steps.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  TextFormField(
                                    initialValue: step.instruction,
                                    decoration: _inputDecoration("Paso ${step.stepNumber}"),
                                    onChanged: (v) => step.instruction = v,
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    initialValue: step.estimatedTime == 0 ? '' : step.estimatedTime.toString(),
                                    decoration: _inputDecoration("Tiempo (min)"),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) =>
                                        step.estimatedTime = int.tryParse(v) ?? 0,
                                  ),
                                ],
                              ),
                            ),
                            if (_steps.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeStep(idx),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _saving
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text("Guardar receta",
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildSearchBar(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: textGrey),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(children: tiles),
    );
  }

  Widget _buildChipSection(List<Widget> chips) {
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

class _SpecificIngredient {
  final int? id;
  final String name;
  final int foodFamilyId;
  final int? kcal;
  _SpecificIngredient({
    this.id,
    required this.name,
    required this.foodFamilyId,
    this.kcal,
  });
}

class _RecipeStep {
  int stepNumber;
  String instruction;
  int estimatedTime;
  _RecipeStep({
    required this.stepNumber,
    required this.instruction,
    required this.estimatedTime,
  });
}