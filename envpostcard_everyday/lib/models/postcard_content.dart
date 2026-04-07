class PostcardContent {
  const PostcardContent({
    required this.imagePath,
    required this.renderedImagePath,
    required this.message,
    required this.styleName,
    required this.stickerLabels,
    required this.locationLabel,
    required this.weatherLabel,
    required this.temperatureText,
    required this.aqiLabel,
    required this.createdAtIso,
    required this.streakDays,
    required this.primaryColorValue,
    required this.secondaryColorValue,
  });

  final String imagePath;
  final String renderedImagePath;
  final String message;
  final String styleName;
  final List<String> stickerLabels;
  final String locationLabel;
  final String weatherLabel;
  final String temperatureText;
  final String aqiLabel;
  final String createdAtIso;
  final int streakDays;
  final int primaryColorValue;
  final int secondaryColorValue;

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'renderedImagePath': renderedImagePath,
      'message': message,
      'styleName': styleName,
      'stickerLabels': stickerLabels,
      'locationLabel': locationLabel,
      'weatherLabel': weatherLabel,
      'temperatureText': temperatureText,
      'aqiLabel': aqiLabel,
      'createdAtIso': createdAtIso,
      'streakDays': streakDays,
      'primaryColorValue': primaryColorValue,
      'secondaryColorValue': secondaryColorValue,
    };
  }

  factory PostcardContent.fromJson(Map<String, dynamic> json) {
    return PostcardContent(
      imagePath: json['imagePath'] as String? ?? '',
      renderedImagePath: json['renderedImagePath'] as String? ?? '',
      message: json['message'] as String? ?? '',
      styleName: json['styleName'] as String? ?? 'Atmosphere Wash',
      stickerLabels:
          (json['stickerLabels'] as List<dynamic>? ?? [])
              .map((item) => item.toString())
              .toList(),
      locationLabel: json['locationLabel'] as String? ?? '',
      weatherLabel: json['weatherLabel'] as String? ?? '',
      temperatureText: json['temperatureText'] as String? ?? '',
      aqiLabel: json['aqiLabel'] as String? ?? '',
      createdAtIso: json['createdAtIso'] as String? ?? '',
      streakDays: json['streakDays'] as int? ?? 1,
      primaryColorValue: json['primaryColorValue'] as int? ?? 0xFF446E64,
      secondaryColorValue: json['secondaryColorValue'] as int? ?? 0xFFEDD8B0,
    );
  }
}
