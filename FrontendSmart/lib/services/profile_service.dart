import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ProfileService {
  Future<List<Map<String, dynamic>>> getProfiles({required int accountId}) async {
    final uri = Uri.parse(ApiConfig.url("/account/$accountId/profiles/"));

    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("GET profiles failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    throw Exception("Unexpected profiles response: ${res.body}");
  }

  Future<Map<String, dynamic>> createProfile({
    required int accountId,
    required String name,
  }) async {
    final uri = Uri.parse(ApiConfig.url("/account/$accountId/profile"));

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name.trim()}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("POST profile failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception("Unexpected create profile response: ${res.body}");
  }

  Future<int> findOrCreateProfileId({
    required int accountId,
    required String profileName,
  }) async {
    final name = profileName.trim();
    final profiles = await getProfiles(accountId: accountId);

    final existing = profiles.where((p) {
      final pName = (p['name'] ?? p['profileName'] ?? '').toString().trim();
      return pName.toLowerCase() == name.toLowerCase();
    }).toList();

    if (existing.isNotEmpty) {
      final id = existing.first['id'];
      if (id is int) return id;
      if (id is num) return id.toInt();
      return int.parse(id.toString());
    }

    final created = await createProfile(accountId: accountId, name: name);
    final id = created['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return int.parse(id.toString());
  }
}