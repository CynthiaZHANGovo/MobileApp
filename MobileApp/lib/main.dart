import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // New import
import 'package:environmental_postcard/screens/capture_screen.dart';
import 'package:environmental_postcard/providers/postcard_provider.dart'; // New import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostcardProvider(), // Provide the PostcardProvider
      child: MaterialApp(
        title: 'Environmental Postcard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const CaptureScreen(),
      ),
    );
  }
}
