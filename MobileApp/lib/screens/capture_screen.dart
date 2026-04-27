import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:environmental_postcard/models/postcard.dart';
import 'package:environmental_postcard/services/location_service.dart';
import 'package:environmental_postcard/services/weather_service.dart';
import 'package:environmental_postcard/services/air_quality_service.dart';
import 'package:environmental_postcard/services/ai_postcard_service.dart';
import 'package:environmental_postcard/screens/postcard_screen.dart';
import 'package:environmental_postcard/screens/gallery_screen.dart'; // New import

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  XFile? _imageFile; // Stores the captured image file
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance
  bool _isLoading = false; // To show loading indicator
  String? _errorMessage; // To display error messages

  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final AirQualityService _airQualityService = AirQualityService();
  final AIPostcardService _aiPostcardService = AIPostcardService();

  Future<void> _captureEnvironment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Capture a photo
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _imageFile = pickedFile;
      });

      // 2. Retrieve user's location
      final Position position = await _locationService.getCurrentLocation();
      final double latitude = position.latitude;
      final double longitude = position.longitude;

      // 3. Fetch weather data
      final weatherData = await _weatherService.fetchWeather(latitude, longitude);

      // 4. Fetch air quality data
      final airQualityData = await _airQualityService.fetchAirQuality(latitude, longitude);

      // 5. Send environmental data to AI service to generate message
      final aiMessage = await _aiPostcardService.generatePostcardMessage(
        weatherData,
        airQualityData,
        weatherData.cityName, // Using city name from weather data for location
      );

      // 6. Create the Postcard object
      final Postcard newPostcard = Postcard(
        imagePath: _imageFile!.path,
        location: weatherData.cityName,
        weather: weatherData,
        airQuality: airQualityData,
        aiMessage: aiMessage,
        date: DateTime.now(),
      );

      // Navigate to PostcardScreen to display the generated postcard
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostcardScreen(postcard: newPostcard),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to navigate to the gallery screen
  void _navigateToGallery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GalleryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Environment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library), // Gallery icon
            onPressed: _navigateToGallery,
            tooltip: 'View Gallery',
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading indicator
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_imageFile != null)
                    Image.file(
                      File(_imageFile!.path),
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  else
                    const Text('No image captured yet. Tap the camera to begin!'),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _captureEnvironment,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture Environment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
