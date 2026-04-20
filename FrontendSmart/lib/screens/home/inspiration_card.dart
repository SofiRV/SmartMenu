import 'package:flutter/material.dart';

class InspirationCard extends StatelessWidget {
  final VoidCallback? onCameraTap;

  const InspirationCard({super.key, this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
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
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onCameraTap ?? () {
              // Aquí pondrás tu integración real de cámara o IA
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Funcionalidad próximamente 😅")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
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
              color: Color(0xFF6D28D9),
            ),
            label: const Text(
              "Abrir cámara",
              style: TextStyle(
                color: Color(0xFF6D28D9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}