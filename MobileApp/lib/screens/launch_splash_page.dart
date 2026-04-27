import 'dart:async';

import 'package:flutter/material.dart';

double _safeUnit(double value) {
  if (!value.isFinite || value.isNaN) return 0;
  return value.clamp(0.0, 1.0).toDouble();
}

class LaunchSplashPage extends StatefulWidget {
  const LaunchSplashPage({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<LaunchSplashPage> createState() => _LaunchSplashPageState();
}

class _LaunchSplashPageState extends State<LaunchSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..forward();

  Timer? _finishTimer;

  @override
  void initState() {
    super.initState();
    _finishTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3E9D2), Color(0xFFE8E3D6), Color(0xFFDCE4DA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = Curves.easeOutCubic.transform(_controller.value);
            final tapeOpacity = _safeUnit(
              Curves.easeOut.transform(((progress - 0.24) / 0.76).clamp(0, 1)),
            );
            final detailOpacity = _safeUnit(
              Curves.easeOut.transform(((progress - 0.48) / 0.52).clamp(0, 1)),
            );
            final captureOpacity = _safeUnit(
              Curves.easeOut.transform(((progress - 0.14) / 0.30).clamp(0, 1)),
            );
            final infoOpacity = _safeUnit(
              Curves.easeOut.transform(((progress - 0.42) / 0.36).clamp(0, 1)),
            );
            final decorateOpacity = _safeUnit(
              Curves.easeOutBack.transform(((progress - 0.66) / 0.34).clamp(0, 1)),
            );

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF4E8D5),
                              Color(0xFFEAE0D1),
                              Color(0xFFE1E6DB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -8,
                      top: 24,
                      child: _GlowBlob(
                        size: 88,
                        color: const Color(0x25F6C57B),
                        opacity: detailOpacity,
                      ),
                    ),
                    Positioned(
                      right: -14,
                      bottom: 12,
                      child: _GlowBlob(
                        size: 110,
                        color: const Color(0x22BFD7E3),
                        opacity: detailOpacity,
                      ),
                    ),
                    Positioned(
                      left: 26,
                      top: 36,
                      child: Transform.scale(
                        scale: 0.92 + detailOpacity * 0.08,
                        child: _DeskCircle(
                          size: 58,
                          color: const Color(0xFFF3CE87),
                          icon: Icons.wb_sunny_rounded,
                          iconColor: const Color(0xFFAA7324),
                          visibility: detailOpacity,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 38,
                      child: Transform.scale(
                        scale: 0.92 + detailOpacity * 0.08,
                        child: Transform.rotate(
                          angle: 0.12,
                          child: _DeskChip(
                            width: 70,
                            height: 40,
                            color: const Color(0xFFE5EEE7),
                            icon: Icons.air_rounded,
                            iconColor: const Color(0xFF56736C),
                            visibility: detailOpacity,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: Transform.scale(
                        scale: 0.92 + detailOpacity * 0.08,
                        child: Transform.rotate(
                          angle: -0.14,
                          child: _DeskCircle(
                            size: 62,
                            color: const Color(0xFFF2D7CD),
                            icon: Icons.auto_awesome_rounded,
                            iconColor: const Color(0xFFC16E62),
                            visibility: detailOpacity,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Transform.translate(
                        offset: Offset(0, (1 - progress) * 58),
                        child: Transform.rotate(
                          angle: -0.04,
                          child: Transform.scale(
                            scale: 0.88 + progress * 0.12,
                            child: SizedBox(
                              width: 278,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _SplashPostcard(
                                    captureOpacity: captureOpacity,
                                    infoOpacity: infoOpacity,
                                    decorateOpacity: decorateOpacity,
                                  ),
                                  Positioned(
                                    left: 22,
                                    top: -10,
                                    child: Transform.rotate(
                                      angle: -0.20,
                                      child: _TapeStrip(
                                        width: 72,
                                        visibility: tapeOpacity,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 18,
                                    top: -8,
                                    child: Transform.rotate(
                                      angle: 0.16,
                                      child: _TapeStrip(
                                        width: 54,
                                        visibility: tapeOpacity,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}

class _SplashPostcard extends StatelessWidget {
  const _SplashPostcard({
    required this.captureOpacity,
    required this.infoOpacity,
    required this.decorateOpacity,
  });

  final double captureOpacity;
  final double infoOpacity;
  final double decorateOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F4EA),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(12, (index) {
              final color = index.isEven ? const Color(0xFFD65C54) : const Color(0xFF5A92B7);
              return Expanded(child: Container(height: 5, color: color));
            }),
          ),
          const SizedBox(height: 16),
          Container(
            height: 188,
            decoration: BoxDecoration(
              color: const Color(0xFFEBE1CE),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.62), width: 1.3),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEFE5D2),
                        const Color(0xFFE6DAC5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: 0.94 + captureOpacity * 0.06,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20 + captureOpacity * 0.46),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.photo_camera_rounded,
                              size: 28,
                              color: const Color(0xFF6F7E78)
                                  .withValues(alpha: 0.08 + captureOpacity * 0.92),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 90,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCD1BD)
                                  .withValues(alpha: 0.12 + captureOpacity * 0.88),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Transform.scale(
                    scale: 0.94 + infoOpacity * 0.06,
                    child: _MiniInfoPill(
                      icon: Icons.wb_sunny_rounded,
                      label: 'Weather',
                      background: const Color(0xFFF3E0AE),
                      foreground: const Color(0xFF9A6A21),
                      visibility: infoOpacity,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 18,
                  child: Transform.scale(
                    scale: 0.94 + infoOpacity * 0.06,
                    child: _MiniInfoPill(
                      icon: Icons.air_rounded,
                      label: 'Air',
                      background: const Color(0xFFE3EEE9),
                      foreground: const Color(0xFF4E7269),
                      visibility: infoOpacity,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  child: Transform.scale(
                    scale: 0.94 + infoOpacity * 0.06,
                    child: _MiniInfoPill(
                      icon: Icons.place_rounded,
                      label: 'Place',
                      background: const Color(0xFFF4DDD3),
                      foreground: const Color(0xFFB56D5B),
                      visibility: infoOpacity,
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 16,
                  child: Transform.scale(
                    scale: 0.90 + decorateOpacity * 0.10,
                    child: Transform.rotate(
                      angle: 0.12,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8E5C2)
                              .withValues(alpha: 0.10 + decorateOpacity * 0.90),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x10000000)
                                  .withValues(alpha: decorateOpacity),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: const Color(0xFFC98736)
                              .withValues(alpha: 0.08 + decorateOpacity * 0.92),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _NoteLine(widthFactor: 0.86),
          const SizedBox(height: 10),
          const _NoteLine(widthFactor: 0.62),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(child: _NoteLine(widthFactor: 1)),
              const SizedBox(width: 12),
              Transform.rotate(
                angle: 0.10,
                child: const _DeskChip(
                  width: 48,
                  height: 48,
                  color: Color(0xFFF0DFC3),
                  icon: Icons.place_rounded,
                  iconColor: Color(0xFFBC745C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TapeStrip extends StatelessWidget {
  const _TapeStrip({
    required this.width,
    required this.visibility,
  });

  final double width;
  final double visibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E6).withValues(alpha: 0.08 + visibility * 0.25),
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}

class _DeskCircle extends StatelessWidget {
  const _DeskCircle({
    required this.size,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.visibility,
  });

  final double size;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double visibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.42,
        color: iconColor.withValues(alpha: 0.08 + visibility * 0.92),
      ),
    );
  }
}

class _DeskChip extends StatelessWidget {
  const _DeskChip({
    required this.width,
    required this.height,
    required this.color,
    required this.icon,
    required this.iconColor,
    this.visibility = 1,
  });

  final double width;
  final double height;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double visibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 20,
        color: iconColor.withValues(alpha: 0.08 + visibility * 0.92),
      ),
    );
  }
}

class _MiniInfoPill extends StatelessWidget {
  const _MiniInfoPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.visibility,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final double visibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.10 + visibility * 0.90),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: foreground.withValues(alpha: 0.08 + visibility * 0.92),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground.withValues(alpha: 0.08 + visibility * 0.92),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity * 0.15),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFFE6DAC7),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
