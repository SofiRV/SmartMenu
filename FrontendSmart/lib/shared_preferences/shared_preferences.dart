import 'package:shared_preferences/shared_preferences.dart';

class UserDataStorage {
  // ===== Draft keys (alineadas con el onboarding actual) =====
  static const String _keyAccountId = 'accountId';

  static const String _keyProfileName = 'profileName';
  static const String _keyBirthDateIso = 'birthDate'; // YYYY-MM-DD

  // API enums
  static const String _keySexApi = 'sexApi'; // "male" | "female"
  static const String _keyActivityLevelApi =
      'activityLevelApi'; // "very low" | "low" | "mid" | "high" | "very high"

  // Measures (strings para no perder lo que escribe el usuario)
  static const String _keyWeight = 'weight';
  static const String _keyHeight = 'height';
  static const String _keyWaist = 'waist';
  static const String _keyHips = 'hips';

  // Preferences IDs
  static const String _keyDietTypeId = 'dietTypeId';
  static const String _keyGoalId = 'goalId';

  // Illness draft (hasta que esté todo conectado): guardamos nombres e ids separados
  static const String _keyIllnessNames = 'illnessNames'; // List<String>
  static const String _keyIllnessIds = 'illnessIds'; // List<String> (ids as string)

  // ========= Account =========
  static Future<int?> getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAccountId);
  }

  static Future<void> setAccountId(int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAccountId, accountId);
  }

  // ========= Draft save/load =========
  static Future<void> savePersonalDraft({
    required String profileName,
    required String birthDateIso,
    required String sexApi,
    required String activityLevelApi,
    required String weight,
    required String height,
    required String waist,
    required String hips,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileName, profileName.trim());
    await prefs.setString(_keyBirthDateIso, birthDateIso.trim());
    await prefs.setString(_keySexApi, sexApi);
    await prefs.setString(_keyActivityLevelApi, activityLevelApi);

    await prefs.setString(_keyWeight, weight.trim());
    await prefs.setString(_keyHeight, height.trim());
    await prefs.setString(_keyWaist, waist.trim());
    await prefs.setString(_keyHips, hips.trim());
  }

  static Future<Map<String, dynamic>> loadPersonalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "profileName": prefs.getString(_keyProfileName) ?? '',
      "birthDate": prefs.getString(_keyBirthDateIso) ?? '',
      "sexApi": prefs.getString(_keySexApi) ?? 'female',
      "activityLevelApi": prefs.getString(_keyActivityLevelApi) ?? 'mid',
      "weight": prefs.getString(_keyWeight) ?? '',
      "height": prefs.getString(_keyHeight) ?? '',
      "waist": prefs.getString(_keyWaist) ?? '',
      "hips": prefs.getString(_keyHips) ?? '',
    };
  }

  static Future<void> savePreferencesDraft({
    int? dietTypeId,
    int? goalId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (dietTypeId != null) {
      await prefs.setInt(_keyDietTypeId, dietTypeId);
    }
    if (goalId != null) {
      await prefs.setInt(_keyGoalId, goalId);
    }
  }

  static Future<Map<String, int?>> loadPreferencesDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "dietTypeId": prefs.getInt(_keyDietTypeId),
      "goalId": prefs.getInt(_keyGoalId),
    };
  }

  static Future<void> saveIllnessDraft({
    required List<String> illnessNames,
    required List<int> illnessIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyIllnessNames, illnessNames);
    await prefs.setStringList(
      _keyIllnessIds,
      illnessIds.map((e) => e.toString()).toList(),
    );
  }

  static Future<Map<String, dynamic>> loadIllnessDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_keyIllnessNames) ?? <String>[];
    final idsStr = prefs.getStringList(_keyIllnessIds) ?? <String>[];
    final ids = idsStr.map((s) => int.tryParse(s)).whereType<int>().toList();

    return {"names": names, "ids": ids};
  }

  static Future<void> clearAllDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyProfileName);
    await prefs.remove(_keyBirthDateIso);
    await prefs.remove(_keySexApi);
    await prefs.remove(_keyActivityLevelApi);

    await prefs.remove(_keyWeight);
    await prefs.remove(_keyHeight);
    await prefs.remove(_keyWaist);
    await prefs.remove(_keyHips);

    await prefs.remove(_keyDietTypeId);
    await prefs.remove(_keyGoalId);

    await prefs.remove(_keyIllnessNames);
    await prefs.remove(_keyIllnessIds);

    // claves viejas por compatibilidad (si existían)
    await prefs.remove('age');
    await prefs.remove('gender');
    await prefs.remove('activity');
  }
}