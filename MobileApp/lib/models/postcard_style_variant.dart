import 'package:flutter/material.dart';

class PostcardStyleVariant {
  const PostcardStyleVariant({
    required this.name,
    required this.tagline,
    required this.layout,
    required this.frameColor,
    required this.tintColor,
    required this.accentColor,
    required this.textPanelColor,
    required this.stampLabel,
    required this.stickerLabels,
    required this.tintOpacity,
  });

  final String name;
  final String tagline;
  final String layout;
  final Color frameColor;
  final Color tintColor;
  final Color accentColor;
  final Color textPanelColor;
  final String stampLabel;
  final List<String> stickerLabels;
  final double tintOpacity;
}
