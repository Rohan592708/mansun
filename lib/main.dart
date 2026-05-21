import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/weather_repository.dart';
import 'blocs/weather/weather_bloc.dart';
import 'blocs/weather/weather_event.dart';
import 'presentation/screens/home_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final WeatherRepository weatherRepository = WeatherRepository();


  final prefs = await SharedPreferences.getInstance();
  final String savedCity =
      prefs.getString('last_city') ??
      'Delhi';

  runApp(MyApp(weatherRepository: weatherRepository, initialCity: savedCity));
}

class MyApp extends StatelessWidget {
  final WeatherRepository weatherRepository;
  final String initialCity;

  const MyApp({
    super.key,
    required this.weatherRepository,
    required this.initialCity,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: weatherRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WeatherBloc>(

            create: (context) =>
                WeatherBloc(weatherRepository: weatherRepository)
                  ..add(FetchWeatherByCity(initialCity)),
          ),
        ],
        child: MaterialApp(
          title: 'Mansun',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                Icons.wb_cloudy_rounded,
                size: 120,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 20),
              const Text(
                'Mansun',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your Premium Weather Companion',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
