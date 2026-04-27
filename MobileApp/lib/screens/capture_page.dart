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
    return SizedBox(
      height: 208,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 4,
            top: 12,
            child: _Orb(size: 64, color: Color(0x22F2C86B)),
          ),
          const Positioned(
            right: 20,
            top: 26,
            child: _Orb(size: 26, color: Color(0x20FFF8DF)),
          ),
          const Positioned(
            right: -8,
            bottom: 34,
            child: _Orb(size: 72, color: Color(0x20A6D0DB)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF83BDD5),
                    Color(0xFFE4C668),
                    Color(0xFFF0E0AF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 28,
                    top: 18,
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x32FFFFFF),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 78,
                    top: 26,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 28,
                    top: 24,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x30FFF3C2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 114,
                    bottom: 40,
                    child: Transform.rotate(
                      angle: -0.26,
                      child: Container(
                        width: 78,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                  ),
                  Positioned(
                    left: 164,
                    bottom: 10,
                    child: Container(
                      width: 142,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.50),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 212,
                    bottom: 30,
                    child: Container(
                      width: 94,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
