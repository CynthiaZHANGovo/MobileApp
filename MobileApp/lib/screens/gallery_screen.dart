
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:environmental_postcard/providers/postcard_provider.dart';
import 'package:environmental_postcard/widgets/postcard_card.dart';
import 'package:environmental_postcard/screens/postcard_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    // Load postcards when the gallery screen is initialized
    Future.microtask(() => Provider.of<PostcardProvider>(context, listen: false).loadPostcards());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Postcard Gallery'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<PostcardProvider>(
        builder: (context, postcardProvider, child) {
          if (postcardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (postcardProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${postcardProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (postcardProvider.postcards.isEmpty) {
            return const Center(
              child: Text('No postcards saved yet. Go capture some memories!'),
            );
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.75, // Adjust as needed
              ),
              itemCount: postcardProvider.postcards.length,
              itemBuilder: (context, index) {
                final postcard = postcardProvider.postcards[index];
                return PostcardCard(
                  postcard: postcard,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostcardScreen(postcard: postcard),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
