import 'package:flutter/material.dart';

/// Notificador global del modo de tema.
/// Simple y sin paquetes (no provider/bloc).
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);