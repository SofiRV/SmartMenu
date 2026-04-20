import 'package:flutter/material.dart';

// Importa los tabs principales o screens de tu app
import 'home/home_tab.dart'; // El nuevo HomeTab refactorizado
import 'plan_screen.dart';
import 'search_recipe_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';

class IndividualHomeScreen extends StatefulWidget {
  const IndividualHomeScreen({super.key});

  @override
  State<IndividualHomeScreen> createState() => _IndividualHomeScreenState();
}

class _IndividualHomeScreenState extends State<IndividualHomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  DateTime? _lastBackPressed;

  // Lista de las páginas/tabs principales
  List<Widget> get _pages => [
        const HomeTab(),
        const PlanScreen(),
        const SearchRecipeScreen(),
        const ShopScreen(),
        const SettingsScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Si NO estás en el home tab, regresa a home tab al tocar atrás
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
      return false; // Evita salir
    }

    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pulsa de nuevo para salir'),
        duration: Duration(seconds: 2),
      ));
      return false; // No salir aún
    }
    return true; // Salir de la app
  }

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _onItemTapped(int index) => _goToTab(index);

  @override
  Widget build(BuildContext context) {
    final List<String> icons = [
      "home_ico.png",
      "plan_ico.png",
      "search_ico.png",
      "shop_ico.png",
      "settings_ico.png",
    ];

    return WillPopScope(
      onWillPop: _onWillPop, 
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          children: _pages,
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 1, color: Colors.grey[300]),
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: icons.map((iconPath) {
                final index = icons.indexOf(iconPath);
                final isSelected = index == _selectedIndex;

                return BottomNavigationBarItem(
                  icon: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 1.0,
                      end: isSelected ? 1.25 : 1.0,
                    ),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          iconPath,
                          width: 26,
                          height: 26,
                          color: isSelected
                              ? Colors.green[300]
                              : Colors.grey[500],
                        ),
                      );
                    },
                  ),
                  label: "",
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}