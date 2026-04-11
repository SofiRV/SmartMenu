import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: const Text("Mis recetas guardadas"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            "Aquí se verán tus recetas guardadas.\n\n(Próximamente)",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}