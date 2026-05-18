import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart';
import 'details_recipe_screen.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  List<Map<String, dynamic>> _recipes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId');
      if (accountId == null) {
        setState(() {
          _error = "No se encontró la cuenta.";
          _loading = false;
        });
        return;
      }

      final uri = Uri.parse(ApiConfig.url("/specific-recipe/account/$accountId"));
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _recipes = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        throw Exception("Error al cargar recetas (${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteRecipe(int recipeId) async {
    try {
      final uri = Uri.parse(ApiConfig.url("/specific-recipe/$recipeId"));
      final response = await http.delete(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Receta eliminada correctamente")),
        );
        _loadRecipes(); // Recargar la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  Future<void> _confirmDelete(int recipeId, String recipeName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar receta"),
        content: Text("¿Estás seguro de que quieres eliminar \"$recipeName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteRecipe(recipeId);
    }
  }

  Future<void> _openRecipeDetail(int recipeId) async {
    try {
      final uri = Uri.parse(ApiConfig.url("/specific-recipe/$recipeId"));
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> recipeData = jsonDecode(response.body);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsRecipeScreen(recipeData: recipeData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar detalle (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: const Text("Mis recetas guardadas"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      "Error: $_error\n\nTira para recargar.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              : _recipes.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          "Aún no tienes recetas guardadas.\n\nCrea una desde 'Buscar recetas' o 'Añadir mi propia receta'.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRecipes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          final name = recipe['name'] ?? 'Sin nombre';
                          final kcal = recipe['kcal']?.toString() ?? '--';
                          final advice = recipe['chefAdvice'];
                          final recipeId = recipe['id'] is int
                              ? recipe['id']
                              : int.parse(recipe['id'].toString());

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('🔥 $kcal kcal'),
                                  if (advice != null && advice.toString().isNotEmpty)
                                    Text('💡 ${advice.toString()}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _confirmDelete(recipeId, name),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () => _openRecipeDetail(recipeId),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}