
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:environmental_postcard/models/air_quality_data.dart';

class AirQualityService {
  final String _apiKey = 'YOUR_OPENWEATHER_API_KEY'; // Use the same API key as for WeatherService
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/air_pollution';

  Future<AirQualityData> fetchAirQuality(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey'));

    if (response.statusCode == 200) {
      return AirQualityData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load air quality data');
    }
  }
}
