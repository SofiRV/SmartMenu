import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ProfileSettingsService {
  Future<Map<String, dynamic>> setProfileSettings({
    required int accountId,
    required int profileId,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(
      ApiConfig.url("/account/$accountId/profile/$profileId/settings"),
    );

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("POST settings failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Unexpected settings response: ${res.body}");
  }

  /// ✅ Backend: GET /userApi/v1/account/{accountId}/profile/{profileId}/settings
  Future<Map<String, dynamic>> getProfileSettings({
    required int accountId,
    required int profileId,
  }) async {
    final uri = Uri.parse(
      ApiConfig.url("/account/$accountId/profile/$profileId/settings"),
    );

    final res = await http.get(uri);

    // Si el backend usa 404 cuando no hay settings aún, lo tratamos como "vacío"
    if (res.statusCode == 404) {
      return {};
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET settings failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Unexpected GET settings response: ${res.body}");
  }

  Future<Map<String, dynamic>> setProfileIllnessIds({
    required int accountId,
    required int profileId,
    required List<int> illnessIds,
  }) async {
    final uri = Uri.parse(
      ApiConfig.url("/account/$accountId/profile/$profileId/illnesses"),
    );

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ids": illnessIds}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("POST illnesses failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Unexpected illnesses response: ${res.body}");
  }
}