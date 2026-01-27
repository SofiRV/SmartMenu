import 'package:flutter/material.dart';

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

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    setState(() {
      _submitted = true;
      _emailError = null;
      _passwordError = null;
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

    if (!hasError) {
      // ✅ Sin popup/snackbar (como pediste)
      Navigator.pushNamed(context, '/personal_data');
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

              // ───────── CAJA BLANCA ─────────
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/recover_password',
                                );
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

              // ==========================
              // 🔧 ESPACIADOS DESDE AQUÍ
              // ==========================

              // Espacio entre la caja blanca y el botón Aceptar
              const SizedBox(height: 25), // ← cambia este número
              // ───────── BOTÓN ACEPTAR ─────────
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
                  onPressed: _login,
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              // Espacio entre botón Aceptar y la línea "o continúa con"
              const SizedBox(height: 25), // ← cambia este número
              // ───────── LÍNEA CON TEXTO ─────────
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

              // Espacio entre la línea y los botones sociales
              const SizedBox(height: 20), // ← cambia este número
              // ───────── BOTONES SOCIALES ─────────
              SizedBox(
                width: 280, // 👈 MISMO ANCHO QUE EL BOTÓN ACEPTAR
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.apple, color: Colors.black),
                        label: const Text(
                          'Apple',
                          style: TextStyle(color: Colors.black),
                        ),
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
                        label: const Text(
                          'Google',
                          style: TextStyle(color: Colors.black),
                        ),
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

              // ✅ OPCIÓN 1: Espacio extra para bajar "¿No tienes cuenta?"
              const SizedBox(
                height: 30,
              ), // ← cambia este número (más abajo/arriba)
              // ───────── REGISTRO ─────────
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                        text: "¿No tienes cuenta? ",
                        style: TextStyle(
                          color: Color.fromARGB(255, 107, 101, 101),
                        ),
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

              // Espacio final inferior (por si quieres más aire)
              const SizedBox(height: 20), // ← cambia este número
            ],
          ),
        ),
      ),
    );
  }

  // ───────── CAMPO DE TEXTO ─────────
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
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
