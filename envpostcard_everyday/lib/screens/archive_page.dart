import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/postcard_app_controller.dart';
import '../models/postcard_content.dart';
import 'album_detail_page.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key, required this.controller});

  final PostcardAppController controller;

  @override
  Widget build(BuildContext context) {
    final groups = _groupCards(controller.futureCards);

    return Stack(
      children: [
        const Positioned.fill(child: _AlbumBackground()),
        RefreshIndicator(
          onRefresh: controller.refreshCollections,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 136,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  title: const Text(
                    'Album',
                    style: TextStyle(
                      color: Color(0xFF173230),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: const SizedBox.shrink(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                  child: groups.isEmpty
                      ? _emptyState()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _overview(groups),
                            const SizedBox(height: 20),
                            const Text(
                              'Monthly Booklets',
                              style: TextStyle(
                                color: Color(0xFF163231),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final columns = width > 760 ? 3 : width > 500 ? 2 : 1;
                                final cardWidth = (width - (columns - 1) * 14) / columns;
                                return Wrap(
                                  spacing: 14,
                                  runSpacing: 14,
                                  children: groups.map((group) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: _BookletCard(
                                        group: group,
                                        onTap: () async {
                                          await Navigator.of(context).push(
                                            PageRouteBuilder<void>(
                                              transitionDuration: const Duration(milliseconds: 260),
                                              reverseTransitionDuration: const Duration(milliseconds: 220),
                                              pageBuilder: (context, animation, secondaryAnimation) => AlbumDetailPage(
                                                controller: controller,
                                                groupLabel: group.label,
                                                cards: group.cards,
                                              ),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                final curved = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOut,
                                                  reverseCurve: Curves.easeIn,
                                                );
                                                return FadeTransition(
                                                  opacity: curved,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_AlbumGroup> _groupCards(List<PostcardContent> cards) {
    final formatter = DateFormat('MMMM yyyy');
    final groups = <String, List<PostcardContent>>{};
    for (final card in cards) {
      final date = DateTime.tryParse(card.createdAtIso) ?? DateTime.now();
      final key = formatter.format(date);
      groups.putIfAbsent(key, () => []).add(card);
    }
    return groups.entries
        .map((entry) => _AlbumGroup(label: entry.key, cards: entry.value))
        .toList();
  }

  Widget _overview(List<_AlbumGroup> groups) {
    final totalCards = groups.fold<int>(0, (sum, group) => sum + group.cards.length);
    final latestLabel = groups.first.label;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9F3E6), Color(0xFFF1E7D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _StatPill(
            icon: Icons.menu_book_rounded,
            value: '${groups.length}',
            label: 'Booklets',
          ),
          _StatPill(
            icon: Icons.photo_library_rounded,
            value: '$totalCards',
            label: 'Postcards',
          ),
          _StatPill(
            icon: Icons.schedule_rounded,
            value: latestLabel,
            label: 'Latest',
            wide: true,
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
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
}

class _BookletCard extends StatelessWidget {
  const _BookletCard({
    required this.group,
    required this.onTap,
  });

  final _AlbumGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFF7F1E1), Color(0xFFEEE5D3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 10,
              bottom: 10,
              child: Container(
                width: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4B37E),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 1.02,
                      child: _CoverCollage(cards: group.cards),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    group.label,
                    style: const TextStyle(
                      color: Color(0xFF183231),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${group.cards.length} postcards',
                    style: const TextStyle(
                      color: Color(0xFF657B76),
                      fontWeight: FontWeight.w700,
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
}

class _CoverCollage extends StatelessWidget {
  const _CoverCollage({required this.cards});

  final List<PostcardContent> cards;

  @override
  Widget build(BuildContext context) {
    final preview = cards.take(4).toList();
    if (preview.length == 1) {
      return _image(preview.first);
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: preview.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) => _image(preview[index]),
    );
  }

  Widget _image(PostcardContent card) {
    final path = card.renderedImagePath.isNotEmpty ? card.renderedImagePath : card.imagePath;
    return Image.file(
      File(path),
      fit: BoxFit.cover,
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    this.wide = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: wide ? 180 : 132,
        maxWidth: wide ? 220 : 150,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF4E7CF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF173230)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF60726E),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF173230),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumBackground extends StatelessWidget {
  const _AlbumBackground();

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
      child: Stack(
        children: [
          Positioned(top: -24, right: -24, child: _blob(160, const Color(0x28D7B685))),
          Positioned(top: 240, left: -34, child: _blob(120, const Color(0x22B2CDD3))),
          Positioned(bottom: 110, right: -18, child: _blob(140, const Color(0x22D8A38B))),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AlbumGroup {
  const _AlbumGroup({
    required this.label,
    required this.cards,
  });

  final String label;
  final List<PostcardContent> cards;
}
