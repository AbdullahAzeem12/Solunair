import 'package:flutter_test/flutter_test.dart';
import 'package:solunair/core/config/api_config.dart';
import 'package:solunair/core/models/weather_models.dart';
import 'package:solunair/core/network/weather_api_client.dart';
import 'package:solunair/core/utils/weather_condition_mapper.dart';

void main() {
  group('OpenWeatherMap Integration Tests', () {
    test('Parses OpenWeatherMap current and forecast JSON into WeatherSnapshot', () {
      final mockCurrentJson = {
        'coord': {'lon': 74.3436, 'lat': 31.5497},
        'weather': [
          {'id': 800, 'main': 'Clear', 'description': 'clear sky', 'icon': '01n'}
        ],
        'main': {
          'temp': 26.75,
          'feels_like': 27.53,
          'temp_min': 25.0,
          'temp_max': 28.0,
          'pressure': 1016,
          'humidity': 56
        },
        'visibility': 10000,
        'wind': {'speed': 3.28, 'deg': 56, 'gust': 6.33},
        'clouds': {'all': 4},
        'dt': 1791904494,
        'sys': {'country': 'PK', 'sunrise': 1791853428, 'sunset': 1791894827},
        'name': 'Lahore',
        'cod': 200
      };

      final mockForecastJson = {
        'list': [
          {
            'dt': 1791914400,
            'main': {'temp': 26.18, 'temp_min': 25.14, 'temp_max': 26.18},
            'weather': [
              {'id': 800, 'main': 'Clear', 'description': 'clear sky', 'icon': '01n'}
            ],
            'pop': 0.1,
            'dt_txt': '2026-10-13 18:00:00'
          },
          {
            'dt': 1791925200,
            'main': {'temp': 25.13, 'temp_min': 24.34, 'temp_max': 25.13},
            'weather': [
              {'id': 803, 'main': 'Clouds', 'description': 'broken clouds', 'icon': '04n'}
            ],
            'pop': 0.2,
            'dt_txt': '2026-10-13 21:00:00'
          }
        ]
      };

      final snapshot = WeatherSnapshot.fromOpenWeatherJson(
        currentJson: mockCurrentJson,
        forecastJson: mockForecastJson,
      );

      expect(snapshot.cityName, 'Lahore');
      expect(snapshot.temperatureC, 26.75);
      expect(snapshot.temperatureC.round(), 27); // Rounds to 27°C (matching Huawei weather!)
      expect(snapshot.feelsLikeC, 27.53);
      expect(snapshot.humidity, 56);
      expect(snapshot.windKph, closeTo(3.28 * 3.6, 0.1));
      expect(snapshot.visibilityKm, 10.0);
      expect(snapshot.providerName, 'OpenWeatherMap');
      expect(snapshot.hourlyForecast.length, 4); // 2 raw 3-hr steps interpolated to 4 sequential 1-hr steps
      expect(snapshot.hourlyForecast.first.tempC, 26.18);
    });

    test('LocationSuggestion parses OpenWeather direct geocoding JSON', () {
      final mockGeoJson = {
        'name': 'Lahore',
        'lat': 31.5656822,
        'lon': 74.3141829,
        'country': 'PK',
        'state': 'Punjab'
      };

      final suggestion = LocationSuggestion.fromOpenWeatherJson(mockGeoJson);
      expect(suggestion.name, 'Lahore');
      expect(suggestion.region, 'Punjab');
      expect(suggestion.country, 'Pakistan');
      expect(suggestion.latitude, 31.5656822);
      expect(suggestion.longitude, 74.3141829);
    });

    test('WeatherConditionMapper properly handles OpenWeather codes', () {
      expect(
        WeatherConditionMapper.resolve(conditionText: 'Clear', conditionCode: 800, isDay: true),
        WeatherType.sunny,
      );
      expect(
        WeatherConditionMapper.resolve(conditionText: 'Clear', conditionCode: 800, isDay: false),
        WeatherType.clearNight,
      );
      expect(
        WeatherConditionMapper.resolve(conditionText: 'Thunderstorm', conditionCode: 211, isDay: false),
        WeatherType.thunderstorm,
      );
      expect(
        WeatherConditionMapper.resolve(conditionText: 'Light Rain', conditionCode: 500, isDay: true),
        WeatherType.rain,
      );
    });

    test('Live fetch from OpenWeather using configured API Key', () async {
      final key = ApiConfig.openWeatherApiKey;
      if (key.isEmpty) return;

      final client = WeatherApiClient();
      try {
        final snapshot = await client.fetchWeather(
          city: 'Lahore',
          openWeatherApiKey: key,
          preferredProvider: 'openweather',
        );

        expect(snapshot.cityName.toLowerCase(), contains('lahore'));
        expect(snapshot.providerName, 'OpenWeatherMap');
        expect(snapshot.temperatureC, isNotNull);
        expect(snapshot.hourlyForecast.isNotEmpty, isTrue);
      } finally {
        client.dispose();
      }
    });
  });
}
