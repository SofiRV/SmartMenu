import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFF6F9F8);
const Color softGreen = Color(0xFFE9F9F2);
const Color softBlue = Color(0xFFEAF3FF);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool horno = false;
  bool microondas = true;
  bool batidora = true;
  bool airFryer = false;
  bool thermomix = false;
  bool ollaLenta = true;
  bool procesador = true;
  bool vaporera = false;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,

      // ✅ SIN APPBAR: header idéntico al Home/Search/Shop
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
                          "Ajustes ⚙️",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Personaliza tu experiencia",
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
                        Icons.settings,
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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- PERFIL ----------------
                  _sectionTitle("PERFIL"),
                  _card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            radius: 26,
                            backgroundColor: softGreen,
                            child: Icon(Icons.person, color: primaryGreen),
                          ),
                          title: const Text(
                            "María González",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text(
                            "maria@email.com",
                            style: TextStyle(fontSize: 13),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _MiniStat(
                              title: "65 kg",
                              subtitle: "Peso",
                              icon: Icons.scale,
                            ),
                            _MiniStat(
                              title: "165 cm",
                              subtitle: "Altura",
                              icon: Icons.height,
                            ),
                            _MiniStat(
                              title: "28 años",
                              subtitle: "Edad",
                              icon: Icons.cake,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.bookmark_border),
                          label: const Text("Ver mis recetas guardadas"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ---------------- PREFERENCIAS ----------------
                  _sectionTitle("PREFERENCIAS"),
                  _card(
                    child: Column(
                      children: const [
                        _PreferenceRow(
                          icon: Icons.restaurant,
                          title: "Tipo de dieta",
                          value: "Vegetariana",
                        ),
                        _PreferenceRow(
                          icon: Icons.warning_rounded,
                          title: "Alérgenos",
                          value: "3 seleccionados",
                          iconColor: Colors.red,
                        ),
                        _PreferenceRow(
                          icon: Icons.block,
                          title: "Lista negra",
                          value: "5 alimentos",
                          iconColor: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ---------------- META FÍSICA ----------------
                  _sectionTitle("META FÍSICA"),
                  _card(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: softBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Mantenimiento",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text("💪"),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Calorías diarias recomendadas",
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "2100 kcal",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Basado en tu perfil y actividad",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ---------------- ELECTRODOMÉSTICOS ----------------
                  _sectionTitle("ELECTRODOMÉSTICOS"),
                  _card(
                    child: Column(
                      children: [
                        _deviceTile(
                          "Horno",
                          Icons.local_fire_department,
                          horno,
                          (v) => setState(() => horno = v),
                        ),
                        _deviceTile(
                          "Microondas",
                          Icons.microwave,
                          microondas,
                          (v) => setState(() => microondas = v),
                        ),
                        _deviceTile(
                          "Batidora",
                          Icons.blender,
                          batidora,
                          (v) => setState(() => batidora = v),
                        ),
                        _deviceTile(
                          "Air Fryer",
                          Icons.air,
                          airFryer,
                          (v) => setState(() => airFryer = v),
                        ),
                        _deviceTile(
                          "Thermomix",
                          Icons.precision_manufacturing,
                          thermomix,
                          (v) => setState(() => thermomix = v),
                        ),
                        _deviceTile(
                          "Olla de cocción lenta",
                          Icons.soup_kitchen,
                          ollaLenta,
                          (v) => setState(() => ollaLenta = v),
                        ),
                        _deviceTile(
                          "Procesador de alimentos",
                          Icons.settings,
                          procesador,
                          (v) => setState(() => procesador = v),
                        ),
                        _deviceTile(
                          "Vaporera",
                          Icons.cloud,
                          vaporera,
                          (v) => setState(() => vaporera = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 💡 TIP
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: softBlue,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lightbulb, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Las recetas se adaptarán automáticamente según tus electrodomésticos disponibles",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ---------------- FAMILIA ----------------
                  _sectionTitle("FAMILIA"),
                  _card(
                    child: const ListTile(
                      leading: Icon(Icons.group, color: primaryGreen),
                      title: Text("Grupo familiar"),
                      subtitle: Text("4 miembros"),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ---------------- APARIENCIA ----------------
                  _sectionTitle("APARIENCIA"),
                  _card(
                    child: SwitchListTile(
                      value: darkMode,
                      onChanged: (v) => setState(() => darkMode = v),
                      title: const Text("Modo oscuro"),
                      activeThumbColor: primaryGreen,
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

  // ---------- helpers ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: child,
    );
  }

  Widget _deviceTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: value ? softGreen : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.black,
        title: Text(title),
        secondary: Icon(icon),
      ),
    );
  }
}

// ---------- mini widgets ----------

class _MiniStat extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _MiniStat({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;

  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? primaryGreen),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontSize: 13)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
