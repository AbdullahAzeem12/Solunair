import 'package:flutter/material.dart';
import '../../../../core/models/weather_models.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../shared/widgets/glass_card.dart';

/// Detailed Weather Metrics Grid in 3D Glassmorphic Cards
class WeatherMetricsGrid extends StatelessWidget {
  final WeatherSnapshot weather;
  final bool isDay;
  final String windUnit;
  final String pressureUnit;
  final Color glowColor;

  const WeatherMetricsGrid({
    super.key,
    required this.weather,
    required this.isDay,
    required this.windUnit,
    required this.pressureUnit,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final windFormatted = UnitConverter.formatWindSpeed(weather.windKph, unit: windUnit);
    final pressureFormatted = UnitConverter.formatPressure(weather.pressureHpa, unit: pressureUnit);
    final visibilityFormatted = UnitConverter.formatVisibility(weather.visibilityKm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              const Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weather Conditions & Details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2-Column Responsive Grid of 3D Metric Cards
        Row(
          children: [
            // Humidity Card
            Expanded(
              child: _MetricCard(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF48CAE4),
                title: 'Humidity',
                value: '${weather.humidity}%',
                subtitle: _getHumidityStatus(weather.humidity),
                isDay: isDay,
                progress: weather.humidity / 100.0,
              ),
            ),
            const SizedBox(width: 12),
            // Wind Card
            Expanded(
              child: _MetricCard(
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF70D6FF),
                title: 'Wind Speed',
                value: windFormatted,
                subtitle: '${weather.windDirection} (${weather.windDegree}°)',
                isDay: isDay,
                extraBadge: weather.windGustKph > 0 ? 'Gust: ${weather.windGustKph.round()} km/h' : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            // UV Index Card
            Expanded(
              child: _MetricCard(
                icon: Icons.wb_sunny_rounded,
                iconColor: const Color(0xFFFFD166),
                title: 'UV Index',
                value: weather.uvIndex.toStringAsFixed(1),
                subtitle: _getUvCategory(weather.uvIndex),
                isDay: isDay,
                progress: (weather.uvIndex / 12.0).clamp(0.0, 1.0),
              ),
            ),
            const SizedBox(width: 12),
            // Atmospheric Pressure Card
            Expanded(
              child: _MetricCard(
                icon: Icons.speed_rounded,
                iconColor: const Color(0xFF90E0EF),
                title: 'Air Pressure',
                value: pressureFormatted,
                subtitle: weather.pressureHpa > 1013 ? 'High Pressure' : 'Normal',
                isDay: isDay,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            // Visibility Card
            Expanded(
              child: _MetricCard(
                icon: Icons.visibility_rounded,
                iconColor: const Color(0xFFC7F9CC),
                title: 'Visibility',
                value: visibilityFormatted,
                subtitle: weather.visibilityKm >= 9 ? 'Clear Sight' : 'Hazy',
                isDay: isDay,
              ),
            ),
            const SizedBox(width: 12),
            // Precipitation / Rain Chance
            Expanded(
              child: _MetricCard(
                icon: Icons.umbrella_rounded,
                iconColor: const Color(0xFF80ED99),
                title: 'Rain Chance',
                value: '${weather.chanceOfRain}%',
                subtitle: weather.precipMm > 0 ? '${weather.precipMm} mm precip' : 'No rain recorded',
                isDay: isDay,
                progress: weather.chanceOfRain / 100.0,
              ),
            ),
          ],
        ),

        // Air Quality Banner (if PM2.5 or category is available)
        const SizedBox(height: 12),
        GlassCard(
          isDay: isDay,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.grain_rounded, color: Color(0xFF64DFDF), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Air Quality Index',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weather.airQualityCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (weather.pm2_5 != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'PM2.5: ${weather.pm2_5!.toStringAsFixed(1)} µg/m³',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getAqiColor(weather.airQualityCategory).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _getAqiColor(weather.airQualityCategory)),
                ),
                child: Text(
                  weather.airQualityCategory.split(' ').first,
                  style: TextStyle(
                    color: _getAqiColor(weather.airQualityCategory),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _getHumidityStatus(int humidity) {
    if (humidity < 30) return 'Dry Atmosphere';
    if (humidity <= 60) return 'Comfortable';
    if (humidity <= 80) return 'Moderately Humid';
    return 'Very Humid';
  }

  static String _getUvCategory(double uv) {
    if (uv <= 2.0) return 'Low Risk';
    if (uv <= 5.0) return 'Moderate Risk';
    if (uv <= 7.0) return 'High Protection';
    if (uv <= 10.0) return 'Very High';
    return 'Extreme';
  }

  static Color _getAqiColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('good')) return const Color(0xFF57CC99);
    if (lower.contains('moderate')) return const Color(0xFFFFD166);
    if (lower.contains('sensitive')) return const Color(0xFFF77F00);
    if (lower.contains('unhealthy')) return const Color(0xFFD62828);
    return const Color(0xFF57CC99);
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool isDay;
  final double? progress;
  final String? extraBadge;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDay,
    this.progress,
    this.extraBadge,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isDay: isDay,
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ),
          ],
          if (extraBadge != null) ...[
            const SizedBox(height: 6),
            Text(
              extraBadge!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
