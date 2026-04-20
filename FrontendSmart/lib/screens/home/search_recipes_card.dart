import 'package:flutter/material.dart';
import '../search_recipe_screen.dart'; // Ajusta si la ruta es diferente

class SearchRecipesCard extends StatelessWidget {
  final VoidCallback? onTap;

  const SearchRecipesCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
    const Color textGrey = Color(0xFF5A5565);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchRecipeScreen(),
                ),
              );
            },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFBFEBDD),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Buscar recetas",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Por nombre o ingrediente",
                      style: TextStyle(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: primaryGreen,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}