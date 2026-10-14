import 'package:flutter_test/flutter_test.dart';
import 'package:solunair/core/network/weather_api_client.dart';

void main() {
  test('Live Open-Meteo REST API integration for Pakistan cities', () async {
    final client = WeatherApiClient();
    try {
      // Test live fetch for Islamabad
      final snapshot = await client.fetchWeather(city: 'Islamabad');
      expect(snapshot.cityName, 'Islamabad');
      expect(snapshot.temperatureC, isNotNull);
      expect(snapshot.humidity, isNotNull);
      expect(snapshot.hourlyForecast.isNotEmpty, isTrue);
      expect(snapshot.dailyForecast.isNotEmpty, isTrue);
    } finally {
      client.dispose();
    }
  });

  test('Live Pakistan city search integration', () async {
    final client = WeatherApiClient();
    try {
      final results = await client.searchCities('Karachi');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((c) => c.name.toLowerCase() == 'karachi'), isTrue);
    } finally {
      client.dispose();
    }
  });
}
