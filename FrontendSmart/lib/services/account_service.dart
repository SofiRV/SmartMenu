import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class LoginResult {
  final bool ok;
  final int? accountId;
  final String? username;
  final String? email;

  LoginResult({required this.ok, this.accountId, this.username, this.email});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final result = (json['result'] ?? '').toString();
    if (result != 'OK') return LoginResult(ok: false);

    final account = json['account'] as Map<String, dynamic>?;
    if (account == null) return LoginResult(ok: false);

    final rawId = account['id'];
    final id = rawId is int ? rawId : (rawId as num).toInt();

    return LoginResult(
      ok: true,
      accountId: id,
      username: (account['username'] ?? '').toString(),
      email: (account['email'] ?? '').toString(),
    );
  }
}

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

    throw Exception("Unexpected response: ${res.body}");
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConfig.url("/account/login"));

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("LOGIN failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return LoginResult.fromJson(decoded);
    }

    throw Exception("Unexpected login response: ${res.body}");
  }
}