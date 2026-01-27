import 'package:shared_preferences/shared_preferences.dart';

class UserDataStorage {
  // Claves para SharedPreferences
  static const String _keyAge = 'age';
  static const String _keyWeight = 'weight';
  static const String _keyHeight = 'height';
  static const String _keyGender = 'gender';
  static const String _keyActivity = 'activity';

  // Guardar datos
  static Future<void> saveUserData({
    required String age,
    required String weight,
    required String height,
    required String gender,
    required String activityLevel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAge, age);
    await prefs.setString(_keyWeight, weight);
    await prefs.setString(_keyHeight, height);
    await prefs.setString(_keyGender, gender);
    await prefs.setString(_keyActivity, activityLevel);
  }

  // Cargar datos
  static Future<Map<String, String>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'age': prefs.getString(_keyAge) ?? '',
      'weight': prefs.getString(_keyWeight) ?? '',
      'height': prefs.getString(_keyHeight) ?? '',
      'gender': prefs.getString(_keyGender) ?? 'Mujer',
      'activity': prefs.getString(_keyActivity) ?? 'Ligero (ejercicio 1-3 día)',
    };
  }

  // Limpiar datos
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAge);
    await prefs.remove(_keyWeight);
    await prefs.remove(_keyHeight);
    await prefs.remove(_keyGender);
    await prefs.remove(_keyActivity);
  }
}
