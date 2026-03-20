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
          bottomNavigationBar: NavigationBar(
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
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Album',
              ),
            ],
          ),
        );
      },
    );
  }
}
