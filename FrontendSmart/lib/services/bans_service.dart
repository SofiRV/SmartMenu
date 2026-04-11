import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class BansService {
  Future<Map<String, dynamic>> setBans({
    required int accountId,
    required int profileId,
    required List<int> foodFamilyIds,
    required List<int> genericIngredientIds,
  }) async {
    final uri = Uri.parse(
      ApiConfig.url("/account/$accountId/profile/$profileId/bans"),
    );

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "foodFamilyIds": {"ids": foodFamilyIds},
        "genericIngredientIds": {"ids": genericIngredientIds},
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("POST bans failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Unexpected bans response: ${res.body}");
  }
}