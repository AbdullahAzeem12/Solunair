import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/pakistan_cities.dart';
import '../models/weather_models.dart';
import 'api_exceptions.dart';

/// REST API client using the official `http` package for public weather services.
class WeatherApiClient {
  final http.Client _client;

  WeatherApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches weather snapshot for the specified city.
  /// Seamlessly tries OpenWeatherMap (highest accuracy station data matching official Huawei weather),
  /// WeatherAPI.com (if key available), and falls back to Open-Meteo.
  Future<WeatherSnapshot> fetchWeather({
    required String city,
    String? openWeatherApiKey,
    String? apiKey,
    String preferredProvider = 'auto',
  }) async {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) {
      throw const InvalidCityException('City name cannot be empty.');
    }

    final effectiveOpenWeatherKey = (openWeatherApiKey != null && openWeatherApiKey.trim().isNotEmpty)
        ? openWeatherApiKey.trim()
        : ApiConfig.openWeatherApiKey;

    final effectiveWeatherApiKey = (apiKey != null && apiKey.trim().isNotEmpty)
        ? apiKey.trim()
        : ApiConfig.apiKey;

    final shouldTryOpenWeather = preferredProvider == 'openweather' ||
        (preferredProvider == 'auto' && effectiveOpenWeatherKey.isNotEmpty);

    final shouldTryWeatherApi = preferredProvider == 'weatherapi' ||
        (preferredProvider == 'auto' && effectiveWeatherApiKey.isNotEmpty);

    // 1. Try OpenWeatherMap (Matches official Huawei / local station temperatures)
    if (shouldTryOpenWeather && effectiveOpenWeatherKey.isNotEmpty) {
      try {
        return await _fetchFromOpenWeather(cleanCity, effectiveOpenWeatherKey);
      } catch (e) {
        if (e is SocketException || e is NoInternetException) {
          throw const NoInternetException();
        }
        if (preferredProvider == 'openweather' && e is InvalidCityException) {
          rethrow;
        }
        // Seamlessly continue to other providers if OpenWeather failed
      }
    }

    // 2. Try WeatherAPI.com
    if (shouldTryWeatherApi && effectiveWeatherApiKey.isNotEmpty) {
      try {
        return await _fetchFromWeatherApi(cleanCity, effectiveWeatherApiKey);
      } catch (e) {
        if (e is SocketException || e is NoInternetException) {
          throw const NoInternetException();
        }
        if (preferredProvider == 'weatherapi' && e is InvalidCityException) {
          rethrow;
        }
        // Fall back to Open-Meteo
      }
    }

