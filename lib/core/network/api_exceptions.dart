/// Exceptions for weather REST API operations
class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  const WeatherApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class InvalidCityException extends WeatherApiException {
  const InvalidCityException([super.message = 'City not found. Please check spelling or select from Pakistani cities.'])
      : super(statusCode: 400);
}

class NoInternetException extends WeatherApiException {
  const NoInternetException([super.message = 'No internet connection detected. Showing cached forecast.']);
}

class ApiKeyException extends WeatherApiException {
  const ApiKeyException([super.message = 'Invalid or missing API key. Please check your WeatherAPI key in Settings.'])
      : super(statusCode: 401);
}

class RateLimitException extends WeatherApiException {
  const RateLimitException([super.message = 'API request quota reached. Switched to backup provider.'])
      : super(statusCode: 429);
}

class ServerTimeoutException extends WeatherApiException {
  const ServerTimeoutException([super.message = 'Weather service request timed out. Please retry.']);
}
