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
          colors: [Color(0xFF153735), Color(0xFF386C63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const AspectRatio(
        aspectRatio: 1.8,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: _Orb(size: 86, color: Color(0x33FFF6D8)),
            ),
            Positioned(
              right: 24,
              top: 12,
              child: _Orb(size: 34, color: Color(0x40FFFFFF)),
            ),
            Positioned(
              right: 0,
              bottom: 6,
              child: _Orb(size: 108, color: Color(0x26F7C67D)),
            ),
            Positioned(
              left: 26,
              bottom: 20,
              child: Icon(Icons.photo_camera_rounded, color: Colors.white, size: 34),
            ),
            Positioned(
              left: 84,
              bottom: 18,
              child: Icon(Icons.wb_sunny_rounded, color: Color(0xFFFCE9AA), size: 22),
            ),
            Positioned(
              left: 118,
              bottom: 18,
              child: Icon(Icons.air_rounded, color: Color(0xD7FFFFFF), size: 22),
            ),
            Positioned(
              left: 24,
              top: 22,
              child: Text(
                'Capture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
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
