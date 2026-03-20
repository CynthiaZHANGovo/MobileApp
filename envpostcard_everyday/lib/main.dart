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
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
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
      ),
      home: const HomePage(),
    );
  }
}
