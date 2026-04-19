import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

// Importar todas las pantallas
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import 'screens/personal_data_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_password_screen.dart';
import 'screens/recover_password_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/individual_home_screen.dart';
import 'screens/saved_recipes_screen.dart';
import 'screens/post_login_router_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const SmartMenuApp());
}

class SmartMenuApp extends StatelessWidget {
  const SmartMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SmartMenu',
          theme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.light,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
          ),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/register': (context) => const RegisterScreen(),
            '/personal_data': (context) => const PersonalDataScreen(),
            '/login': (context) => const LoginScreen(),
            '/new_password': (context) =>
                const NewPasswordScreen(token: 'test_token'),
            '/recover_password': (context) => RecoverPasswordScreen(),
            '/preferences': (context) => const PreferencesScreen(),
            '/individual_home': (context) => const IndividualHomeScreen(),
            '/saved_recipes': (context) => const SavedRecipesScreen(),
            '/post_login': (context) => const PostLoginRouterScreen(),
          },
        );
      },
    );
  }
}