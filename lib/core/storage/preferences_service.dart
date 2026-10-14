import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

/// Local persistent storage service using SharedPreferences
class PreferencesService {
  static const String _keyRecentSearches = 'recent_searches';
  static const String _keyFavorites = 'favorite_cities';
  static const String _keySelectedCity = 'selected_city';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyTempUnit = 'temp_unit';
  static const String _keyWindUnit = 'wind_unit';
  static const String _keyPressureUnit = 'pressure_unit';
  static const String _keyAnimationMode = 'animation_mode';
  static const String _keyCustomApiKey = 'custom_api_key';
  static const String _keyOpenWeatherApiKey = 'openweather_api_key';
  static const String _keyPreferredProvider = 'preferred_provider';
  static const String _keyWeatherCachePrefix = 'weather_cache_';
  static const String _keyGpsLocationEnabled = 'gps_location_enabled';
  static const String _keyLastGpsLat = 'last_gps_latitude';
  static const String _keyLastGpsLon = 'last_gps_longitude';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyAutoRefreshInterval = 'auto_refresh_interval';
  static const String _keyMorningBriefing = 'morning_briefing';
  static const String _keyEveningOutlook = 'evening_outlook';
  static const String _keyAqiAlerts = 'aqi_alerts';
  static const String _keyUvAlerts = 'uv_alerts';
  static const String _keyHapticFeedback = 'haptic_feedback';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // ===========================================================================
  // RECENT SEARCHES (PDF Bonus Requirement)
  // ===========================================================================

  List<String> getRecentSearches() {
    return _prefs.getStringList(_keyRecentSearches) ?? ['Lahore', 'Karachi', 'Islamabad'];
  }

  Future<void> addRecentSearch(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;
    final current = getRecentSearches().toList();
    current.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    if (current.length > 10) {
      current.removeRange(10, current.length);
    }
    await _prefs.setStringList(_keyRecentSearches, current);
  }

