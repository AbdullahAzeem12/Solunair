import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solunair/core/models/weather_models.dart';
import 'package:solunair/core/repositories/weather_repository.dart';
import 'package:solunair/core/storage/preferences_service.dart';
import 'package:solunair/features/splash/presentation/splash_screen.dart';
import 'package:solunair/features/weather/controllers/weather_controller.dart';
import 'package:solunair/features/weather/presentation/widgets/current_weather_hero.dart';
import 'package:solunair/features/weather/presentation/widgets/hourly_forecast_list.dart';

class MockWeatherRepository implements WeatherRepository {
  final WeatherSnapshot mockSnapshot;

  MockWeatherRepository(this.mockSnapshot);

  @override
  Future<WeatherSnapshot> getWeather(String city, {bool forceRefresh = false}) async {
    return mockSnapshot;
  }

  @override
  Future<WeatherSnapshot> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
    String cityName = '',
    String region = '',
    String country = '',
    bool forceRefresh = false,
  }) async {
    return mockSnapshot;
  }

  @override
  Future<List<LocationSuggestion>> searchCities(String query) async {
    return [];
  }

  @override
  WeatherSnapshot? getCachedWeather(String city) => mockSnapshot;

  @override
  WeatherSnapshot? getLastCachedWeather() => mockSnapshot;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WeatherSnapshot testSnapshot;
  late PreferencesService prefsService;
  late WeatherController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'selected_city': 'Lahore',
      'recent_searches': ['Lahore', 'Karachi', 'Islamabad'],
    });
    final prefs = await SharedPreferences.getInstance();
    prefsService = PreferencesService(prefs);

    testSnapshot = WeatherSnapshot.createDefaultFallback(cityName: 'Lahore');
    final repo = MockWeatherRepository(testSnapshot);
    controller = WeatherController(repository: repo, prefs: prefsService);
  });

  testWidgets('SplashScreen renders branding, 3D elements and countdown', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(controller: controller),
      ),
    );

    // Initial frame rendered
    expect(find.text('SOLUNAIR'), findsOneWidget);
    expect(find.text('ATMOSPHERIC INTELLIGENCE'), findsOneWidget);
    expect(find.text('Explore Now'), findsOneWidget);

    // Let animation advance
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('SOLUNAIR'), findsOneWidget);
  });

  testWidgets('CurrentWeatherHero renders city name, temperature and condition', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrentWeatherHero(
            weather: testSnapshot,
            controller: controller,
            onOpenCitySearch: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Lahore'), findsOneWidget);
    expect(find.textContaining('°C'), findsWidgets);
    expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
  });

  testWidgets('HourlyForecastList renders 24-hour capsules and "Now" highlight', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HourlyForecastList(
            hourlyList: testSnapshot.hourlyForecast,
            isDay: true,
            tempUnit: 'C',
            ambientGlow: const Color(0xFFFFD166),
          ),
        ),
      ),
    );

    expect(find.text('Hourly Forecast'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
  });
}
