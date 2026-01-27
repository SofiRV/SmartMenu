import 'package:flutter/material.dart';
import 'screens/recipe_test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RecipeTestScreen(
        baseUrl: "http://10.0.2.2:8000", // cambia por tu backend
        forceHardcoded: false, // true si quieres solo UI con json fijo
      ),
    );
  }
}
