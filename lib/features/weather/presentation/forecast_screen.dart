import 'package:flutter/material.dart';
import '../../../core/models/weather_models.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/weather_condition_mapper.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/weather_3d_art.dart';
import '../controllers/weather_controller.dart';

/// 3-Day to 7-Day Multi-Day Forecast Screen
class ForecastScreen extends StatelessWidget {
  final WeatherController controller;

  const ForecastScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final weather = controller.snapshot;
        final isDay = controller.isDayEffective;
        final unit = controller.tempUnit;
        final glowColor = controller.ambientGlow;

        if (weather == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final dailyList = weather.dailyForecast;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Multi-Day Forecast',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${weather.cityName} • Atmospheric Trend (${weather.providerName})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Tomorrow Highlight Card
                if (dailyList.length > 1) ...[
                  _buildTomorrowHighlightCard(dailyList[1], isDay, unit, glowColor),
                  const SizedBox(height: 20),
                ],

                // Forecast Days List
                Row(
                  children: [
                    const Icon(Icons.view_week_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Extended Forecast Overview',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...dailyList.map((day) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildDayRowCard(day, isDay, unit, glowColor),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTomorrowHighlightCard(
    DailyForecast tomorrow,
    bool isDay,
    String unit,
    Color glowColor,
  ) {
    final type = WeatherConditionMapper.resolve(
      conditionText: tomorrow.conditionText,
      conditionCode: tomorrow.conditionCode,
      isDay: isDay,
    );

    final minFmt = UnitConverter.formatTemperature(tomorrow.tempMinC, unit: unit);
    final maxFmt = UnitConverter.formatTemperature(tomorrow.tempMaxC, unit: unit);

    return GlassCard(
      isDay: isDay,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      glowColor: glowColor.withOpacity(0.25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TOMORROW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$maxFmt / $minFmt',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tomorrow.conditionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tomorrow.chanceOfRain > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.umbrella_rounded, color: Color(0xFF64DFDF), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Rain Chance: ${tomorrow.chanceOfRain}%',
                        style: const TextStyle(color: Color(0xFF64DFDF), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Weather3DArt(
            weatherType: type,
            isDay: isDay,
            size: 90,
          ),
        ],
      ),
    );
  }

  Widget _buildDayRowCard(
    DailyForecast day,
    bool isDay,
    String unit,
    Color glowColor,
  ) {
    final type = WeatherConditionMapper.resolve(
      conditionText: day.conditionText,
      conditionCode: day.conditionCode,
      isDay: isDay,
    );

    final minFmt = UnitConverter.formatTemperature(day.tempMinC, unit: unit);
    final maxFmt = UnitConverter.formatTemperature(day.tempMaxC, unit: unit);

    return GlassCard(
      isDay: isDay,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Day Name
          SizedBox(
            width: 76,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                day.dayOfWeek,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Mini 3D Weather Icon
          Weather3DArt(
            weatherType: type,
            isDay: isDay,
            size: 38,
            isAnimated: false,
          ),
          const SizedBox(width: 12),

          // Condition Text & Rain Chance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.conditionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (day.chanceOfRain > 10) ...[
                  Text(
                    '${day.chanceOfRain}% Rain Probability',
                    style: TextStyle(
                      color: const Color(0xFF64DFDF).withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Temp Range
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '$maxFmt / $minFmt',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
