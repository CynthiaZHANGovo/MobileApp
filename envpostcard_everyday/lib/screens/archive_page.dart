import 'dart:io';

import 'package:flutter/material.dart';

import '../controllers/postcard_app_controller.dart';
import '../models/postcard_content.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key, required this.controller});

  final PostcardAppController controller;

  @override
  Widget build(BuildContext context) {
    final cards = controller.futureCards;

    return RefreshIndicator(
      onRefresh: controller.refreshCollections,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          const Text(
            'Album',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF163231),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A personal album of postcards mailed to your future self. Flip through recent memories and keep the small weather traces together.',
            style: TextStyle(
              color: Color(0xFF617774),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          if (cards.isEmpty) _emptyState() else ...[
            _albumShelf(cards),
            const SizedBox(height: 18),
            _memoryGrid(cards),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Text(
        'Nothing saved yet. Build a postcard in Studio and save it to start your album.',
        style: TextStyle(
          color: Color(0xFF617774),
          height: 1.55,
        ),
      ),
    );
  }

  Widget _albumShelf(List<PostcardContent> cards) {
    return SizedBox(
      height: 420,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.86),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3E6),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 10,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(card.imagePath),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(top: 14, left: 14, child: _tape()),
                        Positioned(top: 14, right: 14, child: _albumBadge(card.styleName)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.message,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF183231),
                              height: 1.55,
                              fontSize: 14.5,
                            ),
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: card.stickerLabels.take(3).map(_albumBadge).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _memoryGrid(List<PostcardContent> cards) {
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
            'Memory Grid',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF163231),
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F4E8),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(card.imagePath),
                            height: 138,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(top: 10, left: 10, child: _tape()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card.styleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A4A44),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        card.message,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF183231),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _albumBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
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

  Widget _tape() {
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        width: 34,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xBEEADDB8),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
