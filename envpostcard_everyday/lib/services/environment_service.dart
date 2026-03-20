import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/environment_snapshot.dart';

class EnvironmentService {
  Future<EnvironmentSnapshot> collect() async {
    final position = await _determinePosition();
    final place = await _resolvePlace(position);
    final weatherUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '${position.latitude}',
        'longitude': '${position.longitude}',
        'current': 'temperature_2m,weather_code',
        'timezone': 'auto',
      },
    );
    final airUri = Uri.https(
      'air-quality-api.open-meteo.com',
      '/v1/air-quality',
      {
        'latitude': '${position.latitude}',
        'longitude': '${position.longitude}',
        'current': 'european_aqi',
        'timezone': 'auto',
      },
    );

    final responses = await Future.wait([http.get(weatherUri), http.get(airUri)]);
    final weatherJson =
        jsonDecode(responses[0].body) as Map<String, dynamic>;
    final airJson = jsonDecode(responses[1].body) as Map<String, dynamic>;

    final weather = weatherJson['current'] as Map<String, dynamic>? ?? {};
    final air = airJson['current'] as Map<String, dynamic>? ?? {};
    final weatherCode = weather['weather_code'] as num? ?? 0;
    final temperature = weather['temperature_2m'] as num? ?? 0;
    final aqi = (air['european_aqi'] as num? ?? 0).round();

    return EnvironmentSnapshot(
      locationLabel: place,
      temperatureC: temperature.toDouble(),
      weatherLabel: _mapWeatherCode(weatherCode.toInt()),
      aqi: aqi,
      aqiLabel: _mapAqi(aqi),
      localTime: DateTime.now(),
    );
  }

  Future<String> _resolvePlace(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.first;
      final locality = place.locality ?? place.subAdministrativeArea;
      final country = place.country;
      if (locality != null && country != null) {
        return '$locality, $country';
      }
    } catch (_) {
      // Falls back to coordinates when reverse geocoding is unavailable.
    }
    return '${position.latitude.toStringAsFixed(2)}, '
        '${position.longitude.toStringAsFixed(2)}';
  }

  Future<Position> _determinePosition() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are off. Please enable them first.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required to read live context.');
    }

    return Geolocator.getCurrentPosition();
  }

  String _mapWeatherCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1 || code == 2) return 'Soft clouds';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Light rain';
    if (code >= 71 && code <= 77) return 'Snowfall';
    if (code >= 80 && code <= 82) return 'Passing showers';
    if (code >= 95) return 'Thunder';
    return 'Shifting weather';
  }

  String _mapAqi(int aqi) {
    if (aqi <= 20) return 'Air is crisp';
    if (aqi <= 40) return 'Air is calm';
    if (aqi <= 60) return 'Air is moderate';
    if (aqi <= 80) return 'Air feels dense';
    return 'Air needs care';
  }
}
