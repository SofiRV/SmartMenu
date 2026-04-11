import 'package:flutter/material.dart';

import '../services/camera_service.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

const Color textDark = Color(0xFF1A1A1A);
const Color textGrey = Color(0xFF5A5565);

const Color chipGreenBg = Color(0xFFE9FBF5);
const Color chipGreenBorder = Color(0xFFBDEBDA);

const Color cardShadow = Color.fromARGB(22, 0, 0, 0);

class SearchRecipeScreen extends StatefulWidget {
  const SearchRecipeScreen({super.key});

  @override
  State<SearchRecipeScreen> createState() => _SearchRecipeScreenState();
}

class _SearchRecipeScreenState extends State<SearchRecipeScreen> {
  // Ingredientes (simulando)
  final List<_IngredientChip> ingredients = [
    _IngredientChip("Tomates", "🍅", true),
    _IngredientChip("Huevos", "🥚", true),
    _IngredientChip("Cebolla", "🧅", true),
    _IngredientChip("Ajo", "🧄", true),
    _IngredientChip("Aceite", "🫒", true),
    _IngredientChip("Pasta", "🍝", false),
  ];

  String selectedFilter = "Rápidas";

  final List<String> filters = const [
    "Rápidas",
    "Elaboradas",
    "Postres",
    "Favoritos",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,

      // ✅ SIN APPBAR: header idéntico al Home
      body: Column(
        children: [
          // ================= Header verde (MISMO que Home) =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Buscar recetas 🍽️",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Basado en tus ingredientes",
                          style: TextStyle(
                            color: Color.fromARGB(190, 255, 255, 255),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // circulito derecha como Home
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.search_rounded,
                        color: primaryGreen,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= Contenido scroll =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _scanAICard(),
                  const SizedBox(height: 14),
                  _addCustomRecipeCard(),
                  const SizedBox(height: 18),

                  // Ingredientes disponibles + Editar
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Ingredientes disponibles",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // aquí puedes ir a pantalla de editar ingredientes
                        },
                        child: const Text(
                          "Editar",
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ingredients.map((ing) {
                      return _ingredientChip(
                        label: ing.name,
                        emoji: ing.emoji,
                        selected: ing.selected,
                        onTap: () {
                          setState(() => ing.selected = !ing.selected);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Filtros (Rápidas/Elaboradas/Postres/Favoritos)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: filters.map((f) {
                      final bool isSel = selectedFilter == f;
                      return _filterPill(
                        text: f,
                        selected: isSel,
                        onTap: () => setState(() => selectedFilter = f),
                        icon: _filterIcon(f),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Recetas sugeridas",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _recipeCard(
                    iconEmoji: "🍳",
                    title: "Huevos\nRancheros",
                    level: "Fácil",
                    time: "15 min",
                    kcal: "320 kcal",
                    match: "95% match",
                    matchColor: const Color(0xFFDDF7EE),
                    missing: null,
                  ),
                  const SizedBox(height: 12),
                  _recipeCard(
                    iconEmoji: "🥘",
                    title: "Tortilla Española",
                    level: "Media",
                    time: "25 min",
                    kcal: "280 kcal",
                    match: "80% match",
                    matchColor: const Color(0xFFEAF3FF),
                    missing: "Te falta: Patatas",
                  ),
                  const SizedBox(height: 12),
                  _recipeCard(
                    iconEmoji: "🍅",
                    title: "Salsa de\nTomate",
                    level: "Fácil",
                    time: "30 min",
                    kcal: "120 kcal",
                    match: "100% match",
                    matchColor: const Color(0xFFDDF7EE),
                    missing: null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- WIDGETS ----------

  Widget _scanAICard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.photo_camera_outlined, size: 18, color: textGrey),
              SizedBox(width: 10),
              Text(
                "Escanear ingredientes con IA",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () async {
              final file = await CameraService.takePhoto(imageQuality: 85);
              if (!mounted) return;

              if (file == null) return; // canceló

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Foto tomada: ${file.name}")),
              );

              // TODO: aquí mandas file.path a tu IA/backend
            },
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC9CDD5), width: 1.2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.auto_awesome,
                      size: 28,
                      color: Color(0xFF9AA3B2),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Toca para escanear",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addCustomRecipeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Añadir mi propia\nreceta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Crea y guarda tus\nrecetas personalizadas",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // navegar a crear receta
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientChip({
    required String label,
    required String emoji,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? chipGreenBg : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? chipGreenBorder : const Color(0xFFE6E6E6),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPill({
    required String text,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFBFD7FF) : const Color(0xFFE6E6E6),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? const Color(0xFF2F73FF) : textGrey,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: selected ? const Color(0xFF2F73FF) : textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipeCard({
    required String iconEmoji,
    required String title,
    required String level,
    required String time,
    required String kcal,
    required String match,
    required Color matchColor,
    required String? missing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: cardShadow, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(iconEmoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                          height: 1.15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: matchColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        match,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: textGrey),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Color(0xFFFF8A00),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      kcal,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
                if (missing != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      missing,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9A6B00),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _filterIcon(String f) {
    switch (f) {
      case "Rápidas":
        return Icons.access_time;
      case "Elaboradas":
        return Icons.restaurant_menu;
      case "Postres":
        return Icons.cake_outlined;
      case "Favoritos":
        return Icons.star_outline;
      default:
        return Icons.tune;
    }
  }
}

class _IngredientChip {
  final String name;
  final String emoji;
  bool selected;
  _IngredientChip(this.name, this.emoji, this.selected);
}