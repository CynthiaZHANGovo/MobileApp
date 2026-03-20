import 'dart:math';
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
        padding: EdgeInsets.all(variant.layout == 'polaroid' ? 12 : 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [variant.frameColor, variant.accentColor.withValues(alpha: 0.92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 26,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            Positioned(left: 12, right: 12, top: 10, child: _airmailEdge()),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: switch (variant.layout) {
                'grid' => _buildGridLayout(),
                'border' => _buildBorderLayout(),
                'split' => _buildSplitLayout(),
                'polaroid' => _buildPolaroidLayout(),
                _ => _buildFloatingLayout(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLayout() {
    return Stack(
      children: [
        _buildFilteredPhoto(borderRadius: 24),
        Positioned(top: 18, right: 18, child: _stamp(rotation: 0.08)),
        Positioned(top: 18, left: 18, child: _weatherIllustration()),
        Positioned(left: 14, right: 14, bottom: 14, child: _messagePanel(compact: false)),
        Positioned(right: 18, top: 124, child: _stickerColumn(limit: 2)),
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
              Positioned(right: 14, top: 14, child: _weatherIllustration(compact: true)),
              Positioned(left: 14, bottom: 14, child: _miniBadge(card.temperatureText)),
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
                    Expanded(child: _infoTile('AIR', card.aqiLabel)),
                    const SizedBox(height: 10),
                    Expanded(child: _infoTile('PLACE', card.locationLabel)),
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
                Positioned(right: 12, top: 12, child: _weatherIllustration(compact: true)),
                Positioned(right: 12, bottom: 12, child: _stickerColumn(limit: 2)),
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
                  Row(
                    children: [
                      Text(
                        variant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF18312F),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Future Self',
                        style: TextStyle(
                          color: variant.accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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

  Widget _buildSplitLayout() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: Stack(
              children: [
                _buildFilteredPhoto(borderRadius: 18),
                Positioned(left: 12, top: 12, child: _weatherIllustration(compact: true)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      variant.name,
                      style: TextStyle(
                        color: variant.accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    _miniBadge(variant.stampLabel),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: variant.textPanelColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      card.message,
                      style: const TextStyle(
                        color: Color(0xFF173230),
                        height: 1.65,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFFD9CFBC)),
                const SizedBox(height: 12),
                Text(
                  'To: Future Me',
                  style: TextStyle(
                    color: variant.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.locationLabel,
                  style: const TextStyle(color: Color(0xFF536966)),
                ),
                const SizedBox(height: 6),
                Text(
                  '${card.weatherLabel} • ${card.temperatureText}',
                  style: const TextStyle(color: Color(0xFF536966)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidLayout() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EB),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Stack(
              children: [
                _buildFilteredPhoto(borderRadius: 16),
                Positioned(left: 12, top: 12, child: _stamp(rotation: -0.05)),
                Positioned(right: 12, top: 12, child: _weatherIllustration(compact: true)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: variant.textPanelColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.message,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF173230),
                      height: 1.55,
                      fontSize: 14.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      ...card.stickerLabels.take(2).map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _miniBadge(item),
                        );
                      }),
                      const Spacer(),
                      Text(
                        'Environmental Postcard',
                        style: TextStyle(
                          color: variant.accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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
          Row(
            children: [
              Text(
                variant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF162D2A),
                ),
              ),
              const Spacer(),
              Text(
                'POSTCARD',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  color: variant.accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
            title,
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

  Widget _airmailEdge() {
    return SizedBox(
      height: 6,
      child: Row(
        children: List.generate(12, (index) {
          final color = index.isEven ? const Color(0xFFD85D55) : const Color(0xFF4E8EB8);
          return Expanded(child: Container(color: color));
        }),
      ),
    );
  }

  Widget _weatherIllustration({bool compact = false}) {
    final size = compact ? 74.0 : 96.0;
    final background = Colors.white.withValues(alpha: compact ? 0.70 : 0.78);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(compact ? 18 : 24),
      ),
      child: CustomPaint(
        painter: _WeatherPainter(
          weatherLabel: card.weatherLabel,
          accent: variant.accentColor,
          ink: const Color(0xFF173432),
        ),
      ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  const _WeatherPainter({
    required this.weatherLabel,
    required this.accent,
    required this.ink,
  });

  final String weatherLabel;
  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final sunPaint = Paint()..color = accent.withValues(alpha: 0.9);
    final softPaint = Paint()..color = accent.withValues(alpha: 0.22);
    final inkPaint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.035;

    canvas.drawCircle(center, size.width * 0.19, softPaint);

    if (weatherLabel == 'Clear sky') {
      canvas.drawCircle(center, size.width * 0.14, sunPaint);
      for (var i = 0; i < 8; i++) {
        final angle = i * 0.78;
        final inner = Offset(
          center.dx + size.width * 0.20 * cos(angle),
          center.dy + size.width * 0.20 * sin(angle),
        );
        final outer = Offset(
          center.dx + size.width * 0.31 * cos(angle),
          center.dy + size.width * 0.31 * sin(angle),
        );
        canvas.drawLine(inner, outer, inkPaint);
      }
      return;
    }

    final cloudPath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.42, size.width * 0.34, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.26, size.width * 0.50, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.58, size.height * 0.20, size.width * 0.68, size.height * 0.34)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.34, size.width * 0.80, size.height * 0.54)
      ..close();
    canvas.drawPath(cloudPath, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawPath(cloudPath, inkPaint);

    if (weatherLabel == 'Soft clouds' || weatherLabel == 'Overcast' || weatherLabel == 'Fog') {
      if (weatherLabel == 'Fog') {
        for (var i = 0; i < 3; i++) {
          final y = size.height * (0.68 + i * 0.08);
          canvas.drawLine(Offset(size.width * 0.25, y), Offset(size.width * 0.75, y), inkPaint);
        }
      }
      return;
    }

    if (weatherLabel == 'Light rain' || weatherLabel == 'Passing showers') {
      for (var i = 0; i < 4; i++) {
        final x = size.width * (0.34 + i * 0.11);
        canvas.drawLine(
          Offset(x, size.height * 0.68),
          Offset(x - size.width * 0.04, size.height * 0.82),
          inkPaint,
        );
      }
      return;
    }

    if (weatherLabel == 'Snowfall') {
      for (var i = 0; i < 3; i++) {
        final x = size.width * (0.38 + i * 0.12);
        final y = size.height * 0.75;
        canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), inkPaint);
        canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), inkPaint);
      }
      return;
    }

    if (weatherLabel == 'Thunder') {
      final bolt = Path()
        ..moveTo(size.width * 0.50, size.height * 0.56)
        ..lineTo(size.width * 0.42, size.height * 0.78)
        ..lineTo(size.width * 0.50, size.height * 0.78)
        ..lineTo(size.width * 0.44, size.height * 0.94)
        ..lineTo(size.width * 0.62, size.height * 0.68)
        ..lineTo(size.width * 0.54, size.height * 0.68)
        ..close();
      canvas.drawPath(bolt, Paint()..color = accent.withValues(alpha: 0.92));
      canvas.drawPath(bolt, inkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherPainter oldDelegate) {
    return oldDelegate.weatherLabel != weatherLabel ||
        oldDelegate.accent != accent ||
        oldDelegate.ink != ink;
  }
}
