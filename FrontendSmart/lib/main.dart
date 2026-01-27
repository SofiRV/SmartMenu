import 'package:flutter/material.dart';

// Importar todas las pantallas
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import 'screens/personal_data_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_password_screen.dart';
import 'screens/recover_password_screen.dart';
import 'screens/account_type_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/individual_home_screen.dart'; // <<--- IMPORTADO

void main() {
  runApp(SmartMenuApp());
}

class SmartMenuApp extends StatelessWidget {
  const SmartMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartMenu',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/register': (context) => RegisterScreen(),
        '/personal_data': (context) => PersonalDataScreen(),
        '/login': (context) => LoginScreen(),
        '/new_password': (context) => NewPasswordScreen(token: 'test_token'),
        '/recover_password': (context) => RecoverPasswordScreen(),
        '/account_type': (context) => AccountTypeScreen(),
        '/preferences': (context) => PreferencesScreen(),
        '/individual_home': (context) =>
            IndividualHomeScreen(), // <<--- NUEVA RUTA
      },
    );
  }
}
