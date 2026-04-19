import 'package:flutter/material.dart';
import '/../constants/app_colors.dart';

class InspirationSection extends StatelessWidget {
  final VoidCallback? onOpenCamera;
  final VoidCallback? onSearchRecipes;

  const InspirationSection({
    super.key,
    this.onOpenCamera,
    this.onSearchRecipes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "¿Buscas inspiración?",
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "Descubre nuevas recetas para añadir a tu plan",
          style: TextStyle(
            fontSize: 12.8,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
          ),
        ),

        const SizedBox(height: 10),

        // 🟣 Card IA cámara
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.purple,
                AppColors.purpleDark,
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(22, 0, 0, 0),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // icono cámara
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "Foto de tu nevera",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                "La IA te sugiere recetas\ncon lo que tienes disponible",
                style: TextStyle(
                  color: Color.fromARGB(220, 255, 255, 255),
                  fontSize: 13,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 14),

              ElevatedButton.icon(
                onPressed: onOpenCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(
                  Icons.photo_camera_rounded,
                  color: AppColors.purpleDark,
                ),
                label: const Text(
                  "Abrir cámara",
                  style: TextStyle(
                    color: AppColors.purpleDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🔍 Buscar recetas
        InkWell(
          onTap: onSearchRecipes,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderSoftGreen,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryGreen,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Por nombre o ingrediente",
                        style: TextStyle(
                          fontSize: 12.8,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryGreen,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}