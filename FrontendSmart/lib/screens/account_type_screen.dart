import 'package:flutter/material.dart';

const Color primaryGreen = Color.fromARGB(255, 11, 153, 101);
const Color screenBg = Color(0xFFE8F9F5);

const Color boxGreen = Color.fromARGB(255, 220, 245, 236);
const Color boxBlue = Color(0xFFEAF3FF);

const String imgIndividual = 'imgIndividual.png';
const String imgFamiliar = 'imgFamiliar.png';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  String selected = "individual";

  void _select(String value) {
    if (selected == value) return;
    setState(() => selected = value);
  }

  void _continue() {
    if (selected == "individual") {
      Navigator.pushNamed(context, '/preferences');
    } else {
      Navigator.pushNamed(context, '/personal_data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Animación suave (misma sensación que tus cards)
    const duration = Duration(milliseconds: 240);
    const curve = Curves.easeOutCubic;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: screenBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),

      // ✅ CONTENIDO CON SCROLL (para evitar overflow)
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            // ✅ Subimos un poquito el título (más arriba)
            const SizedBox(height: 0),
            const Text(
              "¿Cómo vas a usar\nSmartMenu?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1A1A1A),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Selecciona el tipo de cuenta que mejor\nse adapte a ti",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF5A5565),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 22),

            _optionCard(
              imagePath: imgIndividual,
              accentColor: primaryGreen,
              featuresBgColor: boxGreen,
              title: "Cuenta Individual",
              subtitle: "Solo para mí",
              description: const [
                "Un solo perfil de usuario",
                "Preferencias personalizadas",
                "Menús adaptados a ti",
              ],
              value: "individual",
            ),

            const SizedBox(height: 16),

            _optionCard(
              imagePath: imgFamiliar,
              accentColor: const Color(0xFF2F73FF),
              featuresBgColor: boxBlue,
              title: "Cuenta Familiar",
              subtitle: "Para toda la familia",
              description: const [
                "Hasta 6 perfiles diferentes",
                "Preferencias individuales",
                "Plan semanal compartido",
                "Lista de compra unificada",
              ],
              value: "family",
            ),

            const SizedBox(height: 14),

            // ✅ TIP debajo de la caja "Cuenta Familiar" con animación suave
            AnimatedScale(
              duration: duration,
              curve: curve,
              scale: 1.0,
              child: AnimatedOpacity(
                duration: duration,
                curve: curve,
                opacity: 1.0,
                child: _tipCard(),
              ),
            ),

            // ✅ Espacio para que NO lo tape el botón fijo de abajo
            const SizedBox(height: 110),
          ],
        ),
      ),

      // ✅ BOTÓN FIJO ABAJO (sin overflow)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: _continue,
            child: const Text(
              "Continuar",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ TIP (como tu imagen)
  Widget _tipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(18, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("💡", style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Tip: Puedes cambiar el tipo de\ncuenta en cualquier momento",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF5A5565),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionCard({
    required String imagePath,
    required Color accentColor,
    required Color featuresBgColor,
    required String title,
    required String subtitle,
    required List<String> description,
    required String value,
  }) {
    final bool isSelected = selected == value;

    const duration = Duration(milliseconds: 220);
    const curve = Curves.easeOutCubic;

    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.985,
      duration: duration,
      curve: curve,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _select(value),
        child: AnimatedContainer(
          duration: duration,
          curve: curve,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? accentColor : const Color(0xFFE6E6E6),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(22, 0, 0, 0),
                blurRadius: isSelected ? 14 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ sin fondo, solo la imagen
                  Image.asset(
                    imagePath,
                    width: 62,
                    height: 62,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF5A5565),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Check animado
                  AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? accentColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : const Color(0xFFC9CDD5),
                        width: 2,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              key: ValueKey('check'),
                              size: 16,
                              color: Colors.white,
                            )
                          : const SizedBox(key: ValueKey('empty')),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              AnimatedContainer(
                duration: duration,
                curve: curve,
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: featuresBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: description
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key == description.length - 1 ? 0 : 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check, size: 18, color: accentColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF5A5565),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
