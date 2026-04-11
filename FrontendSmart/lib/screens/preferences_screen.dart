import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/catalog_service.dart';
import '../services/profile_service.dart';
import '../services/profile_settings_service.dart';
import '../services/bans_service.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

const Color textPrimary = Color(0xFF1A1A1A);
const Color textGrey = Color(0xFF5A5565);
const Color borderGrey = Color.fromARGB(255, 248, 240, 240);

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

  int? _selectedDietTypeId;
  int? _selectedGoalId;

  // Illnesses (chips)
  final TextEditingController _illnessCtrl = TextEditingController();
  List<IllnessItem> _selectedIllnesses = [];
  List<IllnessItem> _illnessSuggestions = [];
  bool _loadingIllnessSuggestions = false;

  // ===== BANS via search suggestions (connects to back) =====
  final TextEditingController _foodFamilyAllergyCtrl = TextEditingController();
  final TextEditingController _ingredientAllergyCtrl = TextEditingController();
  final TextEditingController _blacklistIngredientCtrl =
      TextEditingController();

  List<FoodFamilyItem> _foodFamilySuggestions = [];
  List<GenericIngredientItem> _ingredientSuggestions = [];
  List<GenericIngredientItem> _blacklistSuggestions = [];

  List<FoodFamilyItem> _selectedAllergyFamilies = [];
  List<GenericIngredientItem> _selectedAllergyIngredients = [];
  List<GenericIngredientItem> _selectedBlacklistIngredients = [];

  bool _loadingFoodFamilySug = false;
  bool _loadingIngredientSug = false;
  bool _loadingBlacklistSug = false;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFuture = _init();

    _illnessCtrl.addListener(_onIllnessQueryChanged);

    _foodFamilyAllergyCtrl.addListener(_onFoodFamilyQueryChanged);
    _ingredientAllergyCtrl.addListener(_onIngredientAllergyQueryChanged);
    _blacklistIngredientCtrl.addListener(_onBlacklistQueryChanged);
  }

  @override
  void dispose() {
    _illnessCtrl.dispose();
    _foodFamilyAllergyCtrl.dispose();
    _ingredientAllergyCtrl.dispose();
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
    });
  }

  Future<void> _loadCatalogs() async {
    final diets = await _catalog.getDietTypes();
    final goals = await _catalog.getGoals();

    setState(() {
      _dietTypes = diets;
      _goals = goals;
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

    await prefs.setStringList(
      'illnessIds',
      _selectedIllnesses.map((e) => e.id.toString()).toList(),
    );
    await prefs.setStringList(
      'illnessNames',
      _selectedIllnesses.map((e) => e.name).toList(),
    );

    // bans draft (ids as strings)
    await prefs.setStringList(
      'bannedFoodFamilyIds',
      _selectedAllergyFamilies.map((e) => e.id.toString()).toList(),
    );
    await prefs.setStringList(
      'bannedGenericIngredientIds_allergy',
      _selectedAllergyIngredients.map((e) => e.id.toString()).toList(),
    );
    await prefs.setStringList(
      'bannedGenericIngredientIds_blacklist',
      _selectedBlacklistIngredients.map((e) => e.id.toString()).toList(),
    );
  }

  // ========================= Illness helpers =========================
  void _onIllnessQueryChanged() async {
    final q = _illnessCtrl.text.trim();
    if (q.length < 2) {
      setState(() {
        _illnessSuggestions = [];
      });
      return;
    }

    setState(() => _loadingIllnessSuggestions = true);
    try {
      final results = await _catalog.searchIllnesses(query: q);
      final selectedIds = _selectedIllnesses.map((e) => e.id).toSet();
      final filtered = results.where((e) => !selectedIds.contains(e.id)).toList();

      if (!mounted) return;
      setState(() {
        _illnessSuggestions = filtered.take(6).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _illnessSuggestions = [];
      });
    } finally {
      if (mounted) setState(() => _loadingIllnessSuggestions = false);
    }
  }

  Future<void> _addIllnessFromText() async {
    final text = _illnessCtrl.text.trim();
    if (text.isEmpty) return;

    try {
      final created = await _catalog.createOrGetIllness(name: text);
      final already = _selectedIllnesses.any((e) => e.id == created.id);
      if (!already) {
        setState(() {
          _selectedIllnesses.add(created);
        });
      }
      setState(() {
        _illnessCtrl.clear();
        _illnessSuggestions = [];
      });
      await _saveSelectionsToPrefs();
    } catch (e) {
      setState(() {
        _error = "No se pudo añadir la condición. (${e.toString()})";
      });
    }
  }

  void _addIllnessFromSuggestion(IllnessItem item) async {
    final already = _selectedIllnesses.any((e) => e.id == item.id);
    if (!already) {
      setState(() => _selectedIllnesses.add(item));
      await _saveSelectionsToPrefs();
    }
    setState(() {
      _illnessCtrl.clear();
      _illnessSuggestions = [];
    });
  }

  // ========================= BANS (search suggestions) =========================
  void _onFoodFamilyQueryChanged() async {
    final q = _foodFamilyAllergyCtrl.text.trim();
    if (q.length < 2) {
      setState(() => _foodFamilySuggestions = []);
      return;
    }

    setState(() => _loadingFoodFamilySug = true);
    try {
      final res = await _catalog.searchFoodFamilies(query: q);
      final selectedIds = _selectedAllergyFamilies.map((e) => e.id).toSet();
      setState(() {
        _foodFamilySuggestions =
            res.where((e) => !selectedIds.contains(e.id)).take(6).toList();
      });
    } catch (_) {
      setState(() => _foodFamilySuggestions = []);
    } finally {
      if (mounted) setState(() => _loadingFoodFamilySug = false);
    }
  }

  void _onIngredientAllergyQueryChanged() async {
    final q = _ingredientAllergyCtrl.text.trim();
    if (q.length < 2) {
      setState(() => _ingredientSuggestions = []);
      return;
    }

    setState(() => _loadingIngredientSug = true);
    try {
      final res = await _catalog.searchGenericIngredients(query: q);
      final selectedIds = _selectedAllergyIngredients.map((e) => e.id).toSet();
      setState(() {
        _ingredientSuggestions =
            res.where((e) => !selectedIds.contains(e.id)).take(6).toList();
      });
    } catch (_) {
      setState(() => _ingredientSuggestions = []);
    } finally {
      if (mounted) setState(() => _loadingIngredientSug = false);
    }
  }

  void _onBlacklistQueryChanged() async {
    final q = _blacklistIngredientCtrl.text.trim();
    if (q.length < 2) {
      setState(() => _blacklistSuggestions = []);
      return;
    }

    setState(() => _loadingBlacklistSug = true);
    try {
      final res = await _catalog.searchGenericIngredients(query: q);
      final selectedIds =
          _selectedBlacklistIngredients.map((e) => e.id).toSet();
      setState(() {
        _blacklistSuggestions =
            res.where((e) => !selectedIds.contains(e.id)).take(6).toList();
      });
    } catch (_) {
      setState(() => _blacklistSuggestions = []);
    } finally {
      if (mounted) setState(() => _loadingBlacklistSug = false);
    }
  }

  void _addFoodFamilyAllergy(FoodFamilyItem item) async {
    final already = _selectedAllergyFamilies.any((e) => e.id == item.id);
    if (!already) {
      setState(() => _selectedAllergyFamilies.add(item));
      await _saveSelectionsToPrefs();
    }
    setState(() {
      _foodFamilyAllergyCtrl.clear();
      _foodFamilySuggestions = [];
    });
  }

  void _addIngredientAllergy(GenericIngredientItem item) async {
    final already = _selectedAllergyIngredients.any((e) => e.id == item.id);
    if (!already) {
      setState(() => _selectedAllergyIngredients.add(item));
      await _saveSelectionsToPrefs();
    }
    setState(() {
      _ingredientAllergyCtrl.clear();
      _ingredientSuggestions = [];
    });
  }

  void _addBlacklistIngredient(GenericIngredientItem item) async {
    final already = _selectedBlacklistIngredients.any((e) => e.id == item.id);
    if (!already) {
      setState(() => _selectedBlacklistIngredients.add(item));
      await _saveSelectionsToPrefs();
    }
    setState(() {
      _blacklistIngredientCtrl.clear();
      _blacklistSuggestions = [];
    });
  }

  // ========================= Submit =========================
  bool get _canSave {
    if (_saving) return false;
    if (_accountId == null) return false;

    // required by ProfileSettingsCreate
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
        "birth_date": _birthDateIso, // backend expects str
        "weight": _parseDoubleStrict(_weight),
        "height": _parseDoubleStrict(_height),
        "waist_measure": _parseDoubleStrict(_waist),
        "hips_measure": _parseDoubleStrict(_hips),
        "sex": _sexApi, // "male" | "female"
        "activity_level": _activityLevelApi, // "very low" | ... | "very high"
      };

      await _settingsService.setProfileSettings(
        accountId: accountId,
        profileId: profileId,
        payload: payload,
      );

      if (_selectedIllnesses.isNotEmpty) {
        await _settingsService.setProfileIllnessIds(
          accountId: accountId,
          profileId: profileId,
          illnessIds: _selectedIllnesses.map((e) => e.id).toList(),
        );
      }

      // Bans:
      // - foodFamilyIds = allergy families
      // - genericIngredientIds = union(allergy ingredients + blacklist ingredients)
      final foodFamilyIds = _selectedAllergyFamilies.map((e) => e.id).toList();
      final genericIngredientIds = <int>{
        ..._selectedAllergyIngredients.map((e) => e.id),
        ..._selectedBlacklistIngredients.map((e) => e.id),
      }.toList();

      await _bansService.setBans(
        accountId: accountId,
        profileId: profileId,
        foodFamilyIds: foodFamilyIds,
        genericIngredientIds: genericIngredientIds,
      );

      await _saveSelectionsToPrefs();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/individual_home');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ========================= UI =========================
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
                  _errorBox(
                    "No se encontró accountId en SharedPreferences. Inicia sesión/registro primero.",
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _errorBox(_error!),
                ],
                _sectionTitle("Tipo de dieta",
                    "Selecciona tu estilo de alimentación"),
                const SizedBox(height: 12),
                _dietGridFromApi(),
                const SizedBox(height: 24),
                _sectionTitle("Meta física", "Selecciona solo un objetivo."),
                const SizedBox(height: 12),
                _goalListFromApi(),
                const SizedBox(height: 26),
                _sectionTitle(
                    "Condiciones médicas", "Escribe y añade a tu perfil"),
                const SizedBox(height: 12),
                _illnessInputCard(),
                const SizedBox(height: 10),
                _illnessSelectedChips(),
                const SizedBox(height: 26),
                _sectionTitle("Alérgenos por familia",
                    "Ej: mariscos, lácteos (Food Families)"),
                const SizedBox(height: 12),
                _foodFamilyAllergyCard(),
                const SizedBox(height: 10),
                _foodFamilySelectedChips(),
                const SizedBox(height: 26),
                _sectionTitle("Alérgenos por ingrediente",
                    "Ej: fresas, mostaza (Generic Ingredients)"),
                const SizedBox(height: 12),
                _ingredientAllergyCard(),
                const SizedBox(height: 10),
                _ingredientAllergySelectedChips(),
                const SizedBox(height: 26),
                _sectionTitle("Lista negra",
                    "Alimentos que no te gustan (Generic Ingredients)"),
                const SizedBox(height: 12),
                _blacklistCard(),
                const SizedBox(height: 10),
                _blacklistSelectedChips(),
                const SizedBox(height: 26),
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

  // ====== Common UI helpers ======
  Widget _errorBox(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dangerRed.withOpacity(0.4)),
      ),
      child: Text(
        msg,
        style: const TextStyle(color: dangerRed, fontSize: 13),
      ),
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

  // ====== Diets ======
  Widget _dietGridFromApi() {
    if (_dietTypes.isEmpty) {
      return _errorBox(
        "No hay diet-types disponibles (endpoint aún no responde o BD vacía).",
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _dietTypes.map((diet) {
        final bool isSelected = diet.id == _selectedDietTypeId;

        return GestureDetector(
          onTap: () async {
            setState(() => _selectedDietTypeId = diet.id);
            await _saveSelectionsToPrefs();
          },
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
                    const Text("🥗", style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 10),
                    Text(
                      diet.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
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
                        color:
                            isSelected ? primaryGreen : const Color(0xFFC9CDD5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 14, color: Colors.white)
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

  // ====== Goals ======
  Widget _goalListFromApi() {
    if (_goals.isEmpty) {
      return _errorBox(
        "No hay goals disponibles (endpoint aún no responde o BD vacía).",
      );
    }

    Color accentForName(String name) {
      final n = name.toLowerCase();
      if (n.contains('perder')) return dangerRed;
      if (n.contains('manten')) return blueAccent;
      if (n.contains('masa') || n.contains('muscul')) {
        return const Color(0xFFF59E0B);
      }
      return const Color(0xFFEC4899);
    }

    Color bgForName(String name) {
      final n = name.toLowerCase();
      if (n.contains('perder')) return const Color(0xFFFFF1F1);
      if (n.contains('manten')) return blueBgSoft;
      if (n.contains('masa') || n.contains('muscul')) {
        return const Color(0xFFFFF7E6);
      }
      return const Color(0xFFFFF1F7);
    }

    Color borderForName(String name) {
      final n = name.toLowerCase();
      if (n.contains('perder')) return const Color(0xFFFFC9C9);
      if (n.contains('manten')) return blueBorder;
      if (n.contains('masa') || n.contains('muscul')) {
        return const Color(0xFFFFE0A3);
      }
      return const Color(0xFFFFC7DF);
    }

    return Column(
      children: _goals.map((g) {
        final bool isSelected = g.id == _selectedGoalId;
        final Color accent = accentForName(g.name);
        final Color bg = bgForName(g.name);
        final Color border = borderForName(g.name);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () async {
              setState(() => _selectedGoalId = g.id);
              await _saveSelectionsToPrefs();
            },
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
                    child: const Text("🎯", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      g.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
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
                        color: isSelected
                            ? accent
                            : const Color.fromARGB(255, 201, 205, 213),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.white)
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

  // ====== Illnesses UI ======
  Widget _illnessInputCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Añadir condición",
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
                  controller: _illnessCtrl,
                  decoration: InputDecoration(
                    hintText: "Ej: diabetes tipo 2, hipertensión…",
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _saving ? null : _addIllnessFromText,
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
          const SizedBox(height: 10),
          if (_loadingIllnessSuggestions)
            const LinearProgressIndicator(minHeight: 2),
          if (_illnessSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _illnessSuggestions.map((s) {
                return GestureDetector(
                  onTap: () => _addIllnessFromSuggestion(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE3E6EA)),
                    ),
                    child: Text(
                      s.name,
                      style: const TextStyle(fontSize: 13, color: textGrey),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _illnessSelectedChips() {
    if (_selectedIllnesses.isEmpty) {
      return const Text(
        "No has añadido condiciones.",
        style: TextStyle(color: textGrey, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _selectedIllnesses.map((ill) {
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
              Text(
                ill.name,
                style: const TextStyle(fontSize: 13, color: textPrimary),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  setState(() => _selectedIllnesses
                      .removeWhere((e) => e.id == ill.id));
                  await _saveSelectionsToPrefs();
                },
                child: const Icon(Icons.close, size: 16, color: dangerRed),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  // ====== Food family allergy ======
  Widget _foodFamilyAllergyCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Buscar familia",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textGrey),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _foodFamilyAllergyCtrl,
            decoration: InputDecoration(
              hintText: "Ej: mariscos, lácteos…",
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
          const SizedBox(height: 10),
          if (_loadingFoodFamilySug) const LinearProgressIndicator(minHeight: 2),
          if (_foodFamilySuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _foodFamilySuggestions.map((s) {
                return GestureDetector(
                  onTap: () => _addFoodFamilyAllergy(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE3E6EA)),
                    ),
                    child: Text(s.name, style: const TextStyle(fontSize: 13, color: textGrey)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _foodFamilySelectedChips() {
    if (_selectedAllergyFamilies.isEmpty) {
      return const Text(
        "No has añadido familias alergénicas.",
        style: TextStyle(color: textGrey, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _selectedAllergyFamilies.map((ff) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFFC9C9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ff.name, style: const TextStyle(fontSize: 13, color: dangerRed)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  setState(() => _selectedAllergyFamilies.removeWhere((e) => e.id == ff.id));
                  await _saveSelectionsToPrefs();
                },
                child: const Icon(Icons.close, size: 16, color: dangerRed),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ====== Ingredient allergy ======
  Widget _ingredientAllergyCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Buscar ingrediente",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textGrey),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ingredientAllergyCtrl,
            decoration: InputDecoration(
              hintText: "Ej: fresas, mostaza…",
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
          const SizedBox(height: 10),
          if (_loadingIngredientSug) const LinearProgressIndicator(minHeight: 2),
          if (_ingredientSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _ingredientSuggestions.map((s) {
                return GestureDetector(
                  onTap: () => _addIngredientAllergy(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE3E6EA)),
                    ),
                    child: Text(s.name, style: const TextStyle(fontSize: 13, color: textGrey)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ingredientAllergySelectedChips() {
    if (_selectedAllergyIngredients.isEmpty) {
      return const Text(
        "No has añadido alérgenos por ingrediente.",
        style: TextStyle(color: textGrey, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _selectedAllergyIngredients.map((gi) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFFC9C9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(gi.name, style: const TextStyle(fontSize: 13, color: dangerRed)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  setState(() => _selectedAllergyIngredients.removeWhere((e) => e.id == gi.id));
                  await _saveSelectionsToPrefs();
                },
                child: const Icon(Icons.close, size: 16, color: dangerRed),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ====== Blacklist ======
  Widget _blacklistCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Buscar ingrediente",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textGrey),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _blacklistIngredientCtrl,
            decoration: InputDecoration(
              hintText: "Ej: brócoli, cebolla…",
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
          const SizedBox(height: 10),
          if (_loadingBlacklistSug) const LinearProgressIndicator(minHeight: 2),
          if (_blacklistSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _blacklistSuggestions.map((s) {
                return GestureDetector(
                  onTap: () => _addBlacklistIngredient(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE3E6EA)),
                    ),
                    child: Text(s.name, style: const TextStyle(fontSize: 13, color: textGrey)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _blacklistSelectedChips() {
    if (_selectedBlacklistIngredients.isEmpty) {
      return const Text(
        "No has añadido ingredientes en lista negra.",
        style: TextStyle(color: textGrey, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _selectedBlacklistIngredients.map((gi) {
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
              Text(gi.name, style: const TextStyle(fontSize: 13, color: textPrimary)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  setState(() => _selectedBlacklistIngredients.removeWhere((e) => e.id == gi.id));
                  await _saveSelectionsToPrefs();
                },
                child: const Icon(Icons.close, size: 16, color: dangerRed),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}