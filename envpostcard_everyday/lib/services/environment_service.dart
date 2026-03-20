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
      throw Exception('定位服务未开启，请先在系统设置中打开定位。');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('未获得定位权限，无法获取环境数据。');
    }

    return Geolocator.getCurrentPosition();
  }

  String _mapWeatherCode(int code) {
    if (code == 0) return '晴朗';
    if (code == 1 || code == 2) return '微云';
    if (code == 3) return '阴天';
    if (code == 45 || code == 48) return '雾气';
    if (code >= 51 && code <= 67) return '细雨';
    if (code >= 71 && code <= 77) return '降雪';
    if (code >= 80 && code <= 82) return '阵雨';
    if (code >= 95) return '雷暴';
    return '天气流动中';
  }

  String _mapAqi(int aqi) {
    if (aqi <= 20) return '空气清透';
    if (aqi <= 40) return '空气温和';
    if (aqi <= 60) return '空气一般';
    if (aqi <= 80) return '空气偏沉';
    return '空气需要留意';
  }
}
