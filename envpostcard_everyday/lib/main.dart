import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const EnvironmentalPostcardApp());
}

class EnvironmentalPostcardApp extends StatelessWidget {
  const EnvironmentalPostcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2B5D57),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Environmental Postcard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF3E9D2),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF183433),
          displayColor: const Color(0xFF183433),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1E5751),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0x40214A45)),
            foregroundColor: const Color(0xFF183433),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white.withValues(alpha: 0.96),
          indicatorColor: const Color(0xFFE7F0EC),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: const Color(0xFF173230),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            );
          }),
        ),
      ),
      home: const HomePage(),
    );
  }
}
