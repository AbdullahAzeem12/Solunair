import 'package:flutter/material.dart';
import '../../../core/utils/weather_condition_mapper.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/weather_particles.dart';
import '../controllers/weather_controller.dart';
import 'widgets/current_weather_hero.dart';
import 'widgets/hourly_forecast_list.dart';
import 'widgets/weather_metrics_grid.dart';
import 'widgets/sun_tracker_card.dart';

/// Main Dashboard Screen featuring 3D dynamic hero, hourly pills, metrics, and insights
class HomeScreen extends StatelessWidget {
  final WeatherController controller;
  final VoidCallback onOpenCitySearch;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.onOpenCitySearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final weather = controller.snapshot;
        final isDay = controller.isDayEffective;
        final weatherType = controller.currentWeatherType;
        final glowColor = controller.ambientGlow;
        final isLoading = controller.isLoading;
        final errorMessage = controller.errorMessage;

        return Stack(
          children: [
            // Atmospheric Particle Layer
            WeatherParticles(
              weatherType: weatherType,
              isDay: isDay,
            ),

            // Main Content Area with Pull-to-Refresh
            SafeArea(
              child: RefreshIndicator(
                onRefresh: controller.refreshWeather,
                color: glowColor,
                backgroundColor: isDay ? const Color(0xFF0D72D1) : const Color(0xFF1B263B),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                  child: Column(
                    children: [
                      // Loading bar when fetching in background
                      if (controller.isRefreshing) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Error Banner if present
                      if (errorMessage != null && weather == null) ...[
                        _buildErrorView(context, errorMessage),
                      ] else if (weather != null) ...[
                        // 1. Current Weather Hero
                        CurrentWeatherHero(
                          weather: weather,
                          controller: controller,
                          onOpenCitySearch: onOpenCitySearch,
                        ),

                        const SizedBox(height: 24),

                        // 2. Hourly Forecast Section (24 Hours horizontal capsules)
                        HourlyForecastList(
                          hourlyList: weather.hourlyForecast,
                          isDay: isDay,
                          tempUnit: controller.tempUnit,
                          ambientGlow: glowColor,
                          currentTempC: weather.temperatureC,
                          currentConditionText: weather.conditionText,
                          currentConditionCode: weather.conditionCode,
                          currentIsDay: weather.isDay,
                          currentChanceOfRain: weather.chanceOfRain,
                        ),

                        const SizedBox(height: 24),

                        // 3. Smart Weather Insights & Advisory Card
                        _buildSmartInsightsCard(weather, isDay, glowColor),

                        const SizedBox(height: 24),

                        // 4. Detailed Weather Metrics Grid
                        WeatherMetricsGrid(
                          weather: weather,
                          isDay: isDay,
                          windUnit: controller.windUnit,
                          pressureUnit: controller.pressureUnit,
                          glowColor: glowColor,
                        ),

                        const SizedBox(height: 24),

                        // 5. Sun & Daylight Progression Arc
                        SunTrackerCard(
                          weather: weather,
                          isDay: isDay,
                          glowColor: glowColor,
                        ),
                      ] else if (isLoading) ...[
                        _buildLoadingPlaceholder(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmartInsightsCard(dynamic weather, bool isDay, Color glowColor) {
    final insights = WeatherConditionMapper.getSmartInsights(
      tempC: weather.temperatureC,
      chanceOfRain: weather.chanceOfRain,
      windKph: weather.windKph,
      uvIndex: weather.uvIndex,
      humidity: weather.humidity,
      conditionText: weather.conditionText,
    );

    return GlassCard(
      isDay: isDay,
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      glowColor: glowColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tips_and_updates_rounded, color: glowColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Weather Advisory & Living Index',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Icon(Icons.circle, color: Color(0xFF64DFDF), size: 6),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Column(
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Synchronizing Atmospheric Telemetry...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: GlassCard(
          isDay: controller.isDayEffective,
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, color: Color(0xFFFFD166), size: 54),
              const SizedBox(height: 16),
              const Text(
                'Unable to Fetch Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.refreshWeather,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.25),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
