import 'package:flutter/material.dart';
import '../../../../core/models/weather_models.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../core/utils/weather_condition_mapper.dart';
import '../../../shared/widgets/weather_3d_art.dart';

/// Horizontal 24-Hour Forecast with Pill Capsule Cards (replicates reference design)
class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> hourlyList;
  final bool isDay;
  final String tempUnit;
  final Color ambientGlow;
  final double? currentTempC;
  final String? currentConditionText;
  final int? currentConditionCode;
  final bool? currentIsDay;
  final int? currentChanceOfRain;

  const HourlyForecastList({
    super.key,
    required this.hourlyList,
    required this.isDay,
    required this.tempUnit,
    required this.ambientGlow,
    this.currentTempC,
    this.currentConditionText,
    this.currentConditionCode,
    this.currentIsDay,
    this.currentChanceOfRain,
  });

  /// Builds a strictly sequential hourly forecast list:
  /// - First pill: 'Now' (exact current temperature & condition)
  /// - Subsequent pills: Sequential future hours (12 PM, 1 PM, 2 PM, 3 PM...)
  List<_HourlyDisplayItem> _buildSequentialHourlyList() {
    final List<_HourlyDisplayItem> items = [];
    final now = DateTime.now();

    // 1. Current Live Weather Pill ('Now')
    items.add(_HourlyDisplayItem(
      label: 'Now',
      tempC: currentTempC ?? (hourlyList.isNotEmpty ? hourlyList.first.tempC : 25.0),
      conditionText: currentConditionText ?? (hourlyList.isNotEmpty ? hourlyList.first.conditionText : 'Clear'),
      conditionCode: currentConditionCode ?? (hourlyList.isNotEmpty ? hourlyList.first.conditionCode : 800),
      isDay: currentIsDay ?? isDay,
      chanceOfRain: currentChanceOfRain ?? (hourlyList.isNotEmpty ? hourlyList.first.chanceOfRain : 0),
      isNow: true,
    ));

    // Parse all forecast items with their DateTime for chronological lookups
    final List<_ParsedForecastPoint> points = [];
    for (final h in hourlyList) {
      final dt = _parseHourlyTime(h.time);
      if (dt != null) {
        points.add(_ParsedForecastPoint(
          dateTime: dt,
          tempC: h.tempC,
          conditionText: h.conditionText,
          conditionCode: h.conditionCode,
          chanceOfRain: h.chanceOfRain,
          isDay: h.isDay,
        ));
      }
    }
    points.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // 2. Next 24 Hours: sequential hour-by-hour (e.g. 12 PM, 1 PM, 2 PM, 3 PM...)
    final nextHour = now.hour + 1;

    for (int step = 0; step < 24; step++) {
      final targetDateTime = DateTime(now.year, now.month, now.day, nextHour + step);
      final label = _formatHourTime(targetDateTime.hour);

      final point = _findOrInterpolate(targetDateTime, points);

      items.add(_HourlyDisplayItem(
        label: label,
        tempC: point.tempC,
        conditionText: point.conditionText,
        conditionCode: point.conditionCode,
        isDay: point.isDay,
        chanceOfRain: point.chanceOfRain,
        isNow: false,
      ));
    }

    return items;
  }

  /// Finds or smoothly interpolates forecast data for a given target hour
  _ParsedForecastPoint _findOrInterpolate(DateTime target, List<_ParsedForecastPoint> points) {
    final isDaytime = target.hour >= 6 && target.hour < 19;

    if (points.isEmpty) {
      return _ParsedForecastPoint(
        dateTime: target,
        tempC: currentTempC ?? 24.0,
        conditionText: currentConditionText ?? 'Clear',
        conditionCode: currentConditionCode ?? 800,
        chanceOfRain: currentChanceOfRain ?? 0,
        isDay: isDaytime,
      );
    }

    // Exact or nearest match
    for (int i = 0; i < points.length; i++) {
      final diffMin = points[i].dateTime.difference(target).inMinutes.abs();
      if (diffMin <= 30) {
        return _ParsedForecastPoint(
          dateTime: target,
          tempC: points[i].tempC,
          conditionText: points[i].conditionText,
          conditionCode: points[i].conditionCode,
          chanceOfRain: points[i].chanceOfRain,
          isDay: isDaytime,
        );
      }
    }

    // Interpolation between points before and after target
    _ParsedForecastPoint? before;
    _ParsedForecastPoint? after;

    for (final p in points) {
      if (p.dateTime.isBefore(target) || p.dateTime.isAtSameMomentAs(target)) {
        if (before == null || p.dateTime.isAfter(before.dateTime)) {
          before = p;
        }
      }
      if (p.dateTime.isAfter(target)) {
        if (after == null || p.dateTime.isBefore(after.dateTime)) {
          after = p;
        }
      }
    }

    if (before != null && after != null) {
      final totalMin = after.dateTime.difference(before.dateTime).inMinutes;
      final currentMin = target.difference(before.dateTime).inMinutes;
      final fraction = totalMin > 0 ? (currentMin / totalMin).clamp(0.0, 1.0) : 0.5;

      final interpTemp = before.tempC + (after.tempC - before.tempC) * fraction;
      final interpRain = (before.chanceOfRain + (after.chanceOfRain - before.chanceOfRain) * fraction).round();
      final useAfter = fraction >= 0.5;

      return _ParsedForecastPoint(
        dateTime: target,
        tempC: interpTemp,
        conditionText: useAfter ? after.conditionText : before.conditionText,
        conditionCode: useAfter ? after.conditionCode : before.conditionCode,
        chanceOfRain: interpRain,
        isDay: isDaytime,
      );
    }

    if (before != null) {
      return _ParsedForecastPoint(
        dateTime: target,
        tempC: before.tempC,
        conditionText: before.conditionText,
        conditionCode: before.conditionCode,
        chanceOfRain: before.chanceOfRain,
        isDay: isDaytime,
      );
    }

    return _ParsedForecastPoint(
      dateTime: target,
      tempC: points.first.tempC,
      conditionText: points.first.conditionText,
      conditionCode: points.first.conditionCode,
      chanceOfRain: points.first.chanceOfRain,
      isDay: isDaytime,
    );
  }

  static DateTime? _parseHourlyTime(String rawTime) {
    try {
      if (rawTime.contains(' ') && rawTime.contains('-')) {
        return DateTime.parse(rawTime.replaceFirst(' ', 'T'));
      }
      if (rawTime.contains('T')) {
        return DateTime.parse(rawTime);
      }
    } catch (_) {}
    return null;
  }

  static String _formatHourTime(int hour24) {
    final h = hour24 % 24;
    final period = (h >= 12 && h < 24) ? 'PM' : 'AM';
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayHour $period';
  }

  @override
  Widget build(BuildContext context) {
    final sequentialList = _buildSequentialHourlyList();
    if (sequentialList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Hourly Forecast',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
              const SizedBox(width: 8),
              Text(
                'Next 24 Hours',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Capsule List
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: sequentialList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = sequentialList[index];
              final type = WeatherConditionMapper.resolve(
                conditionText: item.conditionText,
                conditionCode: item.conditionCode,
                isDay: item.isDay,
              );

              final tempDisplay = UnitConverter.formatTemperature(
                item.tempC,
                unit: tempUnit,
                showUnit: false,
              );

              return _HourlyPillCard(
                time: item.label,
                temp: tempDisplay,
                chanceOfRain: item.chanceOfRain,
                weatherType: type,
                isDay: item.isDay,
                isHighlight: item.isNow,
                glowColor: ambientGlow,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HourlyDisplayItem {
  final String label;
  final double tempC;
  final String conditionText;
  final int conditionCode;
  final bool isDay;
  final int chanceOfRain;
  final bool isNow;

  const _HourlyDisplayItem({
    required this.label,
    required this.tempC,
    required this.conditionText,
    required this.conditionCode,
    required this.isDay,
    required this.chanceOfRain,
    required this.isNow,
  });
}

class _ParsedForecastPoint {
  final DateTime dateTime;
  final double tempC;
  final String conditionText;
  final int conditionCode;
  final int chanceOfRain;
  final bool isDay;

  const _ParsedForecastPoint({
    required this.dateTime,
    required this.tempC,
    required this.conditionText,
    required this.conditionCode,
    required this.chanceOfRain,
    required this.isDay,
  });
}

class _HourlyPillCard extends StatelessWidget {
  final String time;
  final String temp;
  final int chanceOfRain;
  final WeatherType weatherType;
  final bool isDay;
  final bool isHighlight;
  final Color glowColor;

  const _HourlyPillCard({
    required this.time,
    required this.temp,
    required this.chanceOfRain,
    required this.weatherType,
    required this.isDay,
    required this.isHighlight,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isHighlight
              ? [
                  glowColor.withOpacity(0.55),
                  isDay ? const Color(0x660077B6) : const Color(0x667209B7),
                ]
              : [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.06),
                ],
        ),
        border: Border.all(
          width: isHighlight ? 1.6 : 1.0,
          color: isHighlight ? glowColor.withOpacity(0.9) : Colors.white.withOpacity(0.2),
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          // Weather Icon Art
          Weather3DArt(
            weatherType: weatherType,
            isDay: isDay,
            size: 44,
            isAnimated: isHighlight,
          ),

          // Rain chance if any
          if (chanceOfRain > 15) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$chanceOfRain%',
                style: const TextStyle(
                  color: Color(0xFF64DFDF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
          ],

          // Temperature
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$temp°',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
