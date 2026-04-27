import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/launch_splash_page.dart';
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
    final baseTextTheme = ThemeData.light().textTheme.apply(
      bodyColor: const Color(0xFF183433),
      displayColor: const Color(0xFF183433),
    );
    final textTheme = GoogleFonts.nunitoTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.fredoka(
        textStyle: baseTextTheme.displayLarge,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      displayMedium: GoogleFonts.fredoka(
        textStyle: baseTextTheme.displayMedium,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      displaySmall: GoogleFonts.fredoka(
        textStyle: baseTextTheme.displaySmall,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: GoogleFonts.fredoka(
        textStyle: baseTextTheme.headlineLarge,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.fredoka(
        textStyle: baseTextTheme.headlineMedium,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.fredoka(
        textStyle: baseTextTheme.headlineSmall,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.fredoka(
        textStyle: baseTextTheme.titleLarge,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.nunito(
        textStyle: baseTextTheme.titleMedium,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w800,
      ),
      titleSmall: GoogleFonts.nunito(
        textStyle: baseTextTheme.titleSmall,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: GoogleFonts.nunito(
        textStyle: baseTextTheme.bodyLarge,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: GoogleFonts.nunito(
        textStyle: baseTextTheme.bodyMedium,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      bodySmall: GoogleFonts.nunito(
        textStyle: baseTextTheme.bodySmall,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w700,
      ),
      labelLarge: GoogleFonts.nunito(
        textStyle: baseTextTheme.labelLarge,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w800,
      ),
      labelMedium: GoogleFonts.nunito(
        textStyle: baseTextTheme.labelMedium,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w800,
      ),
      labelSmall: GoogleFonts.nunito(
        textStyle: baseTextTheme.labelSmall,
        color: const Color(0xFF183433),
        fontWeight: FontWeight.w800,
      ),
    );

    return MaterialApp(
      title: 'Dear Environment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF3E9D2),
        textTheme: textTheme,
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
            return GoogleFonts.nunito(
              color: const Color(0xFF173230),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            );
          }),
        ),
      ),
      home: const _AppEntryPoint(),
    );
  }
}

class _AppEntryPoint extends StatefulWidget {
  const _AppEntryPoint();

  @override
  State<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<_AppEntryPoint> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return LaunchSplashPage(
        onFinished: () {
          if (!mounted) return;
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return const HomePage();
  }
}
