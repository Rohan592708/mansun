import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  final String cityName;
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;
  final int chanceOfRain;

  const WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
    required this.chanceOfRain,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String city) {
    final current = json['current'];

    String getWeatherCondition(int code) {
      if (code == 0) return 'Sunny';
      if (code <= 3) return 'Partly Cloudy';
      if (code <= 65) return 'Rainy';
      if (code <= 77) return 'Snowy';
      return 'Thunderstorm';
    }


    int rainProbability = 0;
    if (json['hourly'] != null &&
        json['hourly']['precipitation_probability'] != null) {
      List<dynamic> hourlyRain = json['hourly']['precipitation_probability'];

      if (hourlyRain.isNotEmpty) {
        rainProbability = (hourlyRain[0] as num).toInt();
      }
    }

    return WeatherModel(
      cityName: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      condition: getWeatherCondition(current['weather_code'] as int),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      chanceOfRain: rainProbability,
    );
  }

  @override
  List<Object?> get props => [
    cityName,
    temperature,
    condition,
    windSpeed,
    humidity,
    chanceOfRain,
  ];
}
