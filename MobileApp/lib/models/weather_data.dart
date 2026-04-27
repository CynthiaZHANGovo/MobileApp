
class WeatherData {
  final double temperature;
  final String description;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: (json['weather'][0]['description'] as String),
      cityName: (json['name'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'description': description,
      'cityName': cityName,
    };
  }
}
