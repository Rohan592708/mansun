import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../blocs/weather/weather_bloc.dart';
import '../../blocs/weather/weather_event.dart';
import '../../blocs/weather/weather_state.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _cityController = TextEditingController();

  HomeScreen({super.key});


  void _saveLastCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', cityName);
  }

  Widget _getWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor;

    switch (condition.toLowerCase()) {
      case 'sunny':
        iconData = Icons.wb_sunny_rounded;
        iconColor = Colors.amber;
        break;
      case 'partly cloudy':
        iconData = Icons.cloud_queue_rounded;
        iconColor = Colors.white70;
        break;
      case 'rainy':
        iconData = Icons.grain_rounded;
        iconColor = Colors.blueAccent;
        break;
      case 'thunderstorm':
        iconData = Icons.thunderstorm_rounded;
        iconColor = Colors.yellowAccent;
        break;
      case 'snowy':
        iconData = Icons.ac_unit_rounded;
        iconColor = Colors.lightBlueAccent;
        break;
      default:
        iconData = Icons.cloud_rounded;
        iconColor = Colors.white;
    }

    return Icon(
      iconData,
      size: 100,
      color: iconColor,
      shadows: [
        Shadow(
          blurRadius: 20,
          color: iconColor.withOpacity(0.5),
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D2671), Color(0xFFC33764)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Mansun',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'Your Premium Weather Companion',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 25),

                TextField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter City Name (e.g. Mumbai)',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        if (_cityController.text.isNotEmpty) {
                          final searchedCity = _cityController.text.trim();
                          context.read<WeatherBloc>().add(
                            FetchWeatherByCity(searchedCity),
                          );

                          _saveLastCity(searchedCity);
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: BlocBuilder<WeatherBloc, WeatherState>(
                    builder: (context, state) {
                      if (state is WeatherInitial) {
                        return const Center(
                          child: Text(
                            'Search a city to check the weather!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      } else if (state is WeatherLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      } else if (state is WeatherLoaded) {
                        final weather = state.weather;
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                weather.cityName,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _getWeatherIcon(weather.condition),

                              const SizedBox(height: 10),
                              Text(
                                '${weather.temperature.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 75,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                weather.condition,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 40),

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildWeatherDetailItem(
                                      icon: Icons.air,
                                      value: '${weather.windSpeed} km/h',
                                      label: 'Wind',
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      color: Colors.white30,
                                    ),
                                    _buildWeatherDetailItem(
                                      icon: Icons.umbrella,
                                      value: '${weather.chanceOfRain}%',
                                      label: 'Rain',
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      color: Colors.white30,
                                    ),
                                    _buildWeatherDetailItem(
                                      icon: Icons.water_drop,
                                      value: '${weather.humidity}%',
                                      label: 'Humidity',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (state is WeatherError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
