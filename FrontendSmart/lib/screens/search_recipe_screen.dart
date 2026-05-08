import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_config.dart';
import '../services/catalog_service.dart';
import 'create_recipe_screen.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);
const Color textDark = Color(0xFF1A1A1A);
const Color textGrey = Color(0xFF5A5565);
const Color chipGreenBg = Color(0xFFE9FBF5);
const Color chipGreenBorder = Color(0xFFBDEBDA);
const Color cardShadow = Color.fromARGB(22, 0, 0, 0);

class SearchRecipeScreen extends StatefulWidget {
  const SearchRecipeScreen({super.key});

  @override
  State<SearchRecipeScreen> createState() => _SearchRecipeScreenState();
}

class _SearchRecipeScreenState extends State<SearchRecipeScreen> {
  final ImagePicker _picker = ImagePicker();

  // ---------- Catálogos ----------
  List<GenericIngredientItem> _allGenericIngredients = [];
  List<FoodFamilyItem> _foodFamilies = [];
  bool _loadingCatalogs = true;

  // ---------- Buscador de genéricos ----------
  final TextEditingController _genericSearchCtrl = TextEditingController();
  List<GenericIngredientItem> _genericSearchResults = [];

  // ---------- Buscador de específicos ----------
  final TextEditingController _specificSearchCtrl = TextEditingController();
  List<Map<String, dynamic>> _allSpecificIngredients = [];
  List<Map<String, dynamic>> _specificSearchResults = [];
  bool _loadingSpecific = false;

  // ---------- Seleccionados ----------
  final Set<int> _selectedGenericIngredientIds = {};
  final Set<int> _selectedSpecificIngredientIds = {};
  final List<_SpecificIngredient> _selectedSpecificIngredients = [];

  // Ingredientes extra (IA)
  final List<String> _extraIngredientNames = [];

  // Receta generada
  Map<String, dynamic>? _generatedRecipe;
  bool _isGenerating = false;
  bool _isSavingRecipe = false;
  bool _isAddingMeal = false;

  // Filtros
  String selectedFilter = "Rápidas";
  final List<String> filters = const [
    "Rápidas",
    "Elaboradas",
    "Postres",
    "Favoritos",
  ];

  @override
  void initState() {
    super.initState();
    _genericSearchCtrl.addListener(_onGenericSearchChanged);
    _specificSearchCtrl.addListener(_onSpecificSearchChanged);
    _loadCatalogs();
    _loadSpecificIngredients();
  }

  @override
  void dispose() {
    _genericSearchCtrl.dispose();
    _specificSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final catalog = CatalogService();
      final ingredients = await catalog.getAllGenericIngredients();
      final families = await catalog.getAllFoodFamilies();
      if (!mounted) return;
      setState(() {
        _allGenericIngredients = ingredients;
        _foodFamilies = families;
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

  // ===================== Búsqueda genéricos =====================
  void _onGenericSearchChanged() {
    final query = _genericSearchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _genericSearchResults = [];
      } else {
        _genericSearchResults = _allGenericIngredients
            .where((i) => i.name.toLowerCase().contains(query))
            .toList();
      }
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

  // ===================== Búsqueda específicos =====================
  Future<void> _loadSpecificIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId');
    if (accountId == null) return;

    setState(() => _loadingSpecific = true);
    try {
      final uri = Uri.parse(
          ApiConfig.url("/specific-ingredient/account/$accountId"));
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allSpecificIngredients = data.cast<Map<String, dynamic>>();
          _loadingSpecific = false;
        });
      } else {
        throw Exception("Error al cargar ingredientes específicos");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSpecific = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
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

  // ===================== Crear ingrediente específico =====================
  Future<void> _showAddCustomIngredientDialog() async {
    final nameCtrl = TextEditingController();
    int? selectedFamilyId;
    String? kcalText;

    final result = await showDialog<_SpecificIngredient?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Nuevo ingrediente"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nombre",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedFamilyId,
                      items: _foodFamilies
                          .map((f) => DropdownMenuItem(
                                value: f.id,
                                child: Text(f.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedFamilyId = v),
                      decoration: const InputDecoration(
                        labelText: "Familia",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Kcal (opcional)",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => kcalText = v.trim(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty || selectedFamilyId == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Nombre y familia son obligatorios")),
                      );
                      return;
                    }
                    final kcal = int.tryParse(kcalText ?? '');
                    Navigator.pop(
                      ctx,
                      _SpecificIngredient(
                        name: name,
                        foodFamilyId: selectedFamilyId!,
                        kcal: kcal,
                      ),
                    );
                  },
                  child: const Text("Añadir"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await _createSpecificIngredient(result);
      await _loadSpecificIngredients();
    }
  }

