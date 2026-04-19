import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/profile_service.dart';
import '../services/profile_settings_service.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);

class PostLoginRouterScreen extends StatefulWidget {
  const PostLoginRouterScreen({super.key});

  @override
  State<PostLoginRouterScreen> createState() => _PostLoginRouterScreenState();
}

class _PostLoginRouterScreenState extends State<PostLoginRouterScreen> {
  final _profiles = ProfileService();
  final _settings = ProfileSettingsService();

  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  bool _looksLikeSettingsComplete(Map<String, dynamic> s) {
    // Ajusta si tu backend devuelve más/menos campos.
    // Con que existan diet_type_id y goal_id ya es buena señal.
    final diet = s['diet_type_id'] ?? s['dietTypeId'];
    final goal = s['goal_id'] ?? s['goalId'];
    return diet != null && goal != null;
  }

  Future<void> _run() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId');

      if (accountId == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final profiles = await _profiles.getProfiles(accountId: accountId);

      if (profiles.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/personal_data');
        return;
      }

      // Solo 1 perfil: cogemos el primero
      final p0 = profiles.first;
      final rawProfileId = p0['id'];
      final profileId = rawProfileId is int
          ? rawProfileId
          : (rawProfileId is num)
              ? rawProfileId.toInt()
              : int.parse(rawProfileId.toString());

      // Guarda profileId por comodidad (lo usas mucho)
      await prefs.setInt('profileId', profileId);

      final s = await _settings.getProfileSettings(
        accountId: accountId,
        profileId: profileId,
      );

      if (s.isEmpty || !_looksLikeSettingsComplete(s)) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/personal_data');
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: primaryGreen),
              const SizedBox(height: 14),
              const Text(
                "Cargando tu perfil…",
                style: TextStyle(fontSize: 14),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _run,
                  child: const Text("Reintentar"),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}