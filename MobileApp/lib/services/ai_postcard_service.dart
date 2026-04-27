
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:environmental_postcard/models/weather_data.dart';
import 'package:environmental_postcard/models/air_quality_data.dart';

class AIPostcardService {
  final String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with your actual Gemini API key
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> generatePostcardMessage(
      WeatherData weather,
      AirQualityData airQuality,
      String location,
  ) async {
    final prompt = """
      Write a short, poetic postcard message (max 50 words) about the environment based on the following data:
      Location: $location
      Temperature: ${weather.temperature}°C
      Weather Description: ${weather.description}
      Air Quality Index (AQI): ${airQuality.aqi}
      PM2.5: ${airQuality.pm2_5} µg/m³
      PM10: ${airQuality.pm10} µg/m³

      Example message:
      "A quiet morning beneath drifting clouds.
      Cool air moves gently through the streets,
      and the city pauses for a breath."
      """;

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Assuming the AI response structure, adjust if needed
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Failed to generate postcard message: ${response.body}');
    }
  }
}
