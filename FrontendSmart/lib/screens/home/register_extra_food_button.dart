import 'package:flutter/material.dart';
import '../register_extra_food_screen.dart';

class RegisterExtraFoodButton extends StatelessWidget {
  const RegisterExtraFoodButton({
    super.key,
    this.onSaved,
  });

  final Future<void> Function()? onSaved;

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
      child: InkWell(
        onTap: () async {
          final didSave = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterExtraFoodScreen(),
            ),
          );

          if (didSave == true && onSaved != null) {
            await onSaved!();
          }
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