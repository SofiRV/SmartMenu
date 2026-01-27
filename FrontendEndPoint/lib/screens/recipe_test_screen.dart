import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ---------------------------
/// 1) JSON hardcodeado (fallback)
/// ---------------------------
const Map<String, dynamic> recetaEjemploJson = {
  "name": "Paella de la Abuela",
  "tagIDs": [1, 5, 12],
  "genericIngredientIDs": [101, 102, 105, 110],
  "steps": [
    {
      "number": 1,
      "instruction": "Sofreír el conejo y el pollo hasta que estén dorados.",
      "minutes": 15,
    },
    {
      "number": 2,
      "instruction": "Añadir el tomate rallado y el azafrán.",
      "minutes": 5,
    },
  ],
  "cheffAdvice":
      "No remuevas el arroz una vez que lo eches al caldo si quieres un buen socarrat.",
};

/// ---------------------------
/// 2) Modelo
/// ---------------------------
class RecipeDetail {
  final String name;
  final List<int> tagIDs;
  final List<int> genericIngredientIDs;
  final List<RecipeStep> steps;
  final String cheffAdvice;

  RecipeDetail({
    required this.name,
    required this.tagIDs,
    required this.genericIngredientIDs,
    required this.steps,
    required this.cheffAdvice,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      name: (json["name"] ?? "").toString(),
      tagIDs: (json["tagIDs"] as List? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      genericIngredientIDs: (json["genericIngredientIDs"] as List? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      steps:
          (json["steps"] as List? ?? [])
              .map(
                (e) => RecipeStep.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList()
            ..sort((a, b) => a.number.compareTo(b.number)),
      cheffAdvice: (json["cheffAdvice"] ?? "").toString(),
    );
  }
}

class RecipeStep {
  final int number;
  final String instruction;
  final int minutes;

  RecipeStep({
    required this.number,
    required this.instruction,
    required this.minutes,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      number: (json["number"] as num?)?.toInt() ?? 0,
      instruction: (json["instruction"] ?? "").toString(),
      minutes: (json["minutes"] as num?)?.toInt() ?? 0,
    );
  }
}

/// ---------------------------
/// 3) Service para pegarle al endpoint
/// ---------------------------
class RecipeApi {
  final String baseUrl;
  const RecipeApi({required this.baseUrl});

  Future<RecipeDetail> fetchRecipeDetail() async {
    // Ajusta esta ruta a tu API real:
    final uri = Uri.parse("$baseUrl/recipe/detail");

    final res = await http.get(
      uri,
      headers: {
        "Accept": "application/json",
        // "Authorization": "Bearer TU_TOKEN" // si lo necesitas
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body);

    // Si tu endpoint devuelve directamente el objeto:
    if (decoded is Map<String, dynamic>) {
      return RecipeDetail.fromJson(decoded);
    }

    // Si devuelve algo tipo { data: {...} }
    if (decoded is Map && decoded["data"] is Map) {
      return RecipeDetail.fromJson(
        (decoded["data"] as Map).cast<String, dynamic>(),
      );
    }

    throw Exception("Formato de respuesta no esperado");
  }
}

/// ---------------------------
/// 4) UI SmartMenu - Detalle Receta (Test Endpoint)
/// ---------------------------
class RecipeTestScreen extends StatefulWidget {
  /// Pon aquí tu endpoint base (ej: "http://10.0.2.2:8000" en emulador Android)
  final String baseUrl;

  /// Si quieres forzar hardcodeado para probar UI sin backend
  final bool forceHardcoded;

  const RecipeTestScreen({
    super.key,
    required this.baseUrl,
    this.forceHardcoded = false,
  });

  @override
  State<RecipeTestScreen> createState() => _RecipeTestScreenState();
}

class _RecipeTestScreenState extends State<RecipeTestScreen> {
  late Future<RecipeDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<RecipeDetail> _load() async {
    if (widget.forceHardcoded) {
      await Future.delayed(const Duration(milliseconds: 250));
      return RecipeDetail.fromJson(recetaEjemploJson);
    }

    try {
      final api = RecipeApi(baseUrl: widget.baseUrl);
      return await api.fetchRecipeDetail();
    } catch (_) {
      // Fallback para que SIEMPRE veas algo en pantalla
      return RecipeDetail.fromJson(recetaEjemploJson);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    // Estética tipo SmartMenu (suave, femenino, limpio)
    const bg = Color(0xFFFFF3F7); // rosita muy claro
    const card = Colors.white;
    const textTitle = Color(0xFF2B2B2B);
    const textMuted = Color(0xFF6D6D6D);
    const accent = Color(0xFFE86AA8); // rosa acento
    const chipBg = Color(0xFFFFE1EE);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detalle de receta (Test)",
          style: TextStyle(
            color: textTitle,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: textTitle),
        actions: [
          IconButton(
            tooltip: "Refrescar",
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<RecipeDetail>(
        future: _future,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          if (isLoading) {
            return const _SmartLoading();
          }

          if (snapshot.hasError) {
            // Aun así, el fallback debería evitar esto, pero lo dejamos robusto.
            return _SmartError(
              message: "No se pudo cargar la receta.\n${snapshot.error}",
              onRetry: _refresh,
            );
          }

          final recipe = snapshot.data;
          if (recipe == null) {
            return _SmartError(
              message: "No hay datos de receta.",
              onRetry: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // Header bonito
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          color: textTitle,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Chip(
                            label: "Tags: ${recipe.tagIDs.length}",
                            bg: chipBg,
                            fg: accent,
                            icon: Icons.local_offer_rounded,
                          ),
                          _Chip(
                            label:
                                "Ingredientes: ${recipe.genericIngredientIDs.length}",
                            bg: chipBg,
                            fg: accent,
                            icon: Icons.shopping_basket_rounded,
                          ),
                          _Chip(
                            label: "Pasos: ${recipe.steps.length}",
                            bg: chipBg,
                            fg: accent,
                            icon: Icons.format_list_numbered_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // TAG IDs
                _SectionCard(
                  title: "Tag IDs",
                  icon: Icons.local_offer_rounded,
                  child: _IdWrap(ids: recipe.tagIDs),
                ),

                const SizedBox(height: 12),

                // INGREDIENT IDs
                _SectionCard(
                  title: "Generic Ingredient IDs",
                  icon: Icons.shopping_basket_rounded,
                  child: _IdWrap(ids: recipe.genericIngredientIDs),
                ),

                const SizedBox(height: 12),

                // STEPS
                _SectionCard(
                  title: "Pasos",
                  icon: Icons.format_list_numbered_rounded,
                  child: Column(
                    children: recipe.steps
                        .map(
                          (s) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFFD0E3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE1EE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${s.number}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.instruction,
                                        style: const TextStyle(
                                          color: textTitle,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "⏱ ${s.minutes} min",
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // CHEF ADVICE
                _SectionCard(
                  title: "Consejo del chef",
                  icon: Icons.lightbulb_rounded,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE1EE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      recipe.cheffAdvice,
                      style: const TextStyle(
                        color: textTitle,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Footer mini para debug
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF2D8E5)),
                  ),
                  child: Text(
                    "Endpoint base: ${widget.baseUrl}\n"
                    "Modo hardcoded: ${widget.forceHardcoded ? "Sí" : "No (con fallback)"}",
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------
/// Widgets de soporte (estética)
/// ---------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const card = Colors.white;
    const textTitle = Color(0xFF2B2B2B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE86AA8)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: textTitle,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _IdWrap extends StatelessWidget {
  final List<int> ids;

  const _IdWrap({required this.ids});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE86AA8);
    const chipBg = Color(0xFFFFE1EE);

    if (ids.isEmpty) {
      return const Text(
        "—",
        style: TextStyle(color: Color(0xFF6D6D6D), fontWeight: FontWeight.w600),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ids
          .map(
            (id) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "$id",
                style: const TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SmartLoading extends StatelessWidget {
  const _SmartLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              "Cargando receta…",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SmartError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 42),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text("Reintentar")),
          ],
        ),
      ),
    );
  }
}
