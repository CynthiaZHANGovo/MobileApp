import 'dart:io';

import 'package:flutter/material.dart';

import '../controllers/postcard_app_controller.dart';
import '../models/postcard_content.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key, required this.controller});

  final PostcardAppController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshCollections,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        children: [
          const Text(
            'Archive',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF163231),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Saved postcards live here. Future Self keeps private memories. Post Office shows what you pushed into circulation.',
            style: TextStyle(
              color: Color(0xFF617774),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          _section(
            title: 'Future Self',
            emptyText: 'Nothing saved yet.',
            cards: controller.futureCards,
          ),
          const SizedBox(height: 18),
          _section(
            title: 'Post Office',
            emptyText: 'Nothing published yet.',
            cards: controller.boardCards,
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required String emptyText,
    required List<PostcardContent> cards,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF163231),
            ),
          ),
          const SizedBox(height: 12),
          if (cards.isEmpty)
            Text(
              emptyText,
              style: const TextStyle(color: Color(0xFF667C78)),
            )
          else
            ...cards.map(_cardTile),
        ],
      ),
    );
  }

  Widget _cardTile(PostcardContent card) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(card.imagePath),
              width: 84,
              height: 84,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.styleName,
                  style: const TextStyle(
                    color: Color(0xFF1A4A44),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF183231),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: card.stickerLabels.take(3).map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF516865),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
