import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/environment_snapshot.dart';
import '../models/postcard_style_variant.dart';
import 'photo_palette_service.dart';

class PostcardStyleService {
  List<PostcardStyleVariant> buildVariants({
    required EnvironmentSnapshot environment,
    required PhotoPalette palette,
    required int streakDays,
  }) {
    final aqiAccent = _aqiAccent(environment.aqi);
    final warmFrame = _shiftLightness(palette.primary, 0.12);
    final coolFrame = _shiftHue(palette.primary, 18);
    final paperTone = _mix(palette.secondary, const Color(0xFFF3E9D2), 0.65);
    final stamp = DateFormat('MMM d').format(environment.localTime).toUpperCase();

    return [
      PostcardStyleVariant(
        name: 'Atmosphere Wash',
        tagline: 'Soft tint, layered mood',
        layout: 'floating',
        frameColor: warmFrame,
        tintColor: _mix(palette.primary, palette.secondary, 0.55),
        accentColor: aqiAccent,
        textPanelColor: Colors.white.withValues(alpha: 0.72),
        stampLabel: stamp,
        stickerLabels: [
          environment.weatherLabel,
          '${environment.temperatureC.toStringAsFixed(0)}°C',
          'Day $streakDays',
        ],
        tintOpacity: 0.20,
      ),
      PostcardStyleVariant(
        name: 'Data Collage',
        tagline: 'Signals, stamps, and context',
        layout: 'grid',
        frameColor: _mix(coolFrame, aqiAccent, 0.25),
        tintColor: _shiftHue(palette.secondary, -12),
        accentColor: _mix(aqiAccent, const Color(0xFF102B2B), 0.18),
        textPanelColor: const Color(0xEAF8F2E9),
        stampLabel: environment.aqiLabel.toUpperCase(),
        stickerLabels: [
          'AQI ${environment.aqi}',
          environment.locationLabel.split(',').first,
          environment.weatherLabel,
        ],
        tintOpacity: 0.26,
      ),
      PostcardStyleVariant(
        name: 'Future Mail',
        tagline: 'Calm paper, archival edge',
        layout: 'border',
        frameColor: paperTone,
        tintColor: _mix(palette.primary, const Color(0xFF5A7671), 0.42),
        accentColor: _mix(aqiAccent, const Color(0xFFE6B45D), 0.28),
        textPanelColor: Colors.white.withValues(alpha: 0.84),
        stampLabel: 'MAIL TO FUTURE',
        stickerLabels: [
          DateFormat('HH:mm').format(environment.localTime),
          environment.aqiLabel,
          'Streak $streakDays',
        ],
        tintOpacity: 0.16,
      ),
    ];
  }

  Color _aqiAccent(int aqi) {
    if (aqi <= 20) return const Color(0xFF7BC67E);
    if (aqi <= 40) return const Color(0xFFA6C96A);
    if (aqi <= 60) return const Color(0xFFF1C85A);
    if (aqi <= 80) return const Color(0xFFE99A4B);
    return const Color(0xFFD9654D);
  }

  Color _shiftHue(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withHue((hsl.hue + amount) % 360).toColor();
  }

  Color _shiftLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final next = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(next).toColor();
  }

  Color _mix(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }
}
