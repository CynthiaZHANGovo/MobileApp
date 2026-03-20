import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PhotoPalette {
  const PhotoPalette({
    required this.primary,
    required this.secondary,
    required this.moodLabel,
    required this.colorStory,
  });

  final Color primary;
  final Color secondary;
  final String moodLabel;
  final String colorStory;
}

class PhotoPaletteService {
  Future<PhotoPalette> analyze(String imagePath) async {
    final palette = await PaletteGenerator.fromImageProvider(
      FileImage(File(imagePath)),
      size: const Size(300, 300),
    );

    final primary =
        palette.dominantColor?.color ??
        palette.vibrantColor?.color ??
        const Color(0xFF5D7862);
    final secondary =
        palette.lightVibrantColor?.color ??
        palette.mutedColor?.color ??
        const Color(0xFFE8D7AD);

    final luminance = primary.computeLuminance();
    final moodLabel = luminance > 0.58 ? 'Bright and open' : 'Quiet and inward';

    return PhotoPalette(
      primary: primary,
      secondary: secondary,
      moodLabel: moodLabel,
      colorStory: '${_nameColor(primary)} layered with ${_nameColor(secondary)}',
    );
  }

  String _nameColor(Color color) {
    final red = _channel(color.r);
    final green = _channel(color.g);
    final blue = _channel(color.b);

    if (red > 180 && green > 160 && blue < 140) {
      return 'amber';
    }
    if (green > 140 && red < 140) {
      return 'leaf green';
    }
    if (blue > 150 && red < 130) {
      return 'sky blue';
    }
    if (red > 150 && blue > 120) {
      return 'twilight plum';
    }
    if (red > 150 && green > 110 && blue > 110) {
      return 'warm rose';
    }
    return 'soft earth';
  }

  int _channel(double value) => (value * 255).round().clamp(0, 255);
}
