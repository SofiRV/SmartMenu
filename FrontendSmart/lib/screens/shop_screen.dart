// shop_screen.dart
import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);
const Color textGrey = Color(0xFF5A5565);

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final Map<String, List<_ShopItem>> sections = {
    "Verduras": [
      _ShopItem(name: "Tomates", emoji: "🍅"),
      _ShopItem(name: "Cebolla", emoji: "🧅"),
      _ShopItem(name: "Lechuga romana", emoji: "🥬", done: true),
    ],
    "Carnes": [_ShopItem(name: "Pollo", emoji: "🍗", done: true)],
    "Panadería": [
      _ShopItem(name: "Pan", emoji: "🥖"),
      _ShopItem(name: "Pasta", emoji: "🍝"),
    ],
    "Lácteos": [
      _ShopItem(name: "Queso parmesano", emoji: "🧀"),
      _ShopItem(name: "Huevos", emoji: "🥚"),
    ],
    "Condimentos": [
      _ShopItem(name: "Salsa césar", emoji: "🥫"),
      _ShopItem(name: "Aceite de oliva", emoji: "🫒"),
    ],
  };

  int get totalItems =>
      sections.values.fold(0, (sum, list) => sum + list.length);

  int get doneItems => sections.values.fold(
    0,
    (sum, list) => sum + list.where((e) => e.done).length,
  );

  double get progress => totalItems == 0 ? 0 : doneItems / totalItems;

  @override
  Widget build(BuildContext context) {
    final remaining = (totalItems - doneItems).clamp(0, totalItems);

    return Scaffold(
      backgroundColor: screenBg,

      // ✅ SIN APPBAR: header idéntico al Home/Search (mismo tamaño/estilo)
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lista de compra 🛒",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Para tu plan semanal",
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
                        Icons.shopping_cart_outlined,
                        color: primaryGreen,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= Contenido scrolleable =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _progressCard(
                    done: doneItems,
                    total: totalItems,
                    remaining: remaining,
                    progress: progress,
                  ),
                  const SizedBox(height: 14),

                  // Botón "Añadir extras"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Añadir extras",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...sections.entries.map((entry) {
                    final pending = entry.value.where((e) => !e.done).length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _section(
                        title: entry.key,
                        pending: pending,
                        items: entry.value,
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  // Extras
                  Row(
                    children: const [
                      Text(
                        "✨  Extras",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Artículos adicionales",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFC9CDD5),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: const [
                        SizedBox(height: 4),
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFFC9CDD5),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Sin extras añadidos",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: textGrey,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Usa el botón \"Añadir extras\" para incluir\nartículos adicionales",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tip azul
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBFD7FF),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("💡", style: TextStyle(fontSize: 18)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Tip de compra\nOrganiza tu ruta por el supermercado\nsiguiendo el orden de las categorías",
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.25,
                              color: Color(0xFF1B44BF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard({
    required int done,
    required int total,
    required int remaining,
    required double progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(22, 0, 0, 0),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progreso de compra",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 232, 249, 245),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$done",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "/ $total items",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textGrey,
                ),
              ),
              const Spacer(),
              Text(
                "$remaining restantes",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(primaryGreen),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${(progress * 100).round()}% completado",
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required int pending,
    required List<_ShopItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "  $title",
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            Text(
              "$pending pendientes",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: textGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((it) => _itemTile(it)),
      ],
    );
  }

  Widget _itemTile(_ShopItem item) {
    final isDone = item.done;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDone ? const Color.fromARGB(255, 232, 249, 245) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? const Color.fromARGB(40, 11, 153, 101)
              : const Color(0xFFE6E6E6),
          width: 1,
        ),
        boxShadow: isDone
            ? []
            : const [
                BoxShadow(
                  color: Color.fromARGB(14, 0, 0, 0),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => item.done = !item.done),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isDone ? primaryGreen : const Color(0xFFC9CDD5),
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.emoji,
            style: TextStyle(
              fontSize: 20,
              color: isDone ? const Color(0xFFB7C9C2) : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: isDone
                    ? const Color(0xFF9AA3B2)
                    : const Color(0xFF1A1A1A),
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: const Color(0xFF9AA3B2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItem {
  _ShopItem({required this.name, required this.emoji, this.done = false});
  final String name;
  final String emoji;
  bool done;
}
