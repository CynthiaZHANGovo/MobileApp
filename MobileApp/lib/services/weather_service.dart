
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:environmental_postcard/models/weather_data.dart';

class WeatherService {
  final String _apiKey = 'YOUR_OPENWEATHER_API_KEY'; // Replace with your actual API key
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> fetchWeather(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
