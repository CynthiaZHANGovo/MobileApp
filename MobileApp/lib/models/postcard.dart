import 'package:environmental_postcard/models/air_quality_data.dart';
import 'package:environmental_postcard/models/weather_data.dart';

class Postcard {
  final String imagePath;
  final String location;
  final WeatherData weather;
  final AirQualityData airQuality;
  final String aiMessage;
  final DateTime date;

  Postcard({
    required this.imagePath,
    required this.location,
    required this.weather,
    required this.airQuality,
    required this.aiMessage,
    required this.date,
  });

  // Convert a Postcard object into a Map object
  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'location': location,
      'weather': weather.toJson(),
      'airQuality': airQuality.toJson(),
      'aiMessage': aiMessage,
      'date': date.toIso8601String(),
    };
  }

  // Convert a Map object into a Postcard object
  factory Postcard.fromJson(Map<String, dynamic> json) {
    return Postcard(
      imagePath: json['imagePath'] as String,
      location: json['location'] as String,
      weather: WeatherData.fromJson(json['weather'] as Map<String, dynamic>),
      airQuality: AirQualityData.fromJson(json['airQuality'] as Map<String, dynamic>),
      aiMessage: json['aiMessage'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
