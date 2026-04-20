import 'package:flutter/material.dart';
import 'dart:async';

import '../shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      final accountId = await UserDataStorage.getAccountId();

      if (!mounted) return;

      if (accountId != null) {
        Navigator.pushReplacementNamed(context, '/post_login');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 79, 240, 176),
              Color.fromARGB(255, 11, 153, 101),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // 🟢 LOGO (imagen) + sombra SOLO ABAJO + animación
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 🌫️ SOMBRA SUAVE SOLO ABAJO
                      Positioned(
                        bottom: -8,
                        child: Container(
                          width: 110,
                          height: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(90, 0, 0, 0),
                                blurRadius: 24,
                                offset: Offset(0, 14),
                                spreadRadius: -12,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 🟢 LOGO
                      Image.asset(
                        'Logoblanco.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Bienvenido a SmartMenu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tu asistente de menús inteligente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 30),

              // ⏺️ PUNTITOS (con mini animación suave)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value; // 0..1
                  final pulse =
                      0.9 + (0.2 * (t < 0.5 ? t * 2 : (1 - t) * 2)); // 0.9..1.1

                  return Transform.scale(
                    scale: pulse,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, size: 10, color: Colors.white),
                        SizedBox(width: 6),
                        Icon(Icons.circle, size: 10, color: Colors.white70),
                        SizedBox(width: 6),
                        Icon(Icons.circle, size: 10, color: Colors.white38),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
