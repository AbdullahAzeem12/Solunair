import 'package:flutter/material.dart';
import '../../../core/models/weather_models.dart';
import '../../../core/repositories/weather_repository.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../core/utils/weather_condition_mapper.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';

/// Central state controller for Solunair Weather Application
class WeatherController extends ChangeNotifier {
  final WeatherRepository _repository;
  final PreferencesService _prefs;

  WeatherSnapshot? _snapshot;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  String _selectedCity = 'Islamabad';
  String _themeMode = 'adaptive';
  String _tempUnit = 'C';
  String _windUnit = 'kph';
  String _pressureUnit = 'hpa';
  String _animationMode = 'high';

  List<String> _recentSearches = [];
  List<String> _favorites = [];

  // GPS Location state
  bool _isGpsActive = false;
  bool _isDetectingLocation = false;
  String? _gpsError;
  double? _gpsLatitude;
  double? _gpsLongitude;

  // Notification state
  bool _notificationsEnabled = true;

  // Extended professional settings
  String _autoRefreshInterval = '30m';
  bool _morningBriefingEnabled = true;
  bool _eveningOutlookEnabled = true;
  bool _aqiAlertsEnabled = true;
  bool _uvAlertsEnabled = true;
  bool _hapticFeedbackEnabled = true;

  WeatherController({
    required WeatherRepository repository,
    required PreferencesService prefs,
  })  : _repository = repository,
        _prefs = prefs {
    _loadSettings();
  }

  WeatherSnapshot? get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  String get selectedCity => _selectedCity;
  String get themeMode => _themeMode;
  String get tempUnit => _tempUnit;
  String get windUnit => _windUnit;
  String get pressureUnit => _pressureUnit;
  String get animationMode => _animationMode;

  List<String> get recentSearches => _recentSearches;
  List<String> get favorites => _favorites;
  bool get isFavorite => _prefs.isFavorite(_selectedCity);

  // GPS Location getters
  bool get isGpsActive => _isGpsActive;
  bool get isDetectingLocation => _isDetectingLocation;
  String? get gpsError => _gpsError;
  double? get gpsLatitude => _gpsLatitude;
  double? get gpsLongitude => _gpsLongitude;

  // Notification getters
  bool get notificationsEnabled => _notificationsEnabled;

  // Professional settings getters
  String get autoRefreshInterval => _autoRefreshInterval;
  bool get morningBriefingEnabled => _morningBriefingEnabled;
  bool get eveningOutlookEnabled => _eveningOutlookEnabled;
  bool get aqiAlertsEnabled => _aqiAlertsEnabled;
  bool get uvAlertsEnabled => _uvAlertsEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  void _loadSettings() {
    _selectedCity = _prefs.getSelectedCity();
    _themeMode = _prefs.getThemeMode();
    _tempUnit = _prefs.getTemperatureUnit();
    _windUnit = _prefs.getWindSpeedUnit();
    _pressureUnit = _prefs.getPressureUnit();
    _animationMode = _prefs.getAnimationMode();
    _recentSearches = _prefs.getRecentSearches();
    _favorites = _prefs.getFavorites();
    _isGpsActive = _prefs.isGpsLocationEnabled();
    _notificationsEnabled = _prefs.isNotificationsEnabled();
    _gpsLatitude = _prefs.getLastGpsLatitude();
    _gpsLongitude = _prefs.getLastGpsLongitude();

    _autoRefreshInterval = _prefs.getAutoRefreshInterval();
    _morningBriefingEnabled = _prefs.isMorningBriefingEnabled();
    _eveningOutlookEnabled = _prefs.isEveningOutlookEnabled();
    _aqiAlertsEnabled = _prefs.isAqiAlertsEnabled();
    _uvAlertsEnabled = _prefs.isUvAlertsEnabled();
    _hapticFeedbackEnabled = _prefs.isHapticFeedbackEnabled();

    // Instant load last cached weather for immediate 0ms rendering
    _snapshot = _prefs.getCachedWeather(_selectedCity) ?? _prefs.getLastCachedWeather();
  }

  /// Initial weather fetch
  Future<void> initWeather() async {
    // If we have cached snapshot, render it immediately
    if (_snapshot == null) {
      _isLoading = true;
      notifyListeners();
    }

    // If GPS is enabled, try to use GPS location first
    if (_isGpsActive) {
      await _fetchWeatherFromGps(forceRefresh: false);
    } else {
      await _fetchData(_selectedCity, forceRefresh: false);
    }
  }

  /// Change active city (disables GPS mode)
  Future<void> changeCity(String newCity) async {
    final clean = newCity.trim();
    if (clean.isEmpty) return;

    _selectedCity = clean;
    _isGpsActive = false; // Manual city selection disables GPS mode
    await _prefs.setGpsLocationEnabled(false);
    await _prefs.setSelectedCity(clean);
    await _prefs.addRecentSearch(clean);
    _recentSearches = _prefs.getRecentSearches();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _fetchData(clean, forceRefresh: false);
  }

