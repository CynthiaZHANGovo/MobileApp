
class AirQualityData {
  final int aqi; // Air Quality Index
  final double pm2_5; // PM2.5 concentration
  final double pm10; // PM10 concentration

  AirQualityData({
    required this.aqi,
    required this.pm2_5,
    required this.pm10,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final components = json['list'][0]['components'];
    return AirQualityData(
      aqi: json['list'][0]['main']['aqi'] as int,
      pm2_5: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'pm2_5': pm2_5,
      'pm10': pm10,
    };
  }
}
