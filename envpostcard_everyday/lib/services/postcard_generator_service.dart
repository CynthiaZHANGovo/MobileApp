import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/environment_snapshot.dart';
import 'photo_palette_service.dart';

class PostcardGeneratorService {
  static const _llmEndpoint = String.fromEnvironment('LLM_ENDPOINT');
  static const _llmApiKey = String.fromEnvironment('LLM_API_KEY');

  Future<String> generateMessage({
    required EnvironmentSnapshot environment,
    required PhotoPalette palette,
    required int streakDays,
  }) async {
    if (_llmEndpoint.isNotEmpty) {
      final remote = await _generateRemote(
        environment: environment,
        palette: palette,
        streakDays: streakDays,
      );
      if (remote != null && remote.trim().isNotEmpty) {
        return remote.trim();
      }
    }

    return _generateLocal(
      environment: environment,
      palette: palette,
      streakDays: streakDays,
    );
  }

  Future<String?> _generateRemote({
    required EnvironmentSnapshot environment,
    required PhotoPalette palette,
    required int streakDays,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_llmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          if (_llmApiKey.isNotEmpty) 'Authorization': 'Bearer $_llmApiKey',
        },
        body: jsonEncode({
          'photoMood': palette.moodLabel,
          'photoColors': palette.colorStory,
          'location': environment.locationLabel,
          'weather': environment.weatherLabel,
          'temperatureC': environment.temperatureC,
          'aqi': environment.aqi,
          'aqiLabel': environment.aqiLabel,
          'streakDays': streakDays,
          'prompt':
              'Write a 20 to 60 word environmental postcard in English. Make it poetic, emotional, and concise. Use the photo mood, weather, AQI, time, and streak. Do not explain the process.'
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['text'] as String? ??
            decoded['output_text'] as String? ??
            decoded['message'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _generateLocal({
    required EnvironmentSnapshot environment,
    required PhotoPalette palette,
    required int streakDays,
  }) {
    final formatter = DateFormat('MMM d • HH:mm');
    final timeText = formatter.format(environment.localTime);
    final weatherTone = switch (environment.weatherLabel) {
      'Clear sky' => 'light sharpens the edges of everything',
      'Soft clouds' => 'the sky softens the day into a gentler rhythm',
      'Overcast' => 'the gray air opens like folded paper',
      'Light rain' => 'moisture pulls every detail closer to the skin',
      'Thunder' => 'the air holds a quiet voltage before release',
      _ => 'the atmosphere keeps rewriting its own pace',
    };

    return 'At $timeText in ${environment.locationLabel}, ${environment.weatherLabel.toLowerCase()} settles in and '
        '$weatherTone. The frame carries ${palette.colorStory}, feeling ${palette.moodLabel.toLowerCase()}. '
        '${environment.aqiLabel}, ${environment.temperatureC.toStringAsFixed(0)}°C in the lungs, day $streakDays of mailing this world forward.';
  }
}
