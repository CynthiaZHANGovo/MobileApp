import 'dart:io';

import 'package:flutter/material.dart';

import '../models/postcard_content.dart';
import '../models/postcard_style_variant.dart';

class PostcardPreview extends StatelessWidget {
  const PostcardPreview({
    super.key,
    required this.card,
    required this.variant,
  });

  final PostcardContent card;
  final PostcardStyleVariant variant;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.78,
      child: Container(
        padding: EdgeInsets.all(variant.layout == 'border' ? 18 : 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [variant.frameColor, variant.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: switch (variant.layout) {
          'grid' => _buildGridLayout(),
          'border' => _buildBorderLayout(),
          _ => _buildFloatingLayout(),
        },
      ),
    );
  }

  Widget _buildFloatingLayout() {
    return Stack(
      children: [
        _buildFilteredPhoto(borderRadius: 24),
        Positioned(top: 16, right: 16, child: _stamp(rotation: 0.08)),
        Positioned(
          left: 14,
          right: 14,
          bottom: 14,
          child: _messagePanel(compact: false),
        ),
        Positioned(left: 18, top: 18, child: _stickerColumn(limit: 2)),
      ],
    );
  }

  Widget _buildGridLayout() {
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: Stack(
            children: [
              _buildFilteredPhoto(borderRadius: 22),
              Positioned(left: 14, top: 14, child: _stamp(rotation: -0.06)),
              Positioned(right: 14, top: 14, child: _miniBadge(card.weatherLabel)),
              Positioned(right: 14, bottom: 14, child: _miniBadge(card.temperatureText)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 7,
          child: Row(
            children: [
              Expanded(child: _messagePanel(compact: true)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _infoTile('AQI', card.aqiLabel)),
                    const SizedBox(height: 10),
                    Expanded(child: _infoTile('Location', card.locationLabel)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBorderLayout() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Stack(
              children: [
                _buildFilteredPhoto(borderRadius: 18),
                Positioned(left: 12, top: 12, child: _miniBadge(variant.stampLabel)),
                Positioned(right: 12, bottom: 12, child: _stickerColumn(limit: 3)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: variant.textPanelColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18312F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      card.message,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: Color(0xFF18312F),
                      ),
                    ),
                  ),
                  Text(
                    '${card.locationLabel}  •  ${card.temperatureText}',
                    style: const TextStyle(color: Color(0xFF5C716D)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredPhoto({required double borderRadius}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              variant.tintColor.withValues(alpha: variant.tintOpacity),
              BlendMode.softLight,
            ),
            child: Image.file(File(card.imagePath), fit: BoxFit.cover),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.08),
                  variant.frameColor.withValues(alpha: 0.18),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messagePanel({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: variant.textPanelColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            variant.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF162D2A),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              card.message,
              maxLines: compact ? 7 : 8,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 13.5 : 15.5,
                height: 1.55,
                color: const Color(0xFF142725),
                fontWeight: compact ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: card.stickerLabels.take(compact ? 2 : 3).map(_miniBadge).toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: variant.textPanelColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              color: variant.accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF173230),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stamp({required double rotation}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: variant.accentColor.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          variant.stampLabel,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF102523),
          ),
        ),
      ),
    );
  }

  Widget _stickerColumn({required int limit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variant.stickerLabels.take(limit).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _miniBadge(item),
        );
      }).toList(),
    );
  }

  Widget _miniBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF173432),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
