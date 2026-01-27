import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(
      begin: 0.90, // 👈 más visible que 0.97
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward(from: 0); // 👈 asegura que arranque siempre
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 239, 230),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Stack(
                      clipBehavior:
                          Clip.none, // ✅ CLAVE para que NO recorte la sombra
                      alignment: Alignment.center,
                      children: [
                        // 🌫️ sombra suave SOLO abajo
                        Positioned(
                          bottom: -12,
                          child: Container(
                            width: 80,
                            height: 18,
                            decoration: BoxDecoration(
                              // un pelín de color para que el shadow se pinte sí o sí
                              color: Colors.black.withOpacity(0.01),
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(55, 0, 0, 0),
                                  blurRadius: 16,
                                  offset: Offset(0, 10),
                                  spreadRadius: -8,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // LOGO
                        Image.asset(
                          'Logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Bienvenido a SmartMenu',
                  style: TextStyle(
                    fontSize: 34,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    height: 0.99,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Planifica tus comidas, gestiona tus recetas y simplifica tu lista de compras',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 65, 65, 65),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 60,
                  ),
                  child: Image.asset(
                    'cubiertosbien.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color.fromARGB(255, 8, 110, 73);
                      }
                      return const Color.fromARGB(255, 11, 153, 101);
                    }),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, 50),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 15),

                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color.fromARGB(255, 210, 241, 229);
                      }
                      return const Color.fromARGB(255, 255, 255, 255);
                    }),
                    side: WidgetStateProperty.all(
                      const BorderSide(
                        color: Color.fromARGB(255, 11, 153, 101),
                        width: 2,
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, 50),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(
                      color: Color.fromARGB(255, 11, 153, 101),
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
