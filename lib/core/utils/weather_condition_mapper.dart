import 'package:flutter/material.dart';

enum WeatherType {
  sunny,
  clearNight,
  partlyCloudyDay,
  partlyCloudyNight,
  cloudy,
  overcast,
  drizzle,
  rain,
  heavyRain,
  thunderstorm,
  snow,
  fog,
  windy,
}

class WeatherConditionMapper {
  WeatherConditionMapper._();

  /// Resolve weather type from text, condition code and isDay
  static WeatherType resolve({
    required String conditionText,
    required int conditionCode,
    required bool isDay,
  }) {
    final lower = conditionText.toLowerCase();

    // Thunderstorm
    if (lower.contains('thunder') || lower.contains('storm') || (conditionCode >= 95 && conditionCode <= 99) || (conditionCode >= 1273 && conditionCode <= 1282) || (conditionCode >= 200 && conditionCode <= 232)) {
      return WeatherType.thunderstorm;
    }

    // Snow
    if (lower.contains('snow') || lower.contains('blizzard') || lower.contains('sleet') || (conditionCode >= 71 && conditionCode <= 77) || (conditionCode >= 1210 && conditionCode <= 1225) || (conditionCode >= 600 && conditionCode <= 622)) {
      return WeatherType.snow;
    }

    // Heavy Rain
    if (lower.contains('heavy rain') || lower.contains('torrential') || lower.contains('downpour') || conditionCode == 502 || conditionCode == 503 || conditionCode == 504) {
      return WeatherType.heavyRain;
    }

    // Rain / Showers
    if (lower.contains('rain') || lower.contains('shower') || (conditionCode >= 61 && conditionCode <= 65) || (conditionCode >= 80 && conditionCode <= 82) || (conditionCode >= 500 && conditionCode <= 531)) {
      return WeatherType.rain;
    }

    // Drizzle
    if (lower.contains('drizzle') || (conditionCode >= 51 && conditionCode <= 55) || (conditionCode >= 300 && conditionCode <= 321)) {
      return WeatherType.drizzle;
    }

    // Fog / Mist / Haze
    if (lower.contains('fog') || lower.contains('mist') || lower.contains('haze') || (conditionCode >= 45 && conditionCode <= 48) || (conditionCode >= 701 && conditionCode <= 781)) {
      return WeatherType.fog;
    }

    // Overcast
    if (lower.contains('overcast') || conditionCode == 3 || conditionCode == 804) {
      return WeatherType.overcast;
    }

    // Partly Cloudy
    if (lower.contains('partly') || lower.contains('scattered') || lower.contains('few') || conditionCode == 2 || conditionCode == 1003 || conditionCode == 801 || conditionCode == 802) {
      return isDay ? WeatherType.partlyCloudyDay : WeatherType.partlyCloudyNight;
    }

    // Cloudy
    if (lower.contains('cloud') || conditionCode == 1006 || conditionCode == 1009 || conditionCode == 803) {
      return WeatherType.cloudy;
    }

    // Clear / Sunny
    if (lower.contains('sun') || lower.contains('clear') || conditionCode == 1000 || conditionCode == 0 || conditionCode == 800) {
      return isDay ? WeatherType.sunny : WeatherType.clearNight;
    }

    // Default based on isDay
    return isDay ? WeatherType.sunny : WeatherType.clearNight;
  }