  Future<void> _createSpecificIngredient(
      _SpecificIngredient ingredient) async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId');
    if (accountId == null) {
      _showError("No se encontró la cuenta. Inicia sesión de nuevo.");
      return;
    }

    final uri = Uri.parse(ApiConfig.url("/specific-ingredient/"));
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": ingredient.name,
          "food_family_id": ingredient.foodFamilyId,
          "account_id": accountId,
          "kcal": ingredient.kcal,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final id = data['id'] is int
            ? data['id']
            : int.parse(data['id'].toString());
        setState(() {
          _selectedSpecificIngredients.add(_SpecificIngredient(
            id: id,
            name: ingredient.name,
            foodFamilyId: ingredient.foodFamilyId,
            kcal: ingredient.kcal,
          ));
          _selectedSpecificIngredientIds.add(id);
        });
        _showError("Ingrediente creado con éxito");
      } else {
        _showError("Error al crear ingrediente: ${response.body}");
      }
    } catch (e) {
      _showError("Error de conexión: $e");
    }
  }

  // ===================== IA =====================
  Future<void> _scanAndDetect() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) return;

    final uri = Uri.parse(ApiConfig.url("/specific-ingredient/ai-detect"));
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', photo.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> ingredients = decoded['ingredients'] ?? [];

        setState(() {
          for (final name in ingredients) {
            if (name is String && name.trim().isNotEmpty) {
              _extraIngredientNames.add(name.trim());
            }
          }
        });

        _generateRecipeFromSelectedIngredients();
      } else {
        _showError(
            "Error al detectar ingredientes (${response.statusCode})");
      }
    } catch (e) {
      _showError("Error de conexión: $e");
    }
  }

  Future<void> _generateRecipeFromSelectedIngredients() async {
    final genericNames = _allGenericIngredients
        .where((i) => _selectedGenericIngredientIds.contains(i.id))
        .map((i) => i.name);
    final specificNames = _selectedSpecificIngredients.map((s) => s.name);
    final allNames = {
      ...genericNames,
      ...specificNames,
      ..._extraIngredientNames
    }.toList();

    if (allNames.isEmpty) {
      _showError("Selecciona o detecta al menos un ingrediente");
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedRecipe = null;
    });

    final uri = Uri.parse(ApiConfig.url("/specific-recipe/ai"));
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ingredient_list": allNames}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() => _generatedRecipe = decoded);
      } else if (response.statusCode == 503) {
        _showError(
            "El servicio de IA está saturado. Inténtalo de nuevo en unos momentos.");
      } else {
        final detail =
            jsonDecode(response.body)['detail'] ?? 'Error desconocido';
        _showError(detail.toString());
      }
    } catch (e) {
      _showError("Error de red: $e");
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // ===================== Guardar y añadir a comidas =====================
  Future<Map<String, int>?> _createSpecificRecipeFromGenerated() async {
    if (_generatedRecipe == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId');
    if (accountId == null) {
      _showError("No se encontró la cuenta.");
      return null;
    }
    final recipe = _generatedRecipe!;
    final name = recipe['self_name'] ?? 'Receta generada';
    final advice = recipe['chef_advice'] ?? '';
    final kcal = recipe['kcal'] is int
        ? recipe['kcal']
        : int.tryParse(recipe['kcal'].toString()) ?? 0;
    final steps = (recipe['steps'] as List?) ?? [];

    try {
      final createUri = Uri.parse(ApiConfig.url("/specific-recipe/"));
      final createRes = await http.post(createUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": name,
            "cheff_advice": advice,
            "account_id": accountId,
            "kcal": kcal,
          }));
      if (createRes.statusCode < 200 || createRes.statusCode >= 300) {
        throw Exception("Error al crear la receta: ${createRes.body}");
      }
      final decoded = jsonDecode(createRes.body);
      final recipeId = decoded['id'] is int
          ? decoded['id']
          : int.parse(decoded['id'].toString());
      final foodId = decoded['foodId'] is int
          ? decoded['foodId']
          : int.parse(decoded['foodId'].toString());

      // Asociar ingredientes seleccionados
      if (_selectedGenericIngredientIds.isNotEmpty ||
          _selectedSpecificIngredientIds.isNotEmpty) {
        final ingredientsUri =
            Uri.parse(ApiConfig.url("/specific-recipe/$recipeId/ingredients"));
        final ingRes = await http.post(ingredientsUri,
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
          debugPrint("Aviso: no se pudieron asociar ingredientes: ${ingRes.body}");
        }
      }

      // Asociar pasos
      if (steps.isNotEmpty) {
        final stepsUri =
            Uri.parse(ApiConfig.url("/specific-recipe/$recipeId/steps"));
        final stepsBody = jsonEncode({
          "steps": steps.map((s) {
            final stepNum = s['step_number'] ?? 0;
            final instruction = s['instruction'] ?? '';
            final estTime = s['estimated_time'] ?? 0;
            return {
              "specific_recipe_id": recipeId,
              "step_number": stepNum is int
                  ? stepNum
                  : int.parse(stepNum.toString()),
              "instruction": instruction,
              "estimated_time": estTime is int
                  ? estTime
                  : int.tryParse(estTime.toString()) ?? 0,
              "kcal": null,   // por si el backend lo requiere explícito
            };
          }).toList(),
        });

        debugPrint("Enviando pasos (IA): $stepsBody");

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
          debugPrint(errorMsg);
          // No lanzamos excepción para no bloquear el flujo
        }
      }

      return {'recipeId': recipeId, 'foodId': foodId};
    } catch (e) {
      _showError("Error al guardar receta: $e");
      return null;
    }
  }

  Future<void> _saveRecipeToSpecific() async {
    setState(() => _isSavingRecipe = true);
    final result = await _createSpecificRecipeFromGenerated();
    if (result != null) {
      _showError("Receta guardada con éxito");
    }
    setState(() => _isSavingRecipe = false);
  }

  Future<void> _addRecipeToTodayMeals() async {
    setState(() => _isAddingMeal = true);
    try {
      final result = await _createSpecificRecipeFromGenerated();
      if (result == null) {
        setState(() => _isAddingMeal = false);
        return;
      }
      final foodId = result['foodId']!;

      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId');
      if (accountId == null) {
        _showError("No accountId");
        return;
      }
      final profileId = prefs.getInt('profileId');
      if (profileId == null) {
        _showError("No profileId. Complete su perfil primero.");
        return;
      }

      final now = DateTime.now();
      String eatingMoment;
      int hour = now.hour;
      if (hour < 10) {
        eatingMoment = "breakfast";
      } else if (hour < 12) {
        eatingMoment = "mid_morning_snack";
      } else if (hour < 15) {
        eatingMoment = "lunch";
      } else if (hour < 18) {
        eatingMoment = "afternoon_snack";
      } else {
        eatingMoment = "dinner";
      }

      final mealUri = Uri.parse(ApiConfig.url("/meal/"));
      final mealRes = await http.post(mealUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "account_id": accountId,
            "profilIds": [profileId],
            "foodIds": [foodId],
            "eating_moment": eatingMoment,
            "eaten": true,
            "datetime": now.toIso8601String(),
          }));
      if (mealRes.statusCode >= 200 && mealRes.statusCode < 300) {
        _showError("Añadido a comidas de hoy ✅");
      } else {
        _showError("Error al añadir a comidas: ${mealRes.body}");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isAddingMeal = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      body: Column(
        children: [
          // Header verde
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
                        Text("Buscar recetas 🍽️",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 6),
                        Text("Basado en tus ingredientes",
                            style: TextStyle(
                                color: Color.fromARGB(190, 255, 255, 255),
                                fontSize: 13.5)),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22)),
                    child: const Center(
                        child: Icon(Icons.search_rounded,
                            color: primaryGreen, size: 22)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _scanAICard(),
                  const SizedBox(height: 14),
                  _addCustomRecipeCard(),
                  const SizedBox(height: 18),

                  // 🔍 Buscador de genéricos
                  const Text("Ingredientes genéricos",
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                  const SizedBox(height: 8),
                  _buildSearchBar(
                      _genericSearchCtrl, "Ej: tomate, pollo..."),
                  const SizedBox(height: 8),
                  if (_genericSearchResults.isNotEmpty)
                    _buildSuggestionsList(
                      _genericSearchResults
                          .map((i) => ListTile(
                                title: Text(i.name),
                                onTap: () => _addGenericIngredient(i),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 10),

                  // 🔍 Buscador de específicos
                  const Text("Tus ingredientes personalizados",
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSearchBar(_specificSearchCtrl,
                            "Buscar entre tus ingredientes"),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadSpecificIngredients,
                        tooltip: "Cargar ingredientes",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_specificSearchResults.isNotEmpty)
                    _buildSuggestionsList(
                      _specificSearchResults
                          .map((i) => ListTile(
                                title: Text(i['name'] ?? ''),
                                subtitle: Text(i['kcal'] != null
                                    ? "${i['kcal']} kcal"
                                    : ''),
                                onTap: () => _addSpecificIngredient(i),
                              ))
                          .toList(),
                    ),
                  if (_specificSearchCtrl.text.isNotEmpty &&
                      _specificSearchResults.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: _showAddCustomIngredientDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("Crear nuevo ingrediente"),
                        style: TextButton.styleFrom(
                            foregroundColor: primaryGreen),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Chips de ingredientes seleccionados
                  if (_selectedGenericIngredientIds.isNotEmpty)
                    _buildChipSection(
                        "Genéricos seleccionados",
                        _selectedGenericIngredientIds.map((id) {
                          final item = _allGenericIngredients
                              .firstWhere((i) => i.id == id);
                          return Chip(
                            label: Text(item.name),
                            onDeleted: () => _removeGenericIngredient(id),
                          );
                        }).toList()),
                  if (_selectedSpecificIngredients.isNotEmpty)
                    _buildChipSection(
                        "Personalizados seleccionados",
                        _selectedSpecificIngredients.map((s) {
                          return Chip(
                            label: Text(s.name),
                            onDeleted: () =>
                                _removeSpecificIngredient(s.id!),
                          );
                        }).toList()),
                  if (_extraIngredientNames.isNotEmpty)
                    _buildChipSection(
                        "Detectados por IA",
                        _extraIngredientNames.map((name) {
                          return Chip(
                            label: Text(name),
                            onDeleted: () => setState(() =>
                                _extraIngredientNames.remove(name)),
                          );
                        }).toList()),

                  const SizedBox(height: 18),
                  // Filtros (estáticos)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: filters
                        .map((f) => _filterPill(
                              text: f,
                              selected: f == selectedFilter,
                              onTap: () =>
                                  setState(() => selectedFilter = f),
                              icon: _filterIcon(f),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  // Botón Buscar recetas
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating
                          ? null
                          : _generateRecipeFromSelectedIngredients,
                      icon: _isGenerating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                          _isGenerating ? "Generando..." : "Buscar recetas"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_generatedRecipe != null) ...[
                    const Text("Receta sugerida",
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: textDark)),
                    const SizedBox(height: 10),
                    _buildGeneratedRecipeCard(_generatedRecipe!),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSavingRecipe
                                ? null
                                : _saveRecipeToSpecific,
                            icon: _isSavingRecipe
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.save),
                            label: const Text("Guardar receta"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isAddingMeal
                                ? null
                                : _addRecipeToTodayMeals,
                            icon: _isAddingMeal
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.add_circle),
                            label: const Text("Añadir a hoy"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF8A00),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: campo de búsqueda genérico
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: cardShadow, blurRadius: 6, offset: Offset(0, 4))
        ],
      ),
      child: Column(children: tiles),
    );
  }

  Widget _buildChipSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textGrey)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        const SizedBox(height: 12),
      ],
    );
  }

  // Tarjeta de escaneo con IA
  Widget _scanAICard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: cardShadow,
              blurRadius: 10,
              offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo_camera_outlined,
                  size: 18, color: textGrey),
              SizedBox(width: 10),
              Text(
                "Escanear ingredientes con IA",
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: textDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _scanAndDetect,
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFFC9CDD5), width: 1.2),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 28, color: Color(0xFF9AA3B2)),
                    SizedBox(height: 10),
                    Text(
                      "Toca para escanear",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textGrey),
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

  Widget _addCustomRecipeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: cardShadow,
              blurRadius: 10,
              offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.edit_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Añadir mi propia\nreceta",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.15),
                ),
                SizedBox(height: 6),
                Text(
                  "Crea y guarda tus\nrecetas personalizadas",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.2,
                      fontWeight: FontWeight.w400,
                      height: 1.2),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRecipeScreen()),
            );  
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterPill({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEAF3FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFBFD7FF)
                : const Color(0xFFE6E6E6),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? const Color(0xFF2F73FF)
                  : textGrey,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: selected
                    ? const Color(0xFF2F73FF)
                    : textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedRecipeCard(Map<String, dynamic> recipe) {
    final name = recipe['self_name'] ?? "Receta";
    final advice = recipe['chef_advice'] ?? "";
    final kcal = recipe['kcal']?.toString() ?? "—";
    final steps = (recipe['steps'] as List?) ?? [];
    final time = steps.isNotEmpty ? "${steps.length * 5} min" : "—";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: cardShadow,
              blurRadius: 10,
              offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                    child: Text("🍽️",
                        style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF7EE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  "100% match",
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 16, color: textGrey),
              const SizedBox(width: 6),
              Text(time,
                  style: const TextStyle(
                      fontSize: 13, color: textGrey)),
              const SizedBox(width: 14),
              const Icon(Icons.local_fire_department,
                  size: 16, color: Color(0xFFFF8A00)),
              const SizedBox(width: 6),
              Text("$kcal kcal",
                  style: const TextStyle(
                      fontSize: 13, color: textGrey)),
            ],
          ),
          if (advice.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(advice,
                style: const TextStyle(
                    fontSize: 13, color: textGrey)),
          ],
          const SizedBox(height: 8),
          const Text("Pasos:",
              style: TextStyle(fontWeight: FontWeight.w600)),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                  "$idx. ${step['instruction'] ?? ''}"),
            );
          }),
        ],
      ),
    );
  }

  IconData _filterIcon(String f) {
    switch (f) {
      case "Rápidas":
        return Icons.access_time;
      case "Elaboradas":
        return Icons.restaurant_menu;
      case "Postres":
        return Icons.cake_outlined;
      case "Favoritos":
        return Icons.star_outline;
      default:
        return Icons.tune;
    }
  }
}

// Modelo auxiliar para ingredientes específicos
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