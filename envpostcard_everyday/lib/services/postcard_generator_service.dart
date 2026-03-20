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
              '请根据照片氛围、天气、AQI、时间与连续打卡天数，生成一段20到60字的中文环境明信片文案，偏诗性与感受性，不要解释。'
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
    final formatter = DateFormat('M月d日 HH:mm');
    final timeText = formatter.format(environment.localTime);
    final weatherTone = switch (environment.weatherLabel) {
      '晴朗' => '光线把世界的边缘擦得很清楚',
      '微云' => '云层让今天的情绪变得柔软',
      '阴天' => '灰色像一张慢慢摊开的纸',
      '细雨' => '潮湿让每个细节都更贴近皮肤',
      '雷暴' => '空气里有尚未说出的震动',
      _ => '环境在缓慢地调整它的节奏',
    };

    return '在${environment.locationLabel}，$timeText 的${environment.weatherLabel}里，'
        '$weatherTone。照片里是${palette.colorStory}的${palette.moodLabel}，'
        '${environment.aqiLabel}，体感像${environment.temperatureC.toStringAsFixed(0)}°C 的呼吸。'
        '这是连续第 $streakDays 天，把今天寄给未来的自己。';
  }
}
