import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _passwordVisible = false;
  bool _submitted = false;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAccountSession({
    required int accountId,
    String? username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accountId', accountId);
    await prefs.setString('email', email);
    if (username != null && username.trim().isNotEmpty) {
      await prefs.setString('username', username.trim());
    }
  }

  Future<Map<String, dynamic>> _callLogin({
    required String email,
    required String password,
  }) async {
    // IMPORTANTE:
    // Este endpoint lo tiene que exponer el backend.
    // Recomendación: POST /userApi/v1/account/login
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
      throw Exception("Login failed: HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception("Unexpected login response: ${res.body}");
  }

  Future<void> _login() async {
    setState(() {
      _submitted = true;
      _emailError = null;
      _passwordError = null;
      _formError = null;
    });

    bool hasError = false;

    if (_emailCtrl.text.trim().isEmpty) {
      _emailError = "Ingresa tu correo";
      hasError = true;
    } else if (!_emailCtrl.text.contains('@')) {
      _emailError = "Correo inválido";
      hasError = true;
    }

    if (_passwordCtrl.text.isEmpty) {
      _passwordError = "Ingresa tu contraseña";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resp = await _callLogin(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );

      final result = (resp['result'] ?? '').toString().toUpperCase();

      if (result != "OK") {
        setState(() {
          _formError = "Correo o contraseña incorrectos.";
        });
        return;
      }

      // Ideal: backend devuelve accountId
      final accountIdRaw = resp['accountId'] ?? resp['id'];
      if (accountIdRaw == null) {
        // Si el backend NO devuelve accountId, no podemos continuar bien.
        setState(() {
          _formError =
              "Login OK pero el backend no devolvió accountId. Ajustad el endpoint para devolverlo.";
        });
        return;
      }

      final int accountId = accountIdRaw is int
          ? accountIdRaw
          : (accountIdRaw is num)
              ? accountIdRaw.toInt()
              : int.parse(accountIdRaw.toString());

      await _saveAccountSession(
        accountId: accountId,
        username: resp['username']?.toString(),
        email: _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      // ✅ Flujo correcto: al home principal
      Navigator.pushReplacementNamed(context, '/individual_home');
    } catch (e) {
      setState(() {
        _formError = "No se pudo iniciar sesión. Inténtalo de nuevo.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Accede a tu cuenta",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _inputField(
                            "Correo electrónico",
                            _emailCtrl,
                            _emailError,
                            Icons.email_outlined,
                          ),
                          const SizedBox(height: 15),
                          _inputField(
                            "Contraseña",
                            _passwordCtrl,
                            _passwordError,
                            Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 10),
                          if (_submitted && _formError != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/recover_password');
                              },
                              child: const Text(
                                "¿Olvidaste tu contraseña?",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: 280,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: Text(
                    _isLoading ? "Entrando..." : "Aceptar",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'o continúa con',
                      style: TextStyle(
                        color: Color.fromARGB(255, 56, 56, 56),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 280,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.apple, color: Colors.black),
                        label: const Text('Apple', style: TextStyle(color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.asset('google.png', height: 20),
                        label: const Text('Google', style: TextStyle(color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: "¿No tienes cuenta? ",
                        style: TextStyle(color: Color.fromARGB(255, 107, 101, 101)),
                      ),
                      TextSpan(
                        text: "Regístrate",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController ctrl,
    String? error,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: ctrl,
          obscureText: isPassword ? !_passwordVisible : false,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  )
                : null,
            floatingLabelStyle: const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.w500,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 23, 183, 124),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        if (_submitted && error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}