    // 3. Fallback to Open-Meteo (100% Free, zero-key REST API)
    return await _fetchFromOpenMeteo(cleanCity);
  }

  /// Calls OpenWeatherMap (https://openweathermap.org/) current weather and 5-day forecast
  Future<WeatherSnapshot> _fetchFromOpenWeather(String city, String apiKey) async {
    http.Response currentRes;
    String? resolvedRegion;

    try {
      final currentUri = Uri.parse(
        '${ApiConfig.openWeatherCurrentUrl}?q=${Uri.encodeComponent(city)}&units=metric&appid=$apiKey',
      );
      currentRes = await _client.get(currentUri).timeout(ApiConfig.requestTimeout);

      // If city name query returns 404, resolve via coordinate geocoding
      if (currentRes.statusCode == 404) {
        double? lat;
        double? lon;

        final pkMatch = PakistanCitiesDatabase.cities.where(
          (c) => c.name.toLowerCase() == city.toLowerCase(),
        );

        if (pkMatch.isNotEmpty) {
          lat = pkMatch.first.latitude;
          lon = pkMatch.first.longitude;
          resolvedRegion = pkMatch.first.province;
        } else {
          try {
            final geoUri = Uri.parse(
              '${ApiConfig.openMeteoGeocodingUrl}?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
            );
            final geoRes = await _client.get(geoUri).timeout(ApiConfig.requestTimeout);
            if (geoRes.statusCode == 200) {
              final geoData = jsonDecode(geoRes.body) as Map<String, dynamic>;
              final results = geoData['results'] as List<dynamic>?;
              if (results != null && results.isNotEmpty) {
                final first = results[0] as Map<String, dynamic>;
                lat = (first['latitude'] as num?)?.toDouble();
                lon = (first['longitude'] as num?)?.toDouble();
                resolvedRegion = first['admin1']?.toString();
              }
            }
          } catch (_) {}
        }

        if (lat != null && lon != null) {
          final coordCurrentUri = Uri.parse(
            '${ApiConfig.openWeatherCurrentUrl}?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
          );
          currentRes = await _client.get(coordCurrentUri).timeout(ApiConfig.requestTimeout);

          if (currentRes.statusCode == 200) {
            final coordForecastUri = Uri.parse(
              '${ApiConfig.openWeatherForecastUrl}?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
            );
            final forecastRes = await _client.get(coordForecastUri).timeout(ApiConfig.requestTimeout);

            final currentJson = jsonDecode(currentRes.body) as Map<String, dynamic>;
            final forecastJson = forecastRes.statusCode == 200
                ? jsonDecode(forecastRes.body) as Map<String, dynamic>
                : <String, dynamic>{'list': []};

            return WeatherSnapshot.fromOpenWeatherJson(
              currentJson: currentJson,
              forecastJson: forecastJson,
              region: resolvedRegion,
            );
          }
        }

        throw InvalidCityException('Location "$city" not found on OpenWeatherMap.');
      }

      if (currentRes.statusCode == 401 || currentRes.statusCode == 403) {
        throw const ApiKeyException('Invalid OpenWeatherMap API Key. Please verify your key.');
      } else if (currentRes.statusCode == 429) {
        throw const RateLimitException('OpenWeatherMap API rate limit exceeded.');
      } else if (currentRes.statusCode != 200) {
        throw WeatherApiException('OpenWeatherMap error (HTTP ${currentRes.statusCode})');
      }

      // Fetch 5-Day/3-Hour Forecast
      final forecastUri = Uri.parse(
        '${ApiConfig.openWeatherForecastUrl}?q=${Uri.encodeComponent(city)}&units=metric&appid=$apiKey',
      );
      final forecastRes = await _client.get(forecastUri).timeout(ApiConfig.requestTimeout);

      final currentJson = jsonDecode(currentRes.body) as Map<String, dynamic>;
      final forecastJson = forecastRes.statusCode == 200
          ? jsonDecode(forecastRes.body) as Map<String, dynamic>
          : <String, dynamic>{'list': []};

      return WeatherSnapshot.fromOpenWeatherJson(
        currentJson: currentJson,
        forecastJson: forecastJson,
        region: resolvedRegion,
      );
    } on TimeoutException {
      throw const ServerTimeoutException('OpenWeatherMap request timed out.');
    } on SocketException {
      throw const NoInternetException();
    }
  }

  /// Calls WeatherAPI.com forecast REST endpoint
  Future<WeatherSnapshot> _fetchFromWeatherApi(String city, String apiKey) async {
    final uri = Uri.parse(
      '${ApiConfig.weatherApiForecastEndpoint}?key=$apiKey&q=${Uri.encodeComponent(city)}&days=3&aqi=yes&alerts=yes',
    );

    http.Response response;
    try {
      response = await _client.get(uri).timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw const ServerTimeoutException('WeatherAPI request timed out.');
    } on SocketException {
      throw const NoInternetException();
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherSnapshot.fromWeatherApiJson(decoded);
    }

    // Inspect error response
    try {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      final err = errorJson['error'] as Map<String, dynamic>?;
      final code = err?['code'] as int?;
      final msg = err?['message']?.toString() ?? 'Weather API error';

      if (code == 1006 || response.statusCode == 400) {
        throw InvalidCityException('Location "$city" not found. Please verify the city name.');
      } else if (code == 1002 || code == 2006 || code == 2008 || response.statusCode == 401 || response.statusCode == 403) {
        throw ApiKeyException(msg);
      } else if (code == 2007 || response.statusCode == 429) {
        throw RateLimitException(msg);
      }
      throw WeatherApiException(msg, statusCode: response.statusCode);
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Failed with status ${response.statusCode}');
    }
  }

  /// Calls Open-Meteo REST API (Zero API key needed, highly reliable fallback)
  Future<WeatherSnapshot> _fetchFromOpenMeteo(String city) async {
    // 1. Resolve coordinates: Check local Pakistan database first
    double? lat;
    double? lon;
    String resolvedName = city;
    String region = '';
    String country = 'Pakistan';

    final pkMatch = PakistanCitiesDatabase.cities.where(
      (c) => c.name.toLowerCase() == city.toLowerCase(),
    );

    if (pkMatch.isNotEmpty) {
      final matched = pkMatch.first;
      lat = matched.latitude;
      lon = matched.longitude;
      resolvedName = matched.name;
      region = matched.province;
      country = 'Pakistan';
    } else {
      // Query Open-Meteo Geocoding
      try {
        final geoUri = Uri.parse(
          '${ApiConfig.openMeteoGeocodingUrl}?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
        );
        final geoRes = await _client.get(geoUri).timeout(ApiConfig.requestTimeout);
        if (geoRes.statusCode == 200) {
          final geoData = jsonDecode(geoRes.body) as Map<String, dynamic>;
          final results = geoData['results'] as List<dynamic>?;
          if (results != null && results.isNotEmpty) {
            final first = results[0] as Map<String, dynamic>;
            lat = (first['latitude'] as num?)?.toDouble();
            lon = (first['longitude'] as num?)?.toDouble();
            resolvedName = first['name']?.toString() ?? city;
            region = first['admin1']?.toString() ?? '';
            country = first['country']?.toString() ?? 'Pakistan';
          }
        }
      } on SocketException {
        throw const NoInternetException();
      } catch (_) {}
    }

    if (lat == null || lon == null) {
      throw InvalidCityException('City "$city" not found. Please try another location.');
    }

    // 2. Fetch Open-Meteo forecast
    final forecastUri = Uri.parse(
      '${ApiConfig.openMeteoForecastUrl}?'
      'latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m'
      '&hourly=temperature_2m,precipitation_probability,weather_code,is_day'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_probability_max'
      '&timezone=auto',
    );

    http.Response response;
    try {
      response = await _client.get(forecastUri).timeout(ApiConfig.requestTimeout);
    } on TimeoutException {
      throw const ServerTimeoutException('Open-Meteo forecast request timed out.');
    } on SocketException {
      throw const NoInternetException();
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherSnapshot.fromOpenMeteoJson(
        json: decoded,
        cityName: resolvedName,
        region: region,
        country: country,
      );
    }

    throw WeatherApiException('Failed to retrieve forecast (HTTP ${response.statusCode})');
  }

  /// Live search for cities matching the search query
  Future<List<LocationSuggestion>> searchCities(
    String query, {
    String? openWeatherApiKey,
    String? apiKey,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    // Local instant Pakistan cities match
    final localMatches = PakistanCitiesDatabase.search(cleanQuery).map(
      (c) => LocationSuggestion(
        name: c.name,
        region: c.province,
        country: 'Pakistan',
        latitude: c.latitude,
        longitude: c.longitude,
      ),
    ).toList();

    final effectiveOpenWeatherKey = (openWeatherApiKey != null && openWeatherApiKey.trim().isNotEmpty)
        ? openWeatherApiKey.trim()
        : ApiConfig.openWeatherApiKey;

    final effectiveWeatherApiKey = (apiKey != null && apiKey.trim().isNotEmpty)
        ? apiKey.trim()
        : ApiConfig.apiKey;

    final Map<String, LocationSuggestion> mergedMap = {};
    for (final s in localMatches) {
      mergedMap['${s.name}_${s.region}'.toLowerCase()] = s;
    }

    // 1. OpenWeather direct geocoding if key is present
    if (effectiveOpenWeatherKey.isNotEmpty) {
      try {
        final uri = Uri.parse(
          '${ApiConfig.openWeatherGeocodingUrl}?q=${Uri.encodeComponent(cleanQuery)}&limit=5&appid=$effectiveOpenWeatherKey',
        );
        final res = await _client.get(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body) as List<dynamic>;
          for (final item in list) {
            final s = LocationSuggestion.fromOpenWeatherJson(item as Map<String, dynamic>);
            mergedMap['${s.name}_${s.region}'.toLowerCase()] = s;
          }
          if (mergedMap.length > localMatches.length) {
            return mergedMap.values.toList();
          }
        }
      } catch (_) {}
    }

    // 2. If WeatherAPI key is available, query WeatherAPI search endpoint
    if (effectiveWeatherApiKey.isNotEmpty) {
      try {
        final uri = Uri.parse(
          '${ApiConfig.weatherApiSearchEndpoint}?key=$effectiveWeatherApiKey&q=${Uri.encodeComponent(cleanQuery)}',
        );
        final res = await _client.get(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body) as List<dynamic>;
          for (final item in list) {
            final s = LocationSuggestion.fromWeatherApiJson(item as Map<String, dynamic>);
            mergedMap['${s.name}_${s.region}'.toLowerCase()] = s;
          }
          return mergedMap.values.toList();
        }
      } catch (_) {}
    }

    // 3. Geocoding fallback via Open-Meteo
    try {
      final geoUri = Uri.parse(
        '${ApiConfig.openMeteoGeocodingUrl}?name=${Uri.encodeComponent(cleanQuery)}&count=8&language=en&format=json',
      );
      final res = await _client.get(geoUri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null) {
          for (final item in results) {
            final s = LocationSuggestion.fromOpenMeteoJson(item as Map<String, dynamic>);
            mergedMap['${s.name}_${s.region}'.toLowerCase()] = s;
          }
          return mergedMap.values.toList();
        }
      }
    } catch (_) {}

    return mergedMap.values.toList();
  }

  /// Fetches weather by GPS coordinates directly (for Device GPS Auto-Location)
  Future<WeatherSnapshot> fetchWeatherByCoordinates({
    required double latitude,
    required double longitude,
    String cityName = '',
    String region = '',
    String country = '',
    String? openWeatherApiKey,
    String? apiKey,
    String preferredProvider = 'auto',
  }) async {
    final effectiveOpenWeatherKey = (openWeatherApiKey != null && openWeatherApiKey.trim().isNotEmpty)
        ? openWeatherApiKey.trim()
        : ApiConfig.openWeatherApiKey;

    final shouldTryOpenWeather = preferredProvider == 'openweather' ||
        (preferredProvider == 'auto' && effectiveOpenWeatherKey.isNotEmpty);

    // 1. Try OpenWeatherMap with coordinates
    if (shouldTryOpenWeather && effectiveOpenWeatherKey.isNotEmpty) {
      try {
        final currentUri = Uri.parse(
          '${ApiConfig.openWeatherCurrentUrl}?lat=$latitude&lon=$longitude&units=metric&appid=$effectiveOpenWeatherKey',
        );
        final currentRes = await _client.get(currentUri).timeout(ApiConfig.requestTimeout);

        if (currentRes.statusCode == 200) {
          final forecastUri = Uri.parse(
            '${ApiConfig.openWeatherForecastUrl}?lat=$latitude&lon=$longitude&units=metric&appid=$effectiveOpenWeatherKey',
          );
          final forecastRes = await _client.get(forecastUri).timeout(ApiConfig.requestTimeout);

          final currentJson = jsonDecode(currentRes.body) as Map<String, dynamic>;
          final forecastJson = forecastRes.statusCode == 200
              ? jsonDecode(forecastRes.body) as Map<String, dynamic>
              : <String, dynamic>{'list': []};

          return WeatherSnapshot.fromOpenWeatherJson(
            currentJson: currentJson,
            forecastJson: forecastJson,
            region: region.isNotEmpty ? region : null,
            cityNameOverride: cityName.isNotEmpty ? cityName : null,
          );
        }
      } catch (e) {
        if (e is SocketException) throw const NoInternetException();
      }
    }

    // 2. Fallback to Open-Meteo with coordinates
    final forecastUri = Uri.parse(
      '${ApiConfig.openMeteoForecastUrl}?'
      'latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m'
      '&hourly=temperature_2m,precipitation_probability,weather_code,is_day'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_probability_max'
      '&timezone=auto',
    );

    final response = await _client.get(forecastUri).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherSnapshot.fromOpenMeteoJson(
        json: decoded,
        cityName: cityName.isNotEmpty ? cityName : 'Current Location',
        region: region,
        country: country.isNotEmpty ? country : 'GPS',
      );
    }

    throw WeatherApiException('Failed to fetch weather for GPS coordinates (HTTP ${response.statusCode})');
  }

  void dispose() {
    _client.close();
  }
}
