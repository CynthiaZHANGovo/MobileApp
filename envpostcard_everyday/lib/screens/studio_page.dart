import 'package:flutter/material.dart';

import '../controllers/postcard_app_controller.dart';
import '../models/postcard_content.dart';
import '../models/postcard_style_variant.dart';
import '../widgets/postcard_preview.dart';

class StudioPage extends StatelessWidget {
  const StudioPage({super.key, required this.controller});

  final PostcardAppController controller;

  @override
  Widget build(BuildContext context) {
    final card = controller.previewCard;
    final variant = controller.selectedVariant;

    if (card == null || variant == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Studio',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF163231),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Generate a postcard first. This page will show multiple visual treatments, filter-based image styling, and data-driven stickers you can choose from.',
                  style: TextStyle(
                    color: Color(0xFF637875),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      children: [
        _header(variant),
        const SizedBox(height: 18),
        PostcardPreview(card: card, variant: variant),
        const SizedBox(height: 18),
        _variantPicker(),
        const SizedBox(height: 18),
        _contextGrid(card),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  final message = await controller.saveForFutureSelf();
                  if (context.mounted && message != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
                child: const Text('Save to Future Self'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  final message = await controller.publishToBoard();
                  if (context.mounted && message != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE0AA4A),
                  foregroundColor: const Color(0xFF18312F),
                ),
                child: const Text('Publish to Post Office'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.shareCurrentCard,
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share Card'),
        ),
      ],
    );
  }

  Widget _header(PostcardStyleVariant variant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Studio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF173230),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Current treatment: ${variant.name}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: variant.accentColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            variant.tagline,
            style: const TextStyle(
              color: Color(0xFF617773),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _variantPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Generated Looks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF163231),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 136,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.variants.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = controller.variants[index];
              final selected = index == controller.selectedVariantIndex;
              return GestureDetector(
                onTap: () => controller.selectVariant(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 188,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.frameColor, item.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF18312F)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Color(0xFF132826),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.tagline,
                        style: const TextStyle(
                          color: Color(0xCC132826),
                          height: 1.45,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        selected ? 'Selected' : 'Tap to preview',
                        style: const TextStyle(
                          color: Color(0xFF132826),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _contextGrid(PostcardContent card) {
    final items = [
      ('Location', card.locationLabel),
      ('Weather', card.weatherLabel),
      ('Air', card.aqiLabel),
      ('Streak', 'Day ${card.streakDays}'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.$1.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF6E847F),
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                item.$2,
                style: const TextStyle(
                  color: Color(0xFF173230),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
