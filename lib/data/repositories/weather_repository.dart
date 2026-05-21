import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherRepository {
  final Dio _dio = Dio();

  Future<WeatherModel> fetchWeather(String cityName) async {
    try {

      final geoUrl =
          'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1&language=en&format=json';
      final geoResponse = await _dio.get(geoUrl);

      if (geoResponse.data['results'] == null ||
          (geoResponse.data['results'] as List).isEmpty) {
        throw Exception('City not found');
      }

      final result = geoResponse.data['results'][0];
      final double lat = result['latitude'];
      final double lon = result['longitude'];
      final String formattedCityName = result['name'];


      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&hourly=precipitation_probability&forecast_days=1';
      final weatherResponse = await _dio.get(weatherUrl);

      return WeatherModel.fromJson(weatherResponse.data, formattedCityName);
    } catch (e) {
      throw Exception('Failed to load weather: ${e.toString()}');
    }
  }
}
