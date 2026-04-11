import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class CatalogItem {
  final int id;
  final String name;

  CatalogItem({required this.id, required this.name});

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (rawId as num).toInt();
    return CatalogItem(
      id: id,
      name: (json['name'] ?? json['self_name'] ?? '').toString(),
    );
  }
}

class IllnessItem {
  final int id;
  final String name;

  IllnessItem({required this.id, required this.name});

  factory IllnessItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (rawId as num).toInt();
    return IllnessItem(
      id: id,
      name: (json['name'] ?? json['self_name'] ?? '').toString(),
    );
  }
}

class CatalogService {
  // Según tu compi:
  // GET /userApi/v1/accounts/diet-types
  Future<List<CatalogItem>> getDietTypes() async {
    final uri = Uri.parse(ApiConfig.url("/accounts/diet-types"));
    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET diet-types failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded.map((e) => CatalogItem.fromJson(e)).toList();
    }
    throw Exception("Unexpected diet-types response: ${res.body}");
  }

  // GET /userApi/v1/accounts/goals
  Future<List<CatalogItem>> getGoals() async {
    final uri = Uri.parse(ApiConfig.url("/accounts/goals"));
    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET goals failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded.map((e) => CatalogItem.fromJson(e)).toList();
    }
    throw Exception("Unexpected goals response: ${res.body}");
  }

  // GET /userApi/v1/accounts/illnesses?query=...
  Future<List<IllnessItem>> searchIllnesses({required String query}) async {
    final q = query.trim();
    final uri = Uri.parse(ApiConfig.url("/accounts/illnesses"))
        .replace(queryParameters: {'query': q});

    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET illnesses failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded.map((e) => IllnessItem.fromJson(e)).toList();
    }
    throw Exception("Unexpected illnesses response: ${res.body}");
  }

  // POST /userApi/v1/accounts/illnesses  (create-or-get)
  Future<IllnessItem> createOrGetIllness({required String name}) async {
    final n = name.trim();
    final uri = Uri.parse(ApiConfig.url("/accounts/illnesses"));

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": n}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("POST illness failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return IllnessItem.fromJson(decoded);
    }
    throw Exception("Unexpected create-illness response: ${res.body}");
  }
}

class FoodFamilyItem {
  final int id;
  final String name;

  FoodFamilyItem({required this.id, required this.name});

  factory FoodFamilyItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (rawId as num).toInt();
    return FoodFamilyItem(
      id: id,
      name: (json['name'] ?? json['self_name'] ?? '').toString(),
    );
  }
}

class GenericIngredientItem {
  final int id;
  final String name;
  final int? foodFamilyId;

  GenericIngredientItem({required this.id, required this.name, this.foodFamilyId});

  factory GenericIngredientItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (rawId as num).toInt();
    final ff = json['foodFamilyId'] ?? json['food_family_id'];
    return GenericIngredientItem(
      id: id,
      name: (json['name'] ?? json['self_name'] ?? '').toString(),
      foodFamilyId: ff == null ? null : (ff is int ? ff : (ff as num).toInt()),
    );
  }
}

extension BansCatalog on CatalogService {
  // GET /userApi/v1/food-family?query=...
  Future<List<FoodFamilyItem>> searchFoodFamilies({required String query}) async {
    final q = query.trim();
    final uri = Uri.parse(ApiConfig.url("/food-family"))
        .replace(queryParameters: q.isEmpty ? null : {'query': q});

    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET food-family failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded.map((e) => FoodFamilyItem.fromJson(e)).toList();
    }
    throw Exception("Unexpected food-family response: ${res.body}");
  }

  // GET /userApi/v1/generic-ingredient?query=...
  Future<List<GenericIngredientItem>> searchGenericIngredients({required String query}) async {
    final q = query.trim();
    final uri = Uri.parse(ApiConfig.url("/generic-ingredient"))
        .replace(queryParameters: q.isEmpty ? null : {'query': q});

    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET generic-ingredient failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded.map((e) => GenericIngredientItem.fromJson(e)).toList();
    }
    throw Exception("Unexpected generic-ingredient response: ${res.body}");
  }
}