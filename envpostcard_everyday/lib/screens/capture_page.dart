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
        const SizedBox(height: 22),
        _journeyCard(),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF153735), Color(0xFF386C63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CaptureEyebrow(label: 'Capture'),
          SizedBox(height: 12),
          Text(
            'Capture today on purpose.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Start with a photo of what you actively noticed. The app will merge your image, live weather, air quality, and time into a shareable environmental postcard.',
            style: TextStyle(color: Color(0xD8FFFFFF), height: 1.55),
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          'No image yet. Take one photo that says something about the environment around you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF5D716D),
                            fontSize: 17,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  : Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeyCard() {
    final items = [
      ('Photo', Icons.photo_camera_outlined),
      ('AI Mix', Icons.auto_awesome_outlined),
      ('Studio', Icons.edit_outlined),
      ('Album', Icons.collections_bookmark_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Postcard Journey',
            style: TextStyle(
              color: Color(0xFF183231),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? const Color(0xFF1E5751)
                                  : const Color(0xFFECE3CF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item.$2,
                              color: index == 0 ? Colors.white : const Color(0xFF52706A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.$1,
                            style: const TextStyle(
                              color: Color(0xFF526764),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < items.length - 1)
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 22),
                          child: Divider(
                            thickness: 1.2,
                            color: Color(0xFFD9CFBC),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CaptureEyebrow extends StatelessWidget {
  const _CaptureEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
