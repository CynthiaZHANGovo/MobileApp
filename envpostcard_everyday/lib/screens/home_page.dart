import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controllers/postcard_app_controller.dart';
import 'archive_page.dart';
import 'capture_page.dart';
import 'studio_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostcardAppController _controller = PostcardAppController();
  int _currentIndex = 0;
  bool _showStudio = false;

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pages = [
          _showStudio
              ? StudioPage(
                  controller: _controller,
                  onBackToCapture: () {
                    setState(() {
                      _showStudio = false;
                      _currentIndex = 0;
                    });
                  },
                )
              : CapturePage(
                  controller: _controller,
                  onGenerated: () {
                    setState(() {
                      _showStudio = true;
                      _currentIndex = 0;
                    });
                  },
                ),
          ArchivePage(controller: _controller),
        ];

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3E9D2), Color(0xFFE8E3D6), Color(0xFFDCE4DA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(child: pages[_currentIndex]),
          ),
          bottomNavigationBar: _FloatingNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.auto_awesome_mosaic_outlined, Icons.auto_awesome_mosaic_rounded),
      (Icons.photo_album_outlined, Icons.photo_album_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 58,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final selected = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1E5751).withValues(alpha: 0.92)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Icon(
                          selected ? items[index].$2 : items[index].$1,
                          size: 21,
                          color: selected ? Colors.white : const Color(0xFF4E6561),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