  Future<void> removeRecentSearch(String city) async {
    final current = getRecentSearches().toList();
    current.removeWhere((item) => item.toLowerCase() == city.trim().toLowerCase());
    await _prefs.setStringList(_keyRecentSearches, current);
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_keyRecentSearches);
  }

  // ===========================================================================
  // FAVORITES
  // ===========================================================================

  List<String> getFavorites() {
    return _prefs.getStringList(_keyFavorites) ?? ['Islamabad', 'Lahore', 'Karachi', 'Murree'];
  }

  Future<bool> toggleFavorite(String city) async {
    final trimmed = city.trim();
    final current = getFavorites().toList();
    final exists = current.any((c) => c.toLowerCase() == trimmed.toLowerCase());
    if (exists) {
      current.removeWhere((c) => c.toLowerCase() == trimmed.toLowerCase());
      await _prefs.setStringList(_keyFavorites, current);
      return false;
    } else {
      current.add(trimmed);
      await _prefs.setStringList(_keyFavorites, current);
      return true;
    }
  }

  bool isFavorite(String city) {
    return getFavorites().any((c) => c.toLowerCase() == city.trim().toLowerCase());
  }

  // ===========================================================================
  // SELECTED CITY
  // ===========================================================================

  String getSelectedCity() {
    return _prefs.getString(_keySelectedCity) ?? 'Islamabad';
  }

  Future<void> setSelectedCity(String city) async {
    await _prefs.setString(_keySelectedCity, city.trim());
  }

  // ===========================================================================
  // GPS LOCATION
  // ===========================================================================

  bool isGpsLocationEnabled() {
    return _prefs.getBool(_keyGpsLocationEnabled) ?? false;
  }

  Future<void> setGpsLocationEnabled(bool enabled) async {
    await _prefs.setBool(_keyGpsLocationEnabled, enabled);
  }

  double? getLastGpsLatitude() {
    return _prefs.getDouble(_keyLastGpsLat) ?? 31.4772;
  }

  double? getLastGpsLongitude() {
    return _prefs.getDouble(_keyLastGpsLon) ?? 74.2467;
  }

  Future<void> setLastGpsCoordinates(double lat, double lon) async {
    await _prefs.setDouble(_keyLastGpsLat, lat);
    await _prefs.setDouble(_keyLastGpsLon, lon);
  }

  // ===========================================================================
  // NOTIFICATIONS
  // ===========================================================================

  bool isNotificationsEnabled() {
    return _prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // ===========================================================================
  // SETTINGS & CONFIG
  // ===========================================================================

  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'adaptive'; // adaptive, light, dark, system
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  String getTemperatureUnit() {
    return _prefs.getString(_keyTempUnit) ?? 'C'; // 'C' or 'F'
  }

  Future<void> setTemperatureUnit(String unit) async {
    await _prefs.setString(_keyTempUnit, unit);
  }

  String getWindSpeedUnit() {
    return _prefs.getString(_keyWindUnit) ?? 'kph'; // 'kph', 'mph', 'ms'
  }

  Future<void> setWindSpeedUnit(String unit) async {
    await _prefs.setString(_keyWindUnit, unit);
  }

  String getPressureUnit() {
    return _prefs.getString(_keyPressureUnit) ?? 'hpa'; // 'hpa', 'inhg'
  }

  Future<void> setPressureUnit(String unit) async {
    await _prefs.setString(_keyPressureUnit, unit);
  }

  String getAnimationMode() {
    return _prefs.getString(_keyAnimationMode) ?? 'high'; // 'high' or 'reduced'
  }

  Future<void> setAnimationMode(String mode) async {
    await _prefs.setString(_keyAnimationMode, mode);
  }

  String getAutoRefreshInterval() {
    return _prefs.getString(_keyAutoRefreshInterval) ?? '30m';
  }

  Future<void> setAutoRefreshInterval(String interval) async {
    await _prefs.setString(_keyAutoRefreshInterval, interval);
  }

  bool isMorningBriefingEnabled() {
    return _prefs.getBool(_keyMorningBriefing) ?? true;
  }

  Future<void> setMorningBriefingEnabled(bool enabled) async {
    await _prefs.setBool(_keyMorningBriefing, enabled);
  }

  bool isEveningOutlookEnabled() {
    return _prefs.getBool(_keyEveningOutlook) ?? true;
  }

  Future<void> setEveningOutlookEnabled(bool enabled) async {
    await _prefs.setBool(_keyEveningOutlook, enabled);
  }

  bool isAqiAlertsEnabled() {
    return _prefs.getBool(_keyAqiAlerts) ?? true;
  }

  Future<void> setAqiAlertsEnabled(bool enabled) async {
    await _prefs.setBool(_keyAqiAlerts, enabled);
  }

  bool isUvAlertsEnabled() {
    return _prefs.getBool(_keyUvAlerts) ?? true;
  }

  Future<void> setUvAlertsEnabled(bool enabled) async {
    await _prefs.setBool(_keyUvAlerts, enabled);
  }

  bool isHapticFeedbackEnabled() {
    return _prefs.getBool(_keyHapticFeedback) ?? true;
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    await _prefs.setBool(_keyHapticFeedback, enabled);
  }

  String? getCustomApiKey() {
    return _prefs.getString(_keyCustomApiKey);
  }

  Future<void> setCustomApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _prefs.remove(_keyCustomApiKey);
    } else {
      await _prefs.setString(_keyCustomApiKey, key.trim());
    }
  }

  String? getOpenWeatherApiKey() {
    return _prefs.getString(_keyOpenWeatherApiKey);
  }

  Future<void> setOpenWeatherApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _prefs.remove(_keyOpenWeatherApiKey);
    } else {
      await _prefs.setString(_keyOpenWeatherApiKey, key.trim());
    }
  }

  String getPreferredProvider() {
    return _prefs.getString(_keyPreferredProvider) ?? 'auto'; // 'auto', 'openweather', 'weatherapi', 'openmeteo'
  }

  Future<void> setPreferredProvider(String provider) async {
    await _prefs.setString(_keyPreferredProvider, provider);
  }

  // ===========================================================================
  // WEATHER CACHING
  // ===========================================================================

  Future<void> cacheWeather(String city, WeatherSnapshot snapshot) async {
    try {
      final jsonStr = jsonEncode(snapshot.toJson());
      await _prefs.setString('$_keyWeatherCachePrefix${city.toLowerCase()}', jsonStr);
      await _prefs.setString('${_keyWeatherCachePrefix}last_snapshot', jsonStr);
    } catch (_) {}
  }

  WeatherSnapshot? getCachedWeather(String city) {
    try {
      final jsonStr = _prefs.getString('$_keyWeatherCachePrefix${city.toLowerCase()}');
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return WeatherSnapshot.fromCachedJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  WeatherSnapshot? getLastCachedWeather() {
    try {
      final jsonStr = _prefs.getString('${_keyWeatherCachePrefix}last_snapshot');
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return WeatherSnapshot.fromCachedJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyWeatherCachePrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}

