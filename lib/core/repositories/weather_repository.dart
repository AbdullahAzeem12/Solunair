import '../models/weather_models.dart';
import '../network/weather_api_client.dart';
import '../network/api_exceptions.dart';
import '../storage/preferences_service.dart';

abstract class WeatherRepository {
  Future<WeatherSnapshot> getWeather(String city, {bool forceRefresh = false});
  Future<WeatherSnapshot> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
    String cityName = '',
    String region = '',
    String country = '',
    bool forceRefresh = false,
  });
  Future<List<LocationSuggestion>> searchCities(String query);
  WeatherSnapshot? getCachedWeather(String city);
  WeatherSnapshot? getLastCachedWeather();
}

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiClient _apiClient;
  final PreferencesService _prefs;

  // In-flight request deduplication map
  final Map<String, Future<WeatherSnapshot>> _inFlightRequests = {};

  WeatherRepositoryImpl({
    required WeatherApiClient apiClient,
    required PreferencesService prefs,
  })  : _apiClient = apiClient,
        _prefs = prefs;

  @override
  Future<WeatherSnapshot> getWeather(String city, {bool forceRefresh = false}) async {
    final cleanCity = city.trim();
    final cacheKey = cleanCity.toLowerCase();

    // 1. Check in-memory in-flight requests to deduplicate rapid multiple calls
    if (!forceRefresh && _inFlightRequests.containsKey(cacheKey)) {
      return await _inFlightRequests[cacheKey]!;
    }

    // 2. If not forcing refresh, check if we have a fresh cached snapshot (< 15 mins)
    if (!forceRefresh) {
      final cached = _prefs.getCachedWeather(cleanCity);
      if (cached != null) {
        final age = DateTime.now().difference(cached.lastUpdated);
        if (age.inMinutes < 15) {
          return cached;
        }
      }
    }

    // 3. Dispatch fresh network request
    final future = _fetchAndCache(cleanCity);
    _inFlightRequests[cacheKey] = future;

    try {
      final snapshot = await future;
      return snapshot;
    } finally {
      _inFlightRequests.remove(cacheKey);
    }
  }

  Future<WeatherSnapshot> _fetchAndCache(String city) async {
    final customKey = _prefs.getCustomApiKey();
    final openWeatherKey = _prefs.getOpenWeatherApiKey();
    final preferred = _prefs.getPreferredProvider();

    try {
      final freshSnapshot = await _apiClient.fetchWeather(
        city: city,
        openWeatherApiKey: openWeatherKey,
        apiKey: customKey,
        preferredProvider: preferred,
      );

      // Save to persistent cache
      await _prefs.cacheWeather(city, freshSnapshot);
      return freshSnapshot;
    } on NoInternetException {
      // Offline fallback
      final cached = _prefs.getCachedWeather(city) ?? _prefs.getLastCachedWeather();
      if (cached != null) {
        return cached;
      }
      return WeatherSnapshot.createDefaultFallback(cityName: city);
    } on InvalidCityException {
      rethrow;
    } catch (e) {
      // Check cache on server timeout or other unexpected failures
      final cached = _prefs.getCachedWeather(city) ?? _prefs.getLastCachedWeather();
      if (cached != null) {
        return cached;
      }
      return WeatherSnapshot.createDefaultFallback(cityName: city);
    }
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
    final cacheKey = cityName.isNotEmpty ? cityName.toLowerCase() : 'gps_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    if (!forceRefresh) {
      final cached = _prefs.getCachedWeather(cacheKey);
      if (cached != null) {
        final age = DateTime.now().difference(cached.lastUpdated);
        if (age.inMinutes < 15) {
          return cached;
        }
      }
    }

    final openWeatherKey = _prefs.getOpenWeatherApiKey();
    final customKey = _prefs.getCustomApiKey();
    final preferred = _prefs.getPreferredProvider();

    try {
      final snapshot = await _apiClient.fetchWeatherByCoordinates(
        latitude: latitude,
        longitude: longitude,
        cityName: cityName,
        region: region,
        country: country,
        openWeatherApiKey: openWeatherKey,
        apiKey: customKey,
        preferredProvider: preferred,
      );

      await _prefs.cacheWeather(cacheKey, snapshot);
      return snapshot;
    } on NoInternetException {
      final cached = _prefs.getCachedWeather(cacheKey) ?? _prefs.getLastCachedWeather();
      if (cached != null) return cached;
      return WeatherSnapshot.createDefaultFallback(cityName: cityName.isNotEmpty ? cityName : 'Current Location');
    } catch (e) {
      final cached = _prefs.getCachedWeather(cacheKey) ?? _prefs.getLastCachedWeather();
      if (cached != null) return cached;
      return WeatherSnapshot.createDefaultFallback(cityName: cityName.isNotEmpty ? cityName : 'Current Location');
    }
  }

  @override
  Future<List<LocationSuggestion>> searchCities(String query) async {
    final customKey = _prefs.getCustomApiKey();
    final openWeatherKey = _prefs.getOpenWeatherApiKey();
    return await _apiClient.searchCities(
      query,
      openWeatherApiKey: openWeatherKey,
      apiKey: customKey,
    );
  }

  @override
  WeatherSnapshot? getCachedWeather(String city) {
    return _prefs.getCachedWeather(city);
  }

  @override
  WeatherSnapshot? getLastCachedWeather() {
    return _prefs.getLastCachedWeather();
  }
}