  /// Manual refresh
  Future<void> refreshWeather() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    if (_isGpsActive) {
      await _fetchWeatherFromGps(forceRefresh: true);
    } else {
      await _fetchData(_selectedCity, forceRefresh: true);
    }
    _isRefreshing = false;
    notifyListeners();
  }

  // ===========================================================================
  // GPS AUTO-LOCATION
  // ===========================================================================

  /// Use device GPS to detect location and fetch weather
  Future<void> useGpsLocation() async {
    _isDetectingLocation = true;
    _gpsError = null;
    notifyListeners();

    final result = await LocationService.getCurrentLocation(
      fallbackLatitude: _gpsLatitude ?? _prefs.getLastGpsLatitude(),
      fallbackLongitude: _gpsLongitude ?? _prefs.getLastGpsLongitude(),
    );

    if (result.success) {
      _isGpsActive = true;
      _gpsLatitude = result.latitude;
      _gpsLongitude = result.longitude;
      _gpsError = null;

      await _prefs.setLastGpsCoordinates(result.latitude, result.longitude);
      if (result.cityName.isNotEmpty) {
        _selectedCity = result.cityName;
        await _prefs.setSelectedCity(result.cityName);
      }
      await _prefs.setGpsLocationEnabled(true);

      _isDetectingLocation = false;
      _isLoading = true;
      notifyListeners();

      await _fetchWeatherFromGps(forceRefresh: true);
    } else {
      _isDetectingLocation = false;
      _gpsError = result.errorMessage;
      notifyListeners();
    }
  }

  /// Disable GPS mode and revert to manual city selection
  Future<void> disableGpsLocation() async {
    _isGpsActive = false;
    _gpsLatitude = null;
    _gpsLongitude = null;
    _gpsError = null;
    await _prefs.setGpsLocationEnabled(false);
    notifyListeners();
  }

  /// Fetch weather using GPS coordinates
  Future<void> _fetchWeatherFromGps({required bool forceRefresh}) async {
    if (_gpsLatitude != null && _gpsLongitude != null) {
      try {
        final data = await _repository.getWeatherByCoordinates(
          latitude: _gpsLatitude!,
          longitude: _gpsLongitude!,
          cityName: _selectedCity,
          forceRefresh: forceRefresh,
        );
        _snapshot = data;
        _selectedCity = data.cityName;
        _errorMessage = null;
        _gpsError = null;

        // Check for severe weather alerts
        _checkSevereWeatherAlerts(data);
      } catch (e) {
        if (_snapshot == null) {
          _errorMessage = e.toString();
        }
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // Try to detect GPS location first with fallback coordinates
      final result = await LocationService.getCurrentLocation(
        fallbackLatitude: _gpsLatitude ?? _prefs.getLastGpsLatitude(),
        fallbackLongitude: _gpsLongitude ?? _prefs.getLastGpsLongitude(),
      );
      if (result.success) {
        _gpsLatitude = result.latitude;
        _gpsLongitude = result.longitude;
        _gpsError = null;
        await _prefs.setLastGpsCoordinates(result.latitude, result.longitude);
        if (result.cityName.isNotEmpty) {
          _selectedCity = result.cityName;
          await _prefs.setSelectedCity(result.cityName);
        }
        await _fetchWeatherFromGps(forceRefresh: forceRefresh);
      } else {
        // GPS failed, fall back to city-based fetch
        _gpsError = result.errorMessage;
        await _fetchData(_selectedCity, forceRefresh: forceRefresh);
      }
    }
  }

  Future<void> _fetchData(String city, {required bool forceRefresh}) async {
    try {
      final data = await _repository.getWeather(city, forceRefresh: forceRefresh);
      _snapshot = data;
      _errorMessage = null;

      // Check for severe weather alerts
      _checkSevereWeatherAlerts(data);
    } on InvalidCityException catch (e) {
      _errorMessage = e.message;
    } on NoInternetException catch (e) {
      // Retain existing snapshot if available
      if (_snapshot == null) {
        _errorMessage = e.message;
      }
    } catch (e) {
      if (_snapshot == null) {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // SEVERE WEATHER NOTIFICATIONS
  // ===========================================================================

  /// Check weather data for severe conditions and trigger alerts
  void _checkSevereWeatherAlerts(WeatherSnapshot data) {
    if (_notificationsEnabled) {
      NotificationService.checkAndNotifySevereWeather(data);
    }
  }

  /// Toggle notification alerts on/off
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setNotificationsEnabled(enabled);
    if (!enabled) {
      await NotificationService.cancelAll();
    }
    notifyListeners();
  }

  /// Send a test weather alert notification
  Future<void> sendTestNotification() async {
    await NotificationService.showTestNotification();
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    return await NotificationService.requestPermission();
  }

  // ===========================================================================
  // EXISTING METHODS
  // ===========================================================================

  /// Toggle Favorite
  Future<void> toggleFavoriteCity(String city) async {
    await _prefs.toggleFavorite(city);
    _favorites = _prefs.getFavorites();
    notifyListeners();
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    await _prefs.clearRecentSearches();
    _recentSearches = [];
    notifyListeners();
  }

  /// Search matching cities via repository
  Future<List<LocationSuggestion>> searchCities(String query) async {
    return await _repository.searchCities(query);
  }

  /// Remove single recent search
  Future<void> removeRecentSearch(String city) async {
    await _prefs.removeRecentSearch(city);
    _recentSearches = _prefs.getRecentSearches();
    notifyListeners();
  }

  /// Theme Settings
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs.setThemeMode(mode);
    notifyListeners();
  }

  /// Temperature Unit
  Future<void> setTemperatureUnit(String unit) async {
    _tempUnit = unit;
    await _prefs.setTemperatureUnit(unit);
    notifyListeners();
  }

  /// Wind Unit
  Future<void> setWindSpeedUnit(String unit) async {
    _windUnit = unit;
    await _prefs.setWindSpeedUnit(unit);
    notifyListeners();
  }

  /// Pressure Unit
  Future<void> setPressureUnit(String unit) async {
    _pressureUnit = unit;
    await _prefs.setPressureUnit(unit);
    notifyListeners();
  }

  /// Animation Mode ('high', 'reduced', 'saver')
  Future<void> setAnimationMode(String mode) async {
    _animationMode = mode;
    await _prefs.setAnimationMode(mode);
    notifyListeners();
  }

  /// Auto Refresh Interval ('15m', '30m', '1h', 'manual')
  Future<void> setAutoRefreshInterval(String interval) async {
    _autoRefreshInterval = interval;
    await _prefs.setAutoRefreshInterval(interval);
    notifyListeners();
  }

  /// Morning Briefing
  Future<void> setMorningBriefingEnabled(bool val) async {
    _morningBriefingEnabled = val;
    await _prefs.setMorningBriefingEnabled(val);
    notifyListeners();
  }

  /// Evening Outlook
  Future<void> setEveningOutlookEnabled(bool val) async {
    _eveningOutlookEnabled = val;
    await _prefs.setEveningOutlookEnabled(val);
    notifyListeners();
  }

  /// AQI Alerts
  Future<void> setAqiAlertsEnabled(bool val) async {
    _aqiAlertsEnabled = val;
    await _prefs.setAqiAlertsEnabled(val);
    notifyListeners();
  }

  /// UV Solar Alerts
  Future<void> setUvAlertsEnabled(bool val) async {
    _uvAlertsEnabled = val;
    await _prefs.setUvAlertsEnabled(val);
    notifyListeners();
  }

  /// Haptic Feedback
  Future<void> setHapticFeedbackEnabled(bool val) async {
    _hapticFeedbackEnabled = val;
    await _prefs.setHapticFeedbackEnabled(val);
    notifyListeners();
  }

  /// Custom API Key (WeatherAPI.com)
  Future<void> setCustomApiKey(String? key) async {
    await _prefs.setCustomApiKey(key);
    notifyListeners();
    // Refresh weather with new key
    refreshWeather();
  }

  String? get customApiKey => _prefs.getCustomApiKey();

  /// OpenWeatherMap API Key
  Future<void> setOpenWeatherApiKey(String? key) async {
    await _prefs.setOpenWeatherApiKey(key);
    notifyListeners();
    refreshWeather();
  }

  String? get openWeatherApiKey => _prefs.getOpenWeatherApiKey();

  /// Preferred Weather Provider ('auto', 'openweather', 'weatherapi', 'openmeteo')
  String get preferredProvider => _prefs.getPreferredProvider();

  Future<void> setPreferredProvider(String provider) async {
    await _prefs.setPreferredProvider(provider);
    notifyListeners();
    refreshWeather();
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _prefs.clearCache();
    refreshWeather();
  }

  // ===========================================================================
  // COMPUTED THEME & VISUAL GETTERS
  // ===========================================================================

  bool get isDayEffective {
    if (_themeMode == 'light') return true;
    if (_themeMode == 'dark') return false;
    if (_snapshot != null) return _snapshot!.isDay;
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 19;
  }

  WeatherType get currentWeatherType {
    if (_snapshot != null) {
      return WeatherConditionMapper.resolve(
        conditionText: _snapshot!.conditionText,
        conditionCode: _snapshot!.conditionCode,
        isDay: isDayEffective,
      );
    }
    return isDayEffective ? WeatherType.sunny : WeatherType.clearNight;
  }

  List<Color> get backgroundGradient {
    return WeatherConditionMapper.getBackgroundGradient(currentWeatherType);
  }

  Color get ambientGlow {
    return WeatherConditionMapper.getAmbientGlowColor(currentWeatherType);
  }
}