  /// Gradient background for the full-screen canvas
  static List<Color> getBackgroundGradient(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return const [
          Color(0xFF28B7FF),
          Color(0xFF1E88E5),
          Color(0xFF0F55BD),
        ];
      case WeatherType.clearNight:
        return const [
          Color(0xFF0D1B2A),
          Color(0xFF1B263B),
          Color(0xFF0B132B),
        ];
      case WeatherType.partlyCloudyDay:
        return const [
          Color(0xFF38B2FF),
          Color(0xFF4A90E2),
          Color(0xFF2060B0),
        ];
      case WeatherType.partlyCloudyNight:
        return const [
          Color(0xFF161F36),
          Color(0xFF1F2B48),
          Color(0xFF101726),
        ];
      case WeatherType.cloudy:
        return const [
          Color(0xFF4B6584),
          Color(0xFF3B4E63),
          Color(0xFF253342),
        ];
      case WeatherType.overcast:
        return const [
          Color(0xFF576574),
          Color(0xFF3E4E5E),
          Color(0xFF222C38),
        ];
      case WeatherType.drizzle:
      case WeatherType.rain:
        return const [
          Color(0xFF2C5364),
          Color(0xFF203A43),
          Color(0xFF0F2027),
        ];
      case WeatherType.heavyRain:
        return const [
          Color(0xFF1C3144),
          Color(0xFF14202D),
          Color(0xFF0A1017),
        ];
      case WeatherType.thunderstorm:
        return const [
          Color(0xFF1F1C2C),
          Color(0xFF2F2440),
          Color(0xFF14121E),
        ];
      case WeatherType.snow:
        return const [
          Color(0xFF708090),
          Color(0xFF5F6E7D),
          Color(0xFF3B444F),
        ];
      case WeatherType.fog:
        return const [
          Color(0xFF546E7A),
          Color(0xFF37474F),
          Color(0xFF263238),
        ];
      case WeatherType.windy:
        return const [
          Color(0xFF3A6073),
          Color(0xFF284452),
          Color(0xFF1A2D37),
        ];
    }
  }

  /// Ambient primary glow color for glowing 3D cards
  static Color getAmbientGlowColor(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return const Color(0xFFFFD166);
      case WeatherType.clearNight:
        return const Color(0xFF64DFDF);
      case WeatherType.partlyCloudyDay:
        return const Color(0xFF70D6FF);
      case WeatherType.partlyCloudyNight:
        return const Color(0xFF8338EC);
      case WeatherType.thunderstorm:
        return const Color(0xFFFFBE0B);
      case WeatherType.rain:
      case WeatherType.heavyRain:
      case WeatherType.drizzle:
        return const Color(0xFF48CAE4);
      case WeatherType.snow:
        return const Color(0xFFE0FBFC);
      default:
        return const Color(0xFF90E0EF);
    }
  }

  /// Rule-based smart weather advisory insights
  static List<String> getSmartInsights({
    required double tempC,
    required int chanceOfRain,
    required double windKph,
    required double uvIndex,
    required int humidity,
    required String conditionText,
  }) {
    final List<String> insights = [];

    if (chanceOfRain >= 40 || conditionText.toLowerCase().contains('rain')) {
      insights.add('Rain probability is high ($chanceOfRain%). Remember to carry an umbrella!');
    }

    if (uvIndex >= 7.0) {
      insights.add('Very high UV index (${uvIndex.toStringAsFixed(1)}). Wear SPF 30+ sunscreen and protective sunglasses.');
    } else if (uvIndex >= 4.0) {
      insights.add('Moderate UV rays. Sun protection recommended during afternoon hours.');
    }

    if (tempC >= 36.0) {
      insights.add('Extreme heat advisory (${tempC.round()}°C). Stay well-hydrated and avoid direct noon sun exposure.');
    } else if (tempC <= 10.0) {
      insights.add('Chilly weather (${tempC.round()}°C). Keep warm layers and a windbreaker handy.');
    } else if (tempC >= 20.0 && tempC <= 28.0 && chanceOfRain < 20) {
      insights.add('Optimal weather conditions! Great day for outdoor walks, exercise, and leisure.');
    }

    if (windKph >= 30.0) {
      insights.add('Brisk winds blowing at ${windKph.toStringAsFixed(0)} km/h. Secure loose outdoor belongings.');
    }

    if (humidity >= 80) {
      insights.add('High atmospheric humidity ($humidity%). May feel considerably warmer than the actual temperature.');
    }

    if (insights.isEmpty) {
      insights.add('Stable atmospheric conditions. Enjoy your day!');
    }

    return insights;
  }
}
