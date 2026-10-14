import 'package:flutter/material.dart';
import '../../../../core/models/weather_models.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/weather_3d_art.dart';
import '../../controllers/weather_controller.dart';

/// 3D Weather Hero Card displaying current temperature, condition and quick controls
class CurrentWeatherHero extends StatefulWidget {
  final WeatherSnapshot weather;
  final WeatherController controller;
  final VoidCallback onOpenCitySearch;

  const CurrentWeatherHero({
    super.key,
    required this.weather,
    required this.controller,
    required this.onOpenCitySearch,
  });

  @override
  State<CurrentWeatherHero> createState() => _CurrentWeatherHeroState();
}

class _CurrentWeatherHeroState extends State<CurrentWeatherHero> with SingleTickerProviderStateMixin {
  late AnimationController _refreshAnimController;

  @override
  void initState() {
    super.initState();
    _refreshAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _refreshAnimController.dispose();
    super.dispose();
  }

  void _onRefreshTapped() {
    _refreshAnimController.forward(from: 0.0);
    widget.controller.refreshWeather();
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.weather;
    final isDay = widget.controller.isDayEffective;
    final unit = widget.controller.tempUnit;
    final weatherType = widget.controller.currentWeatherType;
    final glowColor = widget.controller.ambientGlow;
    final isFav = widget.controller.isFavorite;

    final tempFormatted = UnitConverter.formatTemperature(weather.temperatureC, unit: unit, showUnit: false);
    final minFormatted = UnitConverter.formatTemperature(weather.tempMinC, unit: unit);
    final maxFormatted = UnitConverter.formatTemperature(weather.tempMaxC, unit: unit);
    final feelsFormatted = UnitConverter.formatTemperature(weather.feelsLikeC, unit: unit);

    return Column(
      children: [
        // 1. Top Location Header & Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              // City & Region Selector Chip (Expanded to prevent overflow)
              Expanded(
                child: GestureDetector(
                  onTap: widget.onOpenCitySearch,
                  child: GlassCard(
                    isDay: isDay,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderRadius: 20,
                    glowColor: glowColor.withOpacity(0.2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.controller.isGpsActive ? Icons.my_location_rounded : Icons.location_on_rounded,
                          color: widget.controller.isGpsActive ? const Color(0xFF00E676) : Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            weather.cityName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (widget.controller.isGpsActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.6), width: 0.8),
                            ),
                            child: const Text(
                              'GPS',
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Action Buttons: Favorite & Refresh
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite Star Button
                  IconButton(
                    onPressed: () => widget.controller.toggleFavoriteCity(weather.cityName),
                    icon: Icon(
                      isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFav ? const Color(0xFFFFD166) : Colors.white,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Animated Refresh Button
                  RotationTransition(
                    turns: _refreshAnimController,
                    child: IconButton(
                      onPressed: _onRefreshTapped,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Central 3D Art & Temperature Display
        GestureDetector(
          onTap: () {
            // Quick toggle between C and F on tap!
            widget.controller.setTemperatureUnit(unit == 'C' ? 'F' : 'C');
          },
          child: Column(
            children: [
              // 3D Weather Art Centerpiece
              Weather3DArt(
                weatherType: weatherType,
                isDay: isDay,
                size: 190,
              ),

              const SizedBox(height: 6),

              // Large 3D Temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tempFormatted,
                    style: TextStyle(
                      fontSize: 78,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 0.95,
                      letterSpacing: -2.0,
                      shadows: [
                        Shadow(
                          color: glowColor.withOpacity(0.8),
                          blurRadius: 36,
                          offset: Offset.zero,
                        ),
                        const Shadow(
                          color: Color(0x66000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '°$unit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Weather Condition Title
              Text(
                weather.conditionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // High / Low / Feels-Like Pill
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'H: $maxFormatted  •  L: $minFormatted  •  Feels $feelsFormatted',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (weather.isCached) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.offline_bolt_rounded, color: Color(0xFFFFD166), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Cached Snapshot (${weather.providerName})',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
