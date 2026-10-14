import 'package:flutter_test/flutter_test.dart';
import 'package:solunair/core/models/weather_models.dart';
import 'package:solunair/core/utils/unit_converter.dart';
import 'package:solunair/core/utils/weather_condition_mapper.dart';
import 'package:solunair/core/data/pakistan_cities.dart';
import 'package:solunair/core/services/location_service.dart';

void main() {
  group('UnitConverter Tests', () {
    test('Celsius to Fahrenheit conversion is accurate', () {
      expect(UnitConverter.cToF(0), 32.0);
      expect(UnitConverter.cToF(100), 212.0);
      expect(UnitConverter.cToF(25), 77.0);
    });

    test('Fahrenheit to Celsius conversion is accurate', () {
      expect(UnitConverter.fToC(32), 0.0);
      expect(UnitConverter.fToC(212), 100.0);
    });

    test('Wind speed conversion from km/h to mph and m/s', () {
      expect(UnitConverter.formatWindSpeed(10.0, unit: 'mph'), '6.2 mph');
      expect(UnitConverter.formatWindSpeed(36.0, unit: 'ms'), '10.0 m/s');
      expect(UnitConverter.formatWindSpeed(15.0, unit: 'kph'), '15.0 km/h');
    });

    test('Temperature formatting with unit symbol', () {
      expect(UnitConverter.formatTemperature(27.4, unit: 'C'), '27°C');
      expect(UnitConverter.formatTemperature(27.4, unit: 'F'), '81°F');
    });
  });

  group('WeatherConditionMapper Tests', () {
    test('Correctly maps rain conditions', () {
      final type = WeatherConditionMapper.resolve(
        conditionText: 'Light rain shower',
        conditionCode: 1240,
        isDay: true,
      );
      expect(type, WeatherType.rain);

      final heavy = WeatherConditionMapper.resolve(
        conditionText: 'Heavy rain downpour',
        conditionCode: 1195,
        isDay: true,
      );
      expect(heavy, WeatherType.heavyRain);
    });

    test('Correctly maps thunderstorm conditions', () {
      final type = WeatherConditionMapper.resolve(
        conditionText: 'Patchy light rain with thunder',
        conditionCode: 1273,
        isDay: false,
      );
      expect(type, WeatherType.thunderstorm);
    });

    test('Correctly differentiates sunny vs clear night', () {
      final dayType = WeatherConditionMapper.resolve(
        conditionText: 'Sunny',
        conditionCode: 1000,
        isDay: true,
      );
      expect(dayType, WeatherType.sunny);

      final nightType = WeatherConditionMapper.resolve(
        conditionText: 'Clear',
        conditionCode: 1000,
        isDay: false,
      );
      expect(nightType, WeatherType.clearNight);
    });
  });

  group('PakistanCitiesDatabase Tests', () {
    test('Contains major Pakistani cities', () {
      final major = PakistanCitiesDatabase.cities.where((c) => c.isMajor).toList();
      expect(major.isNotEmpty, isTrue);

      final names = PakistanCitiesDatabase.cities.map((c) => c.name).toList();
      expect(names.contains('Lahore'), isTrue);
      expect(names.contains('Karachi'), isTrue);
      expect(names.contains('Islamabad'), isTrue);
      expect(names.contains('Peshawar'), isTrue);
      expect(names.contains('Quetta'), isTrue);
    });

    test('Filters by region correctly', () {
      final punjabCities = PakistanCitiesDatabase.getByRegion('Punjab');
      expect(punjabCities.every((c) => c.province == 'Punjab'), isTrue);

      final sindhCities = PakistanCitiesDatabase.getByRegion('Sindh');
      expect(sindhCities.every((c) => c.province == 'Sindh'), isTrue);
    });

    test('Search filters cities appropriately', () {
      final results = PakistanCitiesDatabase.search('lah');
      expect(results.any((c) => c.name.toLowerCase() == 'lahore'), isTrue);
    });
  });

  group('WeatherSnapshot Default Fallback', () {
    test('Generates complete non-null snapshot without crashing', () {
      final fallback = WeatherSnapshot.createDefaultFallback(cityName: 'Lahore');
      expect(fallback.cityName, 'Lahore');
      expect(fallback.temperatureC, isNotNull);
      expect(fallback.hourlyForecast.length, 24);
      expect(fallback.dailyForecast.isNotEmpty, isTrue);
      expect(fallback.isCached, isTrue);
    });
  });

  group('LocationService Precision Geocoding Tests', () {
    test('Resolves Canal Berg Housing Society for active coordinates', () async {
      final match = await LocationService.reverseGeocodePrecision(31.4772, 74.2467);
      expect(match['cityName'], 'Canal Berg Housing Society');
      expect(match['region'], 'Lahore, Punjab');
      expect(match['country'], 'Pakistan');
    });
  });
}
