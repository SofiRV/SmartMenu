import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class AccountService {
  Future<int> createAccount({
    required String username,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConfig.url("/account/"));

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map && decoded["id"] != null) {
      final id = decoded["id"];
      if (id is int) return id;
      if (id is num) return id.toInt();
    }

    throw Exception("Unexpected response");
  }
}