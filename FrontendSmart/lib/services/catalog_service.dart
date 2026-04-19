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

    int? ffId;

    // /generic-ingredient/ devuelve "food_family": {...}
    final ffObj = json['food_family'];
    if (ffObj is Map && ffObj['id'] != null) {
      final x = ffObj['id'];
      ffId = x is int ? x : (x as num).toInt();
    } else {
      final x = json['foodFamilyId'] ?? json['food_family_id'];
      if (x != null) ffId = x is int ? x : (x as num).toInt();
    }

    return GenericIngredientItem(
      id: id,
      name: (json['name'] ?? json['self_name'] ?? '').toString(),
      foodFamilyId: ffId,
    );
  }
}

class CatalogService {
  Future<List<CatalogItem>> getDietTypes() async {
    final uri = Uri.parse(ApiConfig.url("/account/diet-types"));
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET diet-types failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded.map((e) => CatalogItem.fromJson(e)).toList();
    throw Exception("Unexpected diet-types response: ${res.body}");
  }

  Future<List<CatalogItem>> getGoals() async {
    final uri = Uri.parse(ApiConfig.url("/account/goals"));
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET goals failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded.map((e) => CatalogItem.fromJson(e)).toList();
    throw Exception("Unexpected goals response: ${res.body}");
  }

  Future<List<IllnessItem>> getAllIllnesses() async {
    final uri = Uri.parse(ApiConfig.url("/account/illnesses"));
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET illnesses failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded.map((e) => IllnessItem.fromJson(e)).toList();
    throw Exception("Unexpected illnesses response: ${res.body}");
  }

  Future<List<FoodFamilyItem>> getAllFoodFamilies() async {
    final uri = Uri.parse(ApiConfig.url("/food-family/food-families"));
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET food-families failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded.map((e) => FoodFamilyItem.fromJson(e)).toList();
    throw Exception("Unexpected food-families response: ${res.body}");
  }

  Future<List<GenericIngredientItem>> getAllGenericIngredients() async {
    final uri = Uri.parse(ApiConfig.url("/generic-ingredient/"));
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET generic-ingredient failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded.map((e) => GenericIngredientItem.fromJson(e)).toList();
    throw Exception("Unexpected generic-ingredient response: ${res.body}");
  }
}