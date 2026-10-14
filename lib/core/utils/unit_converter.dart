/// Utility for converting and formatting weather units.
class UnitConverter {
  UnitConverter._();

  /// Converts Celsius to Fahrenheit
  static double cToF(double celsius) => (celsius * 9.0 / 5.0) + 32.0;

  /// Converts Fahrenheit to Celsius
  static double fToC(double fahrenheit) => (fahrenheit - 32.0) * 5.0 / 9.0;

  /// Format temperature according to selected unit ('C' or 'F')
  static String formatTemperature(double tempC, {required String unit, bool showUnit = true}) {
    final value = unit == 'F' ? cToF(tempC) : tempC;
    final rounded = value.round();
    return showUnit ? '$rounded°$unit' : '$rounded°';
  }

  /// Converts km/h to mph
  static double kphToMph(double kph) => kph * 0.621371;

  /// Converts km/h to m/s
  static double kphToMs(double kph) => kph / 3.6;

  /// Format wind speed according to selected unit ('kph', 'mph', 'ms')
  static String formatWindSpeed(double kph, {required String unit}) {
    switch (unit) {
      case 'mph':
        return '${kphToMph(kph).toStringAsFixed(1)} mph';
      case 'ms':
        return '${kphToMs(kph).toStringAsFixed(1)} m/s';
      case 'kph':
      default:
        return '${kph.toStringAsFixed(1)} km/h';
    }
  }

  /// Format pressure ('hpa' or 'inhg')
  static String formatPressure(double hpa, {String unit = 'hpa'}) {
    if (unit == 'inhg') {
      return '${(hpa * 0.02953).toStringAsFixed(2)} inHg';
    }
    return '${hpa.round()} hPa';
  }

  /// Format visibility in km or miles
  static String formatVisibility(double km, {bool imperial = false}) {
    if (imperial) {
      return '${(km * 0.621371).toStringAsFixed(1)} mi';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
