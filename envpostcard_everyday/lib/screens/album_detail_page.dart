import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/postcard_app_controller.dart';
import '../models/postcard_content.dart';

class AlbumDetailPage extends StatefulWidget {
  const AlbumDetailPage({
    super.key,
    required this.controller,
    required this.groupLabel,
    required this.cards,
  });

  final PostcardAppController controller;
  final String groupLabel;
  final List<PostcardContent> cards;

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _openController;
  late List<PostcardContent> _cards;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _cards = List<PostcardContent>.from(widget.cards);
    _pageController = PageController(viewportFraction: 0.88);
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..forward();
  }

  @override
  void dispose() {
    _openController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final card = _cards[_index];
    final parsedDate = DateTime.tryParse(card.createdAtIso);
    final dateText = parsedDate == null ? 'Today' : DateFormat('MMMM d, yyyy').format(parsedDate);

    return Scaffold(
      body: Stack(
        children: [
          Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4EAD5), Color(0xFFE7E1D4), Color(0xFFDDE5DA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _eyebrow(widget.groupLabel),
                        const SizedBox(height: 6),
                        const Text(
                          'Booklet',
                          style: TextStyle(
                            color: Color(0xFF163231),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 420,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _cards.length,
                  onPageChanged: (value) {
                    setState(() {
                      _index = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _cards[index];
                    final path = item.renderedImagePath.isNotEmpty ? item.renderedImagePath : item.imagePath;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F3E6),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x17000000),
                              blurRadius: 22,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_cards.length, (index) {
                  final selected = index == _index;
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
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(card.styleName),
                        _chip(dateText),
                        _chip('Day ${card.streakDays}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      card.message,
                      style: const TextStyle(
                        color: Color(0xFF183231),
                        fontSize: 17,
                        height: 1.7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _metaRow('Location', card.locationLabel),
                    _metaRow('Weather', card.weatherLabel),
                    _metaRow('Temperature', card.temperatureText),
                    _metaRow('Air', card.aqiLabel),
                    if (card.stickerLabels.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: card.stickerLabels.map(_chip).toList(),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _index == 0
                                ? null
                                : () => _pageController.previousPage(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOut,
                                    ),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _index == _cards.length - 1
                                ? null
                                : () => _pageController.nextPage(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOut,
                                    ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Next'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final target = _cards[_index];
                        await widget.controller.deleteSavedCard(target.createdAtIso);
                        if (!mounted) return;
                        setState(() {
                          _cards.removeWhere((item) => item.createdAtIso == target.createdAtIso);
                          if (_cards.isEmpty) {
                            Navigator.of(context).pop();
                            return;
                          }
                          _index = _index.clamp(0, _cards.length - 1);
                        });
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Remove from Album'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
          IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: _openController,
              builder: (context, child) {
                final value = Curves.easeInOutCubic.transform(_openController.value);
                final overlayOpacity = (1 - value).clamp(0.0, 1.0).toDouble();
                if (overlayOpacity <= 0.001) {
                  return const SizedBox.shrink();
                }
                final rightTilt = -1.62 * value;
                final leftSlide = -44.0 * value;
                final sheenOpacity = (0.28 * (1 - value)).clamp(0.0, 0.28).toDouble();
                return Positioned.fill(
                  child: Opacity(
                    opacity: overlayOpacity,
                    child: Stack(
                      children: [
                        Container(color: const Color(0xFFF1E7D5)),
                        Row(
                          children: [
                            Expanded(
                              child: Transform.translate(
                                offset: Offset(leftSlide, 0),
                                child: _BookOpenHalf(
                                  isLeft: true,
                                  shadowOpacity: 0.08 + (0.10 * (1 - value)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Transform(
                                alignment: Alignment.centerLeft,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0015)
                                  ..rotateY(rightTilt),
                                child: _BookOpenHalf(
                                  isLeft: false,
                                  shadowOpacity: 0.16 + (0.10 * (1 - value)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0x00FFFFFF),
                                  Color(0xFFFFFFFF).withValues(alpha: sheenOpacity),
                                  Color(0x00FFFFFF),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
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
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF67807B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF183231),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EBDC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF173432),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _eyebrow(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF59706B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _BookOpenHalf extends StatelessWidget {
  const _BookOpenHalf({
    required this.isLeft,
    required this.shadowOpacity,
  });

  final bool isLeft;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final spineColor = isLeft ? const Color(0xFFCCB08A) : const Color(0xFFD8C1A1);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeft
              ? const [Color(0xFFF8F0E0), Color(0xFFF1E5D0)]
              : const [Color(0xFFF4E7D0), Color(0xFFE9D6B8)],
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 20,
            offset: Offset(isLeft ? -4 : 8, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: isLeft ? 0 : null,
            left: isLeft ? null : 0,
            child: Container(
              width: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    spineColor.withValues(alpha: 0.25),
                    spineColor.withValues(alpha: 0.88),
                    spineColor.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 46,
            left: isLeft ? 28 : 22,
            right: isLeft ? 22 : 28,
            child: Container(
              height: 1.2,
              color: const Color(0x26A7885D),
            ),
          ),
          Positioned(
            top: 74,
            left: isLeft ? 28 : 22,
            right: isLeft ? 22 : 28,
            child: Container(
              height: 1.2,
              color: const Color(0x20A7885D),
            ),
          ),
          Positioned(
            bottom: 62,
            left: isLeft ? 28 : 22,
            right: isLeft ? 22 : 28,
            child: Container(
              height: 1.2,
              color: const Color(0x18A7885D),
            ),
          ),
        ],
      ),
    );
  }
}
