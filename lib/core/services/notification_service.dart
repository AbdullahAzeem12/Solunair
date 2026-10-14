import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/weather_models.dart';

/// Severe Weather Alert Notification Service
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service (call once at app startup)
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _initialized = true;
  }

  /// Create dedicated notification channels for weather alerts
  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Critical Severe Weather Alerts Channel
    const severeChannel = AndroidNotificationChannel(
      'severe_weather_alerts',
      'Severe Weather Alerts',
      description: 'Critical alerts for storms, extreme temperatures, and severe weather',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // General Weather Notifications Channel
    const generalChannel = AndroidNotificationChannel(
      'weather_updates',
      'Weather Updates',
      description: 'Daily forecasts and weather change notifications',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    await androidPlugin.createNotificationChannel(severeChannel);
    await androidPlugin.createNotificationChannel(generalChannel);
  }

  /// Handle notification taps
  static void _onNotificationTap(NotificationResponse response) {
    // Will be handled by the app's main navigation
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions (Android 13+)
  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// Check and send severe weather alerts based on weather conditions
  static Future<void> checkAndNotifySevereWeather(WeatherSnapshot snapshot) async {
    if (!_initialized) return;

    final alerts = _detectSevereConditions(snapshot);
    for (final alert in alerts) {
      await _showSevereWeatherAlert(alert);
    }
  }

  /// Detect severe weather conditions from snapshot data
  static List<_WeatherAlert> _detectSevereConditions(WeatherSnapshot snapshot) {
    final List<_WeatherAlert> alerts = [];

    // 🌡️ Extreme Heat (>45°C)
    if (snapshot.temperatureC >= 45) {
      alerts.add(_WeatherAlert(
        id: 1001,
        title: '🔥 Extreme Heat Warning',
        body:
            '${snapshot.cityName}: Temperature is ${snapshot.temperatureC.round()}°C! '
            'Stay hydrated, avoid outdoor exposure. Feels like ${snapshot.feelsLikeC.round()}°C.',
        severity: AlertSeverity.extreme,
      ));
    }
    // Heat Advisory (>40°C)
    else if (snapshot.temperatureC >= 40) {
      alerts.add(_WeatherAlert(
        id: 1002,
        title: '🌡️ Heat Advisory',
        body:
            '${snapshot.cityName}: High temperature of ${snapshot.temperatureC.round()}°C. '
            'Take precautions against heat-related illness.',
        severity: AlertSeverity.severe,
      ));
    }

    // ❄️ Extreme Cold (<-10°C)
    if (snapshot.temperatureC <= -10) {
      alerts.add(_WeatherAlert(
        id: 1003,
        title: '❄️ Extreme Cold Warning',
        body:
            '${snapshot.cityName}: Temperature is ${snapshot.temperatureC.round()}°C. '
            'Risk of frostbite and hypothermia. Stay indoors and stay warm.',
        severity: AlertSeverity.extreme,
      ));
    }
    // Cold Advisory (<0°C)
    else if (snapshot.temperatureC <= 0) {
      alerts.add(_WeatherAlert(
        id: 1004,
        title: '🥶 Cold Weather Advisory',
        body:
            '${snapshot.cityName}: Temperature is ${snapshot.temperatureC.round()}°C. '
            'Wear warm clothing and protect exposed skin.',
        severity: AlertSeverity.moderate,
      ));
    }

    // 🌧️ Heavy Rain (>90% rain probability + >5mm precipitation)
    if (snapshot.chanceOfRain >= 90 && snapshot.precipMm >= 5) {
      alerts.add(_WeatherAlert(
        id: 1005,
        title: '🌧️ Heavy Rain Alert',
        body:
            '${snapshot.cityName}: ${snapshot.chanceOfRain}% chance of heavy rainfall '
            '(${snapshot.precipMm.toStringAsFixed(1)}mm). Potential flooding in low areas.',
        severity: AlertSeverity.severe,
      ));
    }
    // Rain Warning (>70% chance)
    else if (snapshot.chanceOfRain >= 70) {
      alerts.add(_WeatherAlert(
        id: 1006,
        title: '🌦️ Rain Expected',
        body:
            '${snapshot.cityName}: ${snapshot.chanceOfRain}% chance of rain. '
            'Carry an umbrella and plan accordingly.',
        severity: AlertSeverity.moderate,
      ));
    }

    // 💨 High Wind (>60 kph)
    if (snapshot.windKph >= 60) {
      alerts.add(_WeatherAlert(
        id: 1007,
        title: '💨 High Wind Warning',
        body:
            '${snapshot.cityName}: Winds at ${snapshot.windKph.round()} km/h. '
            'Secure loose objects and avoid driving on exposed roads.',
        severity: AlertSeverity.severe,
      ));
    }
    // Wind Advisory (>40 kph)
    else if (snapshot.windKph >= 40) {
      alerts.add(_WeatherAlert(
        id: 1008,
        title: '🌬️ Wind Advisory',
        body:
            '${snapshot.cityName}: Strong winds at ${snapshot.windKph.round()} km/h. '
            'Use caution outdoors.',
        severity: AlertSeverity.moderate,
      ));
    }

    // ⛈️ Thunderstorm Detection (condition codes)
    final condLower = snapshot.conditionText.toLowerCase();
    if (condLower.contains('thunder') || condLower.contains('storm') || condLower.contains('tornado')) {
      alerts.add(_WeatherAlert(
        id: 1009,
        title: '⛈️ Thunderstorm Warning',
        body:
            '${snapshot.cityName}: ${snapshot.conditionText} detected! '
            'Seek shelter immediately. Avoid open areas and tall structures.',
        severity: AlertSeverity.extreme,
      ));
    }

    // 🌫️ Low Visibility (<2km)
    if (snapshot.visibilityKm < 2.0) {
      alerts.add(_WeatherAlert(
        id: 1010,
        title: '🌫️ Low Visibility Warning',
        body:
            '${snapshot.cityName}: Visibility only ${snapshot.visibilityKm.toStringAsFixed(1)}km. '
            'Drive with caution and use fog lights.',
        severity: AlertSeverity.moderate,
      ));
    }

    // ☀️ High UV Index (>8)
    if (snapshot.uvIndex >= 8) {
      alerts.add(_WeatherAlert(
        id: 1011,
        title: '☀️ UV Radiation Warning',
        body:
            '${snapshot.cityName}: UV Index at ${snapshot.uvIndex.toStringAsFixed(0)} (Very High). '
            'Apply SPF 30+ sunscreen and wear protective clothing.',
        severity: AlertSeverity.moderate,
      ));
    }

    // 💀 Hazardous Air Quality
    if (snapshot.airQualityCategory == 'Hazardous' ||
        snapshot.airQualityCategory == 'Very Unhealthy') {
      alerts.add(_WeatherAlert(
        id: 1012,
        title: '😷 Air Quality Alert',
        body:
            '${snapshot.cityName}: Air quality is ${snapshot.airQualityCategory}. '
            'Avoid outdoor activities. Wear an N95 mask if going outside.'
            '${snapshot.pm2_5 != null ? ' PM2.5: ${snapshot.pm2_5!.toStringAsFixed(0)} µg/m³' : ''}',
        severity: AlertSeverity.severe,
      ));
    }

    return alerts;
  }

  /// Show a severe weather notification
  static Future<void> _showSevereWeatherAlert(_WeatherAlert alert) async {
    final channelId = alert.severity == AlertSeverity.extreme ||
            alert.severity == AlertSeverity.severe
        ? 'severe_weather_alerts'
        : 'weather_updates';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      alert.severity == AlertSeverity.extreme || alert.severity == AlertSeverity.severe
          ? 'Severe Weather Alerts'
          : 'Weather Updates',
      importance: alert.severity == AlertSeverity.extreme
          ? Importance.max
          : (alert.severity == AlertSeverity.severe ? Importance.high : Importance.defaultImportance),
      priority: alert.severity == AlertSeverity.extreme
          ? Priority.max
          : (alert.severity == AlertSeverity.severe ? Priority.high : Priority.defaultPriority),
      ticker: alert.title,
      styleInformation: BigTextStyleInformation(
        alert.body,
        contentTitle: alert.title,
      ),
      category: AndroidNotificationCategory.alarm,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      alert.id,
      alert.title,
      alert.body,
      details,
      payload: 'severe_weather_${alert.id}',
    );
  }

  /// Show a simple weather update notification
  static Future<void> showWeatherUpdate({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'weather_updates',
      'Weather Updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Show a test alert notification to verify push notifications
  static Future<void> showTestNotification() async {
    if (!_initialized) {
      await initialize();
    }
    await requestPermission();
    await showWeatherUpdate(
      title: '⚡ Solunair Alert System Verified',
      body: 'Severe weather push notifications are operational. You will receive real-time alerts for storms, heatwaves, and extreme conditions.',
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

/// Internal weather alert model
class _WeatherAlert {
  final int id;
  final String title;
  final String body;
  final AlertSeverity severity;

  const _WeatherAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
  });
}

/// Severity levels for weather alerts
enum AlertSeverity {
  moderate,
  severe,
  extreme,
}
