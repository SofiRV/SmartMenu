import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/account_service.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  bool termsAccepted = false;
  bool _submitted = false;

  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Error general del formulario (backend / red / etc.)
  String? _formError;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // añadimos un booleano si son iguales. para validar las contraseñas y añadir el tick verde de que son iguales las dos.
  bool get _passwordsMatch {
    return _passwordCtrl.text.isNotEmpty &&
        _passwordCtrl.text == _confirmPasswordCtrl.text;
  }

  Future<void> _saveAccountSession({
    required int accountId,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accountId', accountId);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
  }

  Future<void> _register() async {
    setState(() {
      _submitted = true;
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _formError = null;
    });

    bool hasError = false;

    if (_usernameCtrl.text.trim().isEmpty) {
      _usernameError = "Ingresa tu nombre de usuario";
      hasError = true;
    }

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

    if (_confirmPasswordCtrl.text.isEmpty) {
      _confirmPasswordError = "Confirma tu contraseña";
      hasError = true;
    } else if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _confirmPasswordError = "Las contraseñas no coinciden";
      hasError = true;
    }

    if (!termsAccepted) {
      // Mantenemos el snackbar para términos (esto ya existía).
      // Si lo quieres sin snackbar también, lo cambiamos a _formError.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes aceptar los términos y condiciones"),
        ),
      );
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final service = AccountService();

      final accountId = await service.createAccount(
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      await _saveAccountSession(
        accountId: accountId,
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushNamed(context, '/personal_data');
    } catch (e) {
      debugPrint("REGISTER ERROR: $e");
      setState(() {
        _formError =
            "No se pudo crear la cuenta. Revisa los datos e inténtalo de nuevo.";
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
            color: Color.fromARGB(255, 11, 153, 101),
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
                    "Crear cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Regístrate para comenzar",
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
              const SizedBox(height: 10),
              // Caja blanca
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // ➜ margen lateral
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 450,
                    ), // ➜ limita el ancho
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
                            "Nombre de usuario",
                            _usernameCtrl,
                            _usernameError,
                            Icons.person_2_outlined,
                          ),
                          const SizedBox(height: 15),
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
                          const SizedBox(height: 15),
                          _inputField(
                            "Confirmar contraseña",
                            _confirmPasswordCtrl,
                            _confirmPasswordError,
                            Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Checkbox(
                                value: termsAccepted,
                                activeColor:
                                    const Color.fromARGB(255, 11, 153, 101),
                                onChanged: (v) =>
                                    setState(() => termsAccepted = v!),
                              ),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(text: "Acepto los "),
                                      TextSpan(
                                        text: "términos y condiciones",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            12,
                                            165,
                                            109,
                                          ),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      TextSpan(text: " y la "),
                                      TextSpan(
                                        text: "política de privacidad",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            12,
                                            165,
                                            109,
                                          ),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Error general (backend)
                          if (_submitted && _formError != null) ...[
                            const SizedBox(height: 10),
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
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: SizedBox(
                  width: 280, // <<< MISMO ANCHO QUE LA CAJA
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 11, 153, 101),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: Text(
                      _isLoading ? "Creando..." : "Aceptar",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: "¿Ya tienes cuenta? ",
                        style: TextStyle(
                          color: Color.fromARGB(255, 107, 101, 101),
                        ),
                      ),
                      TextSpan(
                        text: "Inicia sesión",
                        style: TextStyle(
                          color: Color.fromARGB(255, 11, 153, 101),
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
    // ignore: unused_local_variable
    bool isConfirmPassword = label.contains("Confirmar");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: ctrl,
          obscureText: isPassword
              ? !(label.contains("Confirmar")
                  ? _confirmPasswordVisible
                  : _passwordVisible)
              : false,
          onChanged: (_) {
            if (isPassword) {
              setState(() {}); // actualiza ticks en tiempo real
            }
          },
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: isPassword
                ? (_passwordsMatch
                    ? const Icon(
                        Icons.check,
                        color: Color.fromARGB(255, 44, 176, 128),
                      )
                    : IconButton(
                        icon: Icon(
                          (label.contains("Confirmar")
                                  ? _confirmPasswordVisible
                                  : _passwordVisible)
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            if (label.contains("Confirmar")) {
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            } else {
                              _passwordVisible = !_passwordVisible;
                            }
                          });
                        },
                      ))
                : null,
            floatingLabelStyle: const TextStyle(
              color: Color.fromARGB(255, 11, 153, 101),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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