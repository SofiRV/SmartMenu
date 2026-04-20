import 'package:flutter/material.dart';
import '../register_extra_food_screen.dart'; // Asegúrate de ajustar el import según tu estructura

class RegisterExtraFoodButton extends StatelessWidget {
  const RegisterExtraFoodButton({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterExtraFoodScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFECFBF5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF7EE7C2),
              width: 1.6,
            ),
          ),
          child: const Center(
            child: Text(
              "+   Registrar algo más que comí",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: primaryGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}