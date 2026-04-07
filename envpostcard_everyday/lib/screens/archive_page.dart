import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/postcard_app_controller.dart';
import '../models/postcard_content.dart';
import 'album_detail_page.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key, required this.controller});

  final PostcardAppController controller;

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  late final PageController _pageController;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.84)
      ..addListener(() {
        if (!mounted) return;
        setState(() {
          _page = _pageController.hasClients ? (_pageController.page ?? 0) : 0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.controller.futureCards;

    return Stack(
      children: [
        const Positioned.fill(child: _AlbumBackground()),
        RefreshIndicator(
          onRefresh: widget.controller.refreshCollections,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 168,
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
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 86, 20, 24),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _HeaderChip(label: 'Saved postcards'),
                          _HeaderChip(label: 'Scrapbook archive'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                  child: cards.isEmpty
                      ? _emptyState()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _statsBar(cards),
                            const SizedBox(height: 20),
                            _sectionTitle('Featured'),
                            const SizedBox(height: 12),
                            _featuredCarousel(cards),
                            const SizedBox(height: 14),
                            _pageDots(cards.length),
                            const SizedBox(height: 20),
                            _sectionTitle('Archive Board'),
                            const SizedBox(height: 12),
                            _masonryBoard(cards),
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

  Widget _emptyState() {
    return _surface(
      padding: const EdgeInsets.all(24),
      child: const Text(
        'Nothing saved yet. Build a postcard in Studio and save it to start your album.',
        style: TextStyle(
          color: Color(0xFF617774),
          height: 1.55,
        ),
      ),
    );
  }

  Widget _statsBar(List<PostcardContent> cards) {
    final styles = cards.map((item) => item.styleName).toSet().length;
    final streakMax = cards.fold<int>(0, (value, card) => math.max(value, card.streakDays));
    final latest = DateTime.tryParse(cards.first.createdAtIso);
    final tiles = [
      _statTile('${cards.length}', 'Cards'),
      _statTile('$styles', 'Themes'),
      _statTile('$streakMax', 'Best Streak'),
      if (latest != null) _statTile(DateFormat('MMM d').format(latest), 'Latest'),
    ];

    return _surface(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 560;
          if (wide) {
            return Row(
              children: List.generate(tiles.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == tiles.length - 1 ? 0 : 10),
                    child: tiles[index],
                  ),
                );
              }),
            );
          }

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tiles.map((tile) {
              return SizedBox(
                width: (constraints.maxWidth - 10) / 2,
                child: tile,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3E6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF173230),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF60726E),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF163231),
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _featuredCarousel(List<PostcardContent> cards) {
    return SizedBox(
      height: 420,
      child: PageView.builder(
        controller: _pageController,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          final delta = index - _page;
          final scale = 1 - (delta.abs().clamp(0.0, 1.0) * 0.05);
          return Transform.scale(
            scale: scale,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _featuredCard(card, index),
            ),
          );
        },
      ),
    );
  }

  Widget _featuredCard(PostcardContent card, int index) {
    final imagePath = card.renderedImagePath.isNotEmpty ? card.renderedImagePath : card.imagePath;
    final heroTag = 'featured-$imagePath-$index';

    return GestureDetector(
      onTap: () => _openDetail(card, heroTag),
      child: _surface(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _badge(card.styleName),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _badge(_formatDate(card.createdAtIso)),
                  ),
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
                  color: const Color(0xFFF8F3E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.message,
                      maxLines: 4,
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
                      children: [
                        _badge(card.locationLabel),
                        _badge(card.weatherLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageDots(int count) {
    if (count <= 1) return const SizedBox.shrink();
    final current = _page.round().clamp(0, count - 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = current == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1E5751) : const Color(0xFFD7D0C0),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  Widget _masonryBoard(List<PostcardContent> cards) {
    return _surface(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth > 560;
          if (!twoColumns) {
            return Column(
              children: List.generate(cards.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == cards.length - 1 ? 0 : 12),
                  child: _memoryCard(cards[index], index, compact: false),
                );
              }),
            );
          }

          final left = <PostcardContent>[];
          final right = <PostcardContent>[];
          for (var i = 0; i < cards.length; i++) {
            (i.isEven ? left : right).add(cards[i]);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: List.generate(left.length, (index) {
                    final card = left[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == left.length - 1 ? 0 : 12),
                      child: _memoryCard(card, index * 2, compact: true),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: List.generate(right.length, (index) {
                    final card = right[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == right.length - 1 ? 0 : 12),
                      child: _memoryCard(card, index * 2 + 1, compact: true),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _memoryCard(PostcardContent card, int index, {required bool compact}) {
    final imagePath = card.renderedImagePath.isNotEmpty ? card.renderedImagePath : card.imagePath;
    final heroTag = 'memory-$imagePath-$index';
    final angle = compact ? (index.isEven ? -0.012 : 0.012) : 0.0;
    final imageHeight = compact ? (index.isEven ? 150.0 : 190.0) : 220.0;

    return Transform.rotate(
      angle: angle,
      child: GestureDetector(
        onTap: () => _openDetail(card, heroTag),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: index.isEven ? const Color(0xFFF9F4E8) : const Color(0xFFF4EFE3),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(imagePath),
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.styleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A4A44),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _badge('Day ${card.streakDays}'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                card.message,
                maxLines: compact ? 4 : 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF183231),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return 'Today';
    return DateFormat('MMM d').format(parsed);
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF173432),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  void _openDetail(PostcardContent card, String heroTag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlbumDetailPage(
          card: card,
          heroTag: heroTag,
        ),
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
          Positioned(
            top: -20,
            right: -24,
            child: _blob(
              size: 160,
              color: const Color(0x28D7B685),
            ),
          ),
          Positioned(
            top: 220,
            left: -36,
            child: _blob(
              size: 120,
              color: const Color(0x22B2CDD3),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -12,
            child: _blob(
              size: 130,
              color: const Color(0x22D8A38B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob({required double size, required Color color}) {
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF23413F),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
