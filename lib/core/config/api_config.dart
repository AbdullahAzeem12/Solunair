/// Configuration for Solunair Weather API integration.
///
/// HOW TO ADD YOUR OPENWEATHERMAP OR WEATHERAPI.COM API KEY:
/// ============================================================================
/// 1. OPENWEATHERMAP KEY:
///    Paste your key into [defaultOpenWeatherApiKey] below!
///    Or enter it inside the app in the Settings screen!
///    Or pass at build time: `flutter run --dart-define=OPENWEATHER_API_KEY=your_key`
///
/// 2. WEATHERAPI.COM KEY:
///    Paste your key into [defaultWeatherApiKey] below!
///
/// If no key is set or if an API quota is exceeded, the app automatically uses
/// Open-Meteo REST API (100% free, no key needed) so it always works.
/// ============================================================================
class ApiConfig {
  ApiConfig._();

  /// 🌟 PASTE YOUR OPENWEATHERMAP (openweathermap.org) API KEY HERE:
  static const String defaultOpenWeatherApiKey = '3c0c4b3eff5aab304ae42ff28d76e4dd';

  /// 🌟 PASTE YOUR WEATHERAPI.COM API KEY HERE:
  static const String defaultWeatherApiKey = '5cde32e745d04736b3c135018261310';

  /// Get OpenWeatherMap API key (environment variable or default constant)
  static String get openWeatherApiKey {
    const envKey = String.fromEnvironment('OPENWEATHER_API_KEY');
    if (envKey.isNotEmpty) return envKey;
    return defaultOpenWeatherApiKey;
  }

  /// Get WeatherAPI.com key (environment variable or default constant)
  static String get apiKey {
    const envKey = String.fromEnvironment('WEATHER_API_KEY');
    if (envKey.isNotEmpty) return envKey;
    return defaultWeatherApiKey;
  }

  /// OpenWeatherMap Endpoints (https://openweathermap.org/)
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String openWeatherCurrentUrl = '$openWeatherBaseUrl/weather';
  static const String openWeatherForecastUrl = '$openWeatherBaseUrl/forecast';
  static const String openWeatherGeocodingUrl = 'https://api.openweathermap.org/geo/1.0/direct';

  /// WeatherAPI.com Endpoints
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String weatherApiForecastEndpoint = '$weatherApiBaseUrl/forecast.json';
  static const String weatherApiSearchEndpoint = '$weatherApiBaseUrl/search.json';

  /// Open-Meteo Endpoints (Free, No Key Required Fallback)
  static const String openMeteoForecastUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String openMeteoGeocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  /// Network Timeout
  static const Duration requestTimeout = Duration(seconds: 12);

  /// Default starting city for Pakistan
  static const String defaultCity = 'Islamabad';
}
