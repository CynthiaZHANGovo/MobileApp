class EnvironmentSnapshot {
  const EnvironmentSnapshot({
    required this.locationLabel,
    required this.temperatureC,
    required this.weatherLabel,
    required this.aqi,
    required this.aqiLabel,
    required this.localTime,
  });

  final String locationLabel;
  final double temperatureC;
  final String weatherLabel;
  final int aqi;
  final String aqiLabel;
  final DateTime localTime;
}
