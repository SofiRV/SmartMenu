import 'package:flutter/material.dart';
import '../shop_screen.dart'; // Ajusta la importación si tu ruta es diferente

class ShoppingListCard extends StatelessWidget {
  final VoidCallback? onTap;
  final int pendingProducts; // Cantidad de productos pendientes, opcional

  const ShoppingListCard({
    super.key,
    this.onTap,
    this.pendingProducts = 12, // Por defecto 12 como en el mockup
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ShopScreen(),
              ),
            );
          },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(22, 0, 0, 0),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mi lista de\ncompras",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$pendingProducts productos\npendientes",
                    style: const TextStyle(
                      color: Color.fromARGB(220, 255, 255, 255),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF7C3AED),
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}