import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/profile_service.dart';
import '../services/profile_settings_service.dart';
import '../services/bans_service.dart';
import '../services/catalog_service.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

const Color textPrimary = Color(0xFF1A1A1A);
const Color textGrey = Color(0xFF5A5565);
const Color borderGrey = Color.fromARGB(255, 248, 240, 240);

const Color dangerRed = Color(0xFFE23B3B);
const Color dangerBg = Color(0xFFFFF1F1);

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _catalog = CatalogService();
  final _profileService = ProfileService();
  final _settingsService = ProfileSettingsService();
  final _bansService = BansService();

  // Draft from PersonalDataScreen (prefs)
  int? _accountId;
  String _profileName = '';
  String _birthDateIso = '';
  String _sexApi = 'female';
  String _activityLevelApi = 'mid';
  String _weight = '';
  String _height = '';
  String _waist = '';
  String _hips = '';

  // Catalog loaded from backend
  late Future<void> _loadFuture;
  List<CatalogItem> _dietTypes = [];
  List<CatalogItem> _goals = [];
  List<IllnessItem> _illnessCatalog = [];

  // Bans catalogs
  List<FoodFamilyItem> _foodFamilies = [];
  List<GenericIngredientItem> _genericIngredients = [];
  late List<GenericIngredientItem> _genericIngredientsIndex; // para search local

  int? _selectedDietTypeId;
  int? _selectedGoalId;

  // Selections
  final Set<int> _selectedIllnessIds = {};
  final Set<int> _selectedAllergyFoodFamilyIds = {};
  final Set<int> _selectedAllergyGenericIngredientIds = {};
  final Set<int> _selectedBlacklistGenericIngredientIds = {};

  // Search controllers (local)
  final TextEditingController _allergyIngredientCtrl = TextEditingController();
  final TextEditingController _blacklistIngredientCtrl = TextEditingController();
  List<GenericIngredientItem> _allergyIngredientSuggestions = [];
  List<GenericIngredientItem> _blacklistIngredientSuggestions = [];
  bool _loadingSuggestions = false;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFuture = _init();

    _allergyIngredientCtrl.addListener(_onAllergyIngredientQueryChanged);
    _blacklistIngredientCtrl.addListener(_onBlacklistIngredientQueryChanged);
  }

  @override
  void dispose() {
    _allergyIngredientCtrl.dispose();
    _blacklistIngredientCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadDraftFromPrefs();
    await _loadCatalogs();
    await _loadSavedSelections();
  }

  Future<void> _loadDraftFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final savedIllnessIds = prefs.getStringList('illnessIds') ?? const [];

    final savedFoodFamilyIds =
        prefs.getStringList('bannedFoodFamilyIds') ?? const [];
    final savedAllergyIngredientIds =
        prefs.getStringList('bannedGenericIngredientIds_allergy') ?? const [];
    final savedBlacklistIngredientIds =
        prefs.getStringList('bannedGenericIngredientIds_blacklist') ?? const [];

    setState(() {
      _accountId = prefs.getInt('accountId');

      _profileName = (prefs.getString('profileName') ?? '').trim();
      _birthDateIso = (prefs.getString('birthDate') ?? '').trim(); // YYYY-MM-DD

      _sexApi = (prefs.getString('sexApi') ?? 'female');
      _activityLevelApi = (prefs.getString('activityLevelApi') ?? 'mid');

      _weight = (prefs.getString('weight') ?? '').trim();
      _height = (prefs.getString('height') ?? '').trim();
      _waist = (prefs.getString('waist') ?? '').trim();
      _hips = (prefs.getString('hips') ?? '').trim();

      _selectedIllnessIds
        ..clear()
        ..addAll(savedIllnessIds.map((e) => int.tryParse(e)).whereType<int>());

      _selectedAllergyFoodFamilyIds
        ..clear()
        ..addAll(savedFoodFamilyIds.map((e) => int.tryParse(e)).whereType<int>());

      _selectedAllergyGenericIngredientIds
        ..clear()
        ..addAll(savedAllergyIngredientIds.map((e) => int.tryParse(e)).whereType<int>());

      _selectedBlacklistGenericIngredientIds
        ..clear()
        ..addAll(savedBlacklistIngredientIds.map((e) => int.tryParse(e)).whereType<int>());
    });
  }

  Future<void> _loadCatalogs() async {
    final diets = await _catalog.getDietTypes();
    final goals = await _catalog.getGoals();
    final illnesses = await _catalog.getAllIllnesses();

    final families = await _catalog.getAllFoodFamilies();
    final ingredients = await _catalog.getAllGenericIngredients();

    // índice para búsqueda local (nameLower)
    final sortedIngredients = [...ingredients]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _dietTypes = diets;
      _goals = goals;
      _illnessCatalog = illnesses;

      _foodFamilies = families;
      _genericIngredients = ingredients;
      _genericIngredientsIndex = sortedIngredients;
    });
  }

  Future<void> _loadSavedSelections() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDietTypeId = prefs.getInt('dietTypeId');
      _selectedGoalId = prefs.getInt('goalId');
    });
  }

  Future<void> _saveSelectionsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedDietTypeId != null) {
      await prefs.setInt('dietTypeId', _selectedDietTypeId!);
    }
    if (_selectedGoalId != null) {
      await prefs.setInt('goalId', _selectedGoalId!);
    }

    final selectedIll = _illnessCatalog
        .where((i) => _selectedIllnessIds.contains(i.id))
        .toList();

    await prefs.setStringList(
      'illnessIds',
      selectedIll.map((e) => e.id.toString()).toList(),
    );
    await prefs.setStringList(
      'illnessNames',
      selectedIll.map((e) => e.name).toList(),
    );

    await prefs.setStringList(
      'bannedFoodFamilyIds',
      _selectedAllergyFoodFamilyIds.map((e) => e.toString()).toList(),
    );

    await prefs.setStringList(
      'bannedGenericIngredientIds_allergy',
      _selectedAllergyGenericIngredientIds.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      'bannedGenericIngredientIds_blacklist',
      _selectedBlacklistGenericIngredientIds.map((e) => e.toString()).toList(),
    );
  }

  bool get _canSave {
    if (_saving) return false;
    if (_accountId == null) return false;

    if (_profileName.isEmpty) return false;
    if (_birthDateIso.isEmpty) return false;

    if (_weight.isEmpty ||
        _height.isEmpty ||
        _waist.isEmpty ||
        _hips.isEmpty) return false;

    if (_selectedDietTypeId == null) return false;
    if (_selectedGoalId == null) return false;

    return true;
  }

  double _parseDoubleStrict(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.parse(t);
  }

  // ======================= Local search helpers =======================
  List<GenericIngredientItem> _searchIngredients(String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];

    // filtro simple (O(n)). Con cientos/miles va ok.
    // Si fueran decenas de miles, hacemos prefix-index o trie.
    final results = _genericIngredientsIndex.where((it) {
      return it.name.toLowerCase().contains(q);
    }).take(10).toList();

    return results;
  }

  void _onAllergyIngredientQueryChanged() async {
    if (_genericIngredients.isEmpty) return;

    final q = _allergyIngredientCtrl.text;
    setState(() => _loadingSuggestions = true);

    try {
      final res = _searchIngredients(q);
      // quitar ya seleccionados en alergias
      final filtered = res.where((x) => !_selectedAllergyGenericIngredientIds.contains(x.id)).toList();

      if (!mounted) return;
      setState(() => _allergyIngredientSuggestions = filtered);
    } finally {
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  void _onBlacklistIngredientQueryChanged() async {
    if (_genericIngredients.isEmpty) return;

    final q = _blacklistIngredientCtrl.text;
    setState(() => _loadingSuggestions = true);

    try {
      final res = _searchIngredients(q);
      // quitar ya seleccionados en blacklist
      final filtered = res.where((x) => !_selectedBlacklistGenericIngredientIds.contains(x.id)).toList();

      if (!mounted) return;
      setState(() => _blacklistIngredientSuggestions = filtered);
    } finally {
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  Future<void> _addAllergyIngredient(GenericIngredientItem item) async {
    setState(() {
      _selectedAllergyGenericIngredientIds.add(item.id);
      _allergyIngredientCtrl.clear();
      _allergyIngredientSuggestions = [];
    });
    await _saveSelectionsToPrefs();
  }

  Future<void> _addBlacklistIngredient(GenericIngredientItem item) async {
    setState(() {
      _selectedBlacklistGenericIngredientIds.add(item.id);
      _blacklistIngredientCtrl.clear();
      _blacklistIngredientSuggestions = [];
    });
    await _saveSelectionsToPrefs();
  }

  Future<void> _removeAllergyIngredient(int id) async {
    setState(() => _selectedAllergyGenericIngredientIds.remove(id));
    await _saveSelectionsToPrefs();
  }

  Future<void> _removeBlacklistIngredient(int id) async {
    setState(() => _selectedBlacklistGenericIngredientIds.remove(id));
    await _saveSelectionsToPrefs();
  }

  // ======================= Submit =======================
  Future<void> _saveAll() async {
    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      final accountId = _accountId!;

      final profileId = await _profileService.findOrCreateProfileId(
        accountId: accountId,
        profileName: _profileName,
      );

      final payload = <String, dynamic>{
        "profile_id": profileId,
        "diet_type_id": _selectedDietTypeId!,
        "goal_id": _selectedGoalId!,
        "birth_date": _birthDateIso,
        "weight": _parseDoubleStrict(_weight),
        "height": _parseDoubleStrict(_height),
        "waist_measure": _parseDoubleStrict(_waist),
        "hips_measure": _parseDoubleStrict(_hips),
        "sex": _sexApi,
        "activity_level": _activityLevelApi,
      };

      await _settingsService.setProfileSettings(
        accountId: accountId,
        profileId: profileId,
        payload: payload,
      );

      if (_selectedIllnessIds.isNotEmpty) {
        await _settingsService.setProfileIllnessIds(
          accountId: accountId,
          profileId: profileId,
          illnessIds: _selectedIllnessIds.toList(),
        );
      }

      // ✅ bans: backend solo acepta una lista de genericIngredientIds
      final genericUnion = <int>{
        ..._selectedAllergyGenericIngredientIds,
        ..._selectedBlacklistGenericIngredientIds,
      }.toList();

      await _bansService.setBans(
        accountId: accountId,
        profileId: profileId,
        foodFamilyIds: _selectedAllergyFoodFamilyIds.toList(),
        genericIngredientIds: genericUnion,
      );

      await _saveSelectionsToPrefs();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ======================= UI =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
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
                      fontSize: 26,
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
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_accountId == null)
                  _errorBox("No se encontró accountId. Regístrate primero."),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _errorBox(_error!),
                ],

                _sectionTitle("Tipo de dieta", "Selecciona tu estilo de alimentación"),
                const SizedBox(height: 12),
                _dietGridFromApi(),
                const SizedBox(height: 24),

                _sectionTitle("Meta física", "Selecciona solo un objetivo."),
                const SizedBox(height: 12),
                _goalListFromApi(),
                const SizedBox(height: 26),

                _sectionTitle("Condiciones médicas", "Selecciona las que aplican."),
                const SizedBox(height: 12),
                _illnessChips(),
                const SizedBox(height: 26),

                _sectionTitle("Alérgenos por familia", "Selecciona familias a evitar."),
                const SizedBox(height: 12),
                _foodFamilyChips(),
                const SizedBox(height: 26),

                _sectionTitle("Alérgenos por ingrediente", "Busca y añade ingredientes."),
                const SizedBox(height: 12),
                _ingredientPicker(
                  controller: _allergyIngredientCtrl,
                  suggestions: _allergyIngredientSuggestions,
                  onPick: _addAllergyIngredient,
                  selectedIds: _selectedAllergyGenericIngredientIds,
                  onRemove: _removeAllergyIngredient,
                  hint: "Ej: fresa, mostaza, maní…",
                ),
                const SizedBox(height: 26),

                _sectionTitle("Lista negra", "Ingredientes que no te gustan."),
                const SizedBox(height: 12),
                _ingredientPicker(
                  controller: _blacklistIngredientCtrl,
                  suggestions: _blacklistIngredientSuggestions,
                  onPick: _addBlacklistIngredient,
                  selectedIds: _selectedBlacklistGenericIngredientIds,
                  onRemove: _removeBlacklistIngredient,
                  hint: "Ej: cebolla, brócoli…",
                ),

                const SizedBox(height: 26),
                if (_loadingSuggestions) const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSave ? _saveAll : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
          );
        },
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dangerRed.withOpacity(0.4)),
      ),
      child: Text(msg, style: const TextStyle(color: dangerRed, fontSize: 13)),
    );
  }

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

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7F2) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? primaryGreen : const Color(0xFFE3E6EA),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: selected ? primaryGreen : textGrey,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _illnessChips() {
    if (_illnessCatalog.isEmpty) {
      return _errorBox("No hay enfermedades disponibles (BD vacía).");
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _illnessCatalog.map((ill) {
        final selected = _selectedIllnessIds.contains(ill.id);
        return _chip(
          label: ill.name,
          selected: selected,
          onTap: () async {
            setState(() {
              selected ? _selectedIllnessIds.remove(ill.id) : _selectedIllnessIds.add(ill.id);
            });
            await _saveSelectionsToPrefs();
          },
        );
      }).toList(),
    );
  }

  Widget _foodFamilyChips() {
    if (_foodFamilies.isEmpty) return _errorBox("No hay food families (BD vacía).");

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _foodFamilies.map((ff) {
        final selected = _selectedAllergyFoodFamilyIds.contains(ff.id);
        return _chip(
          label: ff.name,
          selected: selected,
          onTap: () async {
            setState(() {
              selected
                  ? _selectedAllergyFoodFamilyIds.remove(ff.id)
                  : _selectedAllergyFoodFamilyIds.add(ff.id);
            });
            await _saveSelectionsToPrefs();
          },
        );
      }).toList(),
    );
  }

  Widget _ingredientPicker({
    required TextEditingController controller,
    required List<GenericIngredientItem> suggestions,
    required Future<void> Function(GenericIngredientItem) onPick,
    required Set<int> selectedIds,
    required Future<void> Function(int) onRemove,
    required String hint,
  }) {
    // Mostrar nombres seleccionados (con lookup desde el catálogo completo)
    final selectedItems = _genericIngredients
        .where((x) => selectedIds.contains(x.id))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9AA3AE)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),

        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = suggestions[i];
                return ListTile(
                  dense: true,
                  title: Text(
                    s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onPick(s),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 10),

        if (selectedItems.isEmpty)
          const Text(
            "No has seleccionado ingredientes.",
            style: TextStyle(color: textGrey, fontSize: 13),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: selectedItems.map((it) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFBFD7FF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(it.name, style: const TextStyle(fontSize: 13, color: textPrimary)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onRemove(it.id),
                      child: const Icon(Icons.close, size: 16, color: dangerRed),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // Diets/Goals UI simplificada (puedes usar tu versión anterior si quieres)
  Widget _dietGridFromApi() {
    if (_dietTypes.isEmpty) return _errorBox("No hay diet-types (BD vacía).");

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _dietTypes.map((diet) {
        final selected = diet.id == _selectedDietTypeId;
        return _chip(
          label: diet.name,
          selected: selected,
          onTap: () async {
            setState(() => _selectedDietTypeId = diet.id);
            await _saveSelectionsToPrefs();
          },
        );
      }).toList(),
    );
  }

  Widget _goalListFromApi() {
    if (_goals.isEmpty) return _errorBox("No hay goals (BD vacía).");

    return Column(
      children: _goals.map((g) {
        final selected = g.id == _selectedGoalId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: selected ? primaryGreen : borderGrey,
                width: selected ? 2 : 1,
              ),
            ),
            title: Text(g.name),
            trailing: selected
                ? const Icon(Icons.check_circle, color: primaryGreen)
                : const Icon(Icons.circle_outlined, color: textGrey),
            onTap: () async {
              setState(() => _selectedGoalId = g.id);
              await _saveSelectionsToPrefs();
            },
          ),
        );
      }).toList(),
    );
  }
}