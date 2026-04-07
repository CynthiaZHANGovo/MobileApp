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
          CapturePage(
            controller: _controller,
            onGenerated: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          StudioPage(controller: _controller),
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
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: NavigationBar(
                height: 72,
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.camera_alt_outlined),
                    selectedIcon: Icon(Icons.camera_alt),
                    label: 'Capture',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.auto_awesome_mosaic_outlined),
                    selectedIcon: Icon(Icons.auto_awesome_mosaic),
                    label: 'Studio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.photo_album_outlined),
                    selectedIcon: Icon(Icons.photo_album),
                    label: 'Album',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
