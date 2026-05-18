import 'package:flutter/material.dart';

class DetailsRecipeScreen extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const DetailsRecipeScreen({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    // El nombre puede venir como 'name' o 'self_name'
    final name = recipeData['name'] ??
        recipeData['self_name'] ??
        'Sin nombre';
    final advice = recipeData['chefAdvice'] ??
        recipeData['chef_advice'] ??
        '';
    final kcal = recipeData['kcal']?.toString() ?? '--';
    final steps = (recipeData['steps'] as List<dynamic>?) ?? [];
    final ingredients = (recipeData['ingredients'] as List<dynamic>?) ?? [];
    final tags = (recipeData['tags'] as List<dynamic>?) ?? [];
    final hasRecipeDetails = steps.isNotEmpty || ingredients.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F5),
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF0B9965),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con kcal y tags
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$kcal kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B9965),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: tags.map<Widget>((t) {
                  return Chip(
                    label: Text(t['name'] ?? ''),
                    backgroundColor: const Color(0xFFF2E9FF),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Consejo del chef (solo si es una receta)
            if (advice.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFD7FF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        advice,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1B44BF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Si tiene ingredientes o pasos → mostrar como receta
            if (hasRecipeDetails) ...[
              if (ingredients.isNotEmpty) ...[
                const Text(
                  'Ingredientes',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...ingredients.map((ing) {
                  final ingName = ing['name'] ?? '';
                  final ingKcal = ing['kcal']?.toString() ?? '--';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.circle,
                        size: 8, color: Color(0xFF0B9965)),
                    title: Text(ingName),
                    trailing: Text('$ingKcal kcal'),
                  );
                }),
              ],
              if (steps.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Pasos',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(steps.length, (index) {
                  final step = steps[index];
                  final instruction = step['instruction'] ?? '';
                  final time = step['estimatedTime']?.toString();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              const Color(0xFF0B9965),
                          radius: 16,
                          child: Text('${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(instruction),
                              if (time != null)
                                Text('⏱ $time min',
                                    style: const TextStyle(
                                        color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ] else ...[
              // Ingrediente simple: mostrar información básica
              const SizedBox(height: 16),
              const Text(
                'Información nutricional',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('🔥 Calorías: $kcal kcal'),
              if (recipeData['food_family'] != null &&
                  recipeData['food_family']['name'] != null)
                Text(
                    'Familia: ${recipeData['food_family']['name']}'),
              if (recipeData['food_family_id'] != null)
                Text(
                    'ID de familia: ${recipeData['food_family_id']}'),
            ],
          ],
        ),
      ),
    );
  }
}