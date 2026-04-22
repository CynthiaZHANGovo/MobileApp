import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/postcard_app_controller.dart';

class CapturePage extends StatelessWidget {
  const CapturePage({
    super.key,
    required this.controller,
    required this.onGenerated,
  });

  final PostcardAppController controller;
  final VoidCallback onGenerated;

  @override
  Widget build(BuildContext context) {
    final image = controller.selectedImage;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      children: [
        _heroCard(),
        const SizedBox(height: 18),
        _previewPanel(image?.path),
        if (controller.errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorText!,
            style: const TextStyle(color: Color(0xFFB44F38)),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.gallery),
                icon: const Icon(Icons.collections_outlined),
                label: const Text('From Gallery'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: controller.isGenerating
              ? null
              : () async {
                  final success = await controller.generatePostcard();
                  if (success) {
                    onGenerated();
                  }
                },
          icon: controller.isGenerating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(
            controller.isGenerating ? 'Generating...' : 'Generate Postcard',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1E5751),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF4E9D5), Color(0xFFE9E1D3), Color(0xFFDDE5DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.26,
        child: Stack(
          children: [
            Positioned(
              left: -10,
              top: 20,
              child: _Orb(size: 82, color: Color(0x24F4CB8E)),
            ),
            Positioned(
              right: 6,
              bottom: 10,
              child: _Orb(size: 96, color: Color(0x22BDD8E1)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      _HeroAccentIcon(
                        icon: Icons.wb_sunny_rounded,
                        background: Color(0xFFF6E1A7),
                        foreground: Color(0xFFBA7C1F),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Capture',
                        style: TextStyle(
                          color: Color(0xFF173230),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 10),
                      _HeroAccentIcon(
                        icon: Icons.photo_camera_outlined,
                        background: Color(0xFFDCE8E4),
                        foreground: Color(0xFF46655F),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFC6D7D4),
                            Color(0xFFB5CAC6),
                            Color(0xFFBFD4D8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 20,
                            top: 16,
                            child: _Orb(size: 70, color: Color(0x2EFFF8E9)),
                          ),
                          const Positioned(
                            right: 16,
                            bottom: 18,
                            child: _Orb(size: 88, color: Color(0x26FFF5DA)),
                          ),
                          const Positioned(
                            right: 28,
                            top: 28,
                            child: _Orb(size: 34, color: Color(0x34FFFFFF)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0x3DFFFFFF),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  width: 1.2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    top: 16,
                                    child: Row(
                                      children: List.generate(10, (index) {
                                        final color = index.isEven
                                            ? const Color(0xFFD96A60)
                                            : const Color(0xFF6D9AB7);
                                        return Expanded(
                                          child: Container(
                                            height: 4,
                                            color: color,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 38,
                                          color: Color(0xFF4E6762),
                                        ),
                                        SizedBox(height: 12),
                                        _FrameHintLine(width: 130),
                                        SizedBox(height: 8),
                                        _FrameHintLine(width: 88),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewPanel(String? imagePath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photo Input',
            style: TextStyle(
              color: Color(0xFF163231),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: imagePath == null
                  ? Container(
                      color: const Color(0xFFEBE1CA),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 34,
                        color: Color(0xFF5D716D),
                      ),
                    )
                  : Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeroAccentIcon extends StatelessWidget {
  const _HeroAccentIcon({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: foreground, size: 18),
    );
  }
}

class _FrameHintLine extends StatelessWidget {
  const _FrameHintLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0x40FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
