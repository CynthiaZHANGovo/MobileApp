import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // New import
import 'package:environmental_postcard/models/postcard.dart';
import 'package:environmental_postcard/providers/postcard_provider.dart'; // New import
import 'package:environmental_postcard/screens/gallery_screen.dart'; // New import for navigation

class PostcardScreen extends StatefulWidget {
  final Postcard postcard;

  const PostcardScreen({super.key, required this.postcard});

  @override
  State<PostcardScreen> createState() => _PostcardScreenState();
}

class _PostcardScreenState extends State<PostcardScreen> {
  bool _isSaving = false;

  Future<void> _savePostcard() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final postcardProvider = Provider.of<PostcardProvider>(context, listen: false);
      await postcardProvider.savePostcard(widget.postcard);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postcard saved successfully!')),
        );
        // Navigate to the GalleryScreen after saving
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GalleryScreen()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save postcard: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Environmental Postcard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.file(
                          File(widget.postcard.imagePath),
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Location and Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.postcard.location,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(widget.postcard.date),
                            style: const TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Weather Data
                      Text(
                        'Weather: ${widget.postcard.weather.temperature.toStringAsFixed(1)}°C, ${widget.postcard.weather.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8.0),

                      // Air Quality Data
                      Text(
                        'Air Quality: AQI ${widget.postcard.airQuality.aqi}, PM2.5: ${widget.postcard.airQuality.pm2_5.toStringAsFixed(2)} µg/m³, PM10: ${widget.postcard.airQuality.pm10.toStringAsFixed(2)} µg/m³',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),

                      // AI Message
                      Text(
                        '"${widget.postcard.aiMessage}"',
                        style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _savePostcard,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Postcard'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
