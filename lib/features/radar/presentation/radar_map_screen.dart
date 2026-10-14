import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/api_config.dart';
import '../../weather/controllers/weather_controller.dart';

/// Interactive Rain Radar Map Screen
/// Uses OpenWeatherMap tile layers for precipitation radar visualization
class RadarMapScreen extends StatefulWidget {
  final WeatherController controller;

  const RadarMapScreen({super.key, required this.controller});

  @override
  State<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends State<RadarMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _selectedLayer = 0; // 0: Precipitation, 1: Clouds, 2: Temperature, 3: Wind

  final List<_RadarLayer> _layers = [
    _RadarLayer('Precipitation', Icons.water_drop_rounded, 'precipitation_new', const Color(0xFF00B4D8)),
    _RadarLayer('Clouds', Icons.cloud_rounded, 'clouds_new', const Color(0xFF90E0EF)),
    _RadarLayer('Temperature', Icons.thermostat_rounded, 'temp_new', const Color(0xFFFF6B6B)),
    _RadarLayer('Wind Speed', Icons.air_rounded, 'wind_new', const Color(0xFF48BFE3)),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isDay = widget.controller.isDayEffective;
        final snapshot = widget.controller.snapshot;
        final lat = snapshot?.latitude ?? 33.68;
        final lon = snapshot?.longitude ?? 73.05;
        final city = snapshot?.cityName ?? 'Unknown';

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isDay, city),
                const SizedBox(height: 12),

                // Layer Selector
                _buildLayerSelector(isDay),
                const SizedBox(height: 16),

                // Radar Map Area
                Expanded(
                  child: _buildRadarMap(isDay, lat, lon),
                ),

                // Legend & Info
                _buildLegend(isDay),
                const SizedBox(height: 12),

                // Open in Browser Button
                _buildOpenInBrowserButton(isDay, lat, lon),
                const SizedBox(height: 100), // Bottom nav bar space
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDay, String city) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.3 + _pulseController.value * 0.5),
                      blurRadius: 8 + _pulseController.value * 6,
                      spreadRadius: 1 + _pulseController.value * 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Radar Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: isDay ? Colors.black26 : Colors.black54,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Text(
                  city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Refresh button
          _buildGlassButton(
            icon: Icons.refresh_rounded,
            onTap: () => widget.controller.refreshWeather(),
            isDay: isDay,
          ),
        ],
      ),
    );
  }

  Widget _buildLayerSelector(bool isDay) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _layers.length,
        itemBuilder: (context, index) {
          final layer = _layers[index];
          final isSelected = index == _selectedLayer;

          return GestureDetector(
            onTap: () => setState(() => _selectedLayer = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected
                    ? layer.color.withOpacity(0.35)
                    : Colors.white.withOpacity(isDay ? 0.12 : 0.08),
                border: Border.all(
                  color: isSelected
                      ? layer.color.withOpacity(0.8)
                      : Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: layer.color.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    layer.icon,
                    color: isSelected ? layer.color : Colors.white.withOpacity(0.6),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    layer.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRadarMap(bool isDay, double lat, double lon) {
    final layer = _layers[_selectedLayer];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: layer.color.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Radar Map Tiles (4-tile grid centered on user location)
            _buildRadarTileGrid(lat, lon, layer),

            // Crosshair location indicator overlay
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Container(
                    width: 24 + _pulseController.value * 8,
                    height: 24 + _pulseController.value * 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.9 - _pulseController.value * 0.3),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: layer.color.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Glass overlay with coordinates
            Positioned(
              top: 12,
              left: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.35),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.my_location_rounded, color: layer.color, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${lat.toStringAsFixed(2)}°N, ${lon.toStringAsFixed(2)}°E',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Layer Badge
            Positioned(
              top: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: layer.color.withOpacity(0.25),
                      border: Border.all(color: layer.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      layer.name,
                      style: TextStyle(
                        color: layer.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a 3x3 grid of OpenWeatherMap radar tiles centered on the user's location
  Widget _buildRadarTileGrid(double lat, double lon, _RadarLayer layer) {
    const int zoom = 6;
    final centerTileX = _lonToTileX(lon, zoom);
    final centerTileY = _latToTileY(lat, zoom);
    final apiKey = widget.controller.openWeatherApiKey ?? ApiConfig.openWeatherApiKey;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.maxWidth / 3;

        return Stack(
          children: [
            // Dark map background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A1628),
                    const Color(0xFF132243),
                    const Color(0xFF0D1B2A),
                  ],
                ),
              ),
            ),

            // 3x3 grid of tiles
            for (int dy = -1; dy <= 1; dy++)
              for (int dx = -1; dx <= 1; dx++)
                Positioned(
                  left: (dx + 1) * tileSize,
                  top: (dy + 1) * tileSize,
                  width: tileSize,
                  height: tileSize,
                  child: Image.network(
                    'https://tile.openweathermap.org/map/${layer.layerId}/$zoom/${centerTileX + dx}/${centerTileY + dy}.png?appid=$apiKey',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF132243),
                      child: Center(
                        child: Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.white.withOpacity(0.2),
                          size: 20,
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFF132243),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: layer.color.withOpacity(0.5),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(bool isDay) {
    List<_LegendItem> items;

    if (_selectedLayer == 0) {
      items = [
        _LegendItem('Light', const Color(0xFF96D6F7)),
        _LegendItem('Moderate', const Color(0xFF00B4D8)),
        _LegendItem('Heavy', const Color(0xFF0077B6)),
        _LegendItem('Extreme', const Color(0xFFFF3366)),
      ];
    } else if (_selectedLayer == 1) {
      items = [
        _LegendItem('Clear', const Color(0xFF48BFE3)),
        _LegendItem('Scattered', const Color(0xFF90E0EF)),
        _LegendItem('Broken', const Color(0xFFCAF0F8)),
        _LegendItem('Overcast', const Color(0xFF8D99AE)),
      ];
    } else if (_selectedLayer == 2) {
      items = [
        _LegendItem('Cold', const Color(0xFF00B4D8)),
        _LegendItem('Cool', const Color(0xFF48BFE3)),
        _LegendItem('Warm', const Color(0xFFFFB347)),
        _LegendItem('Hot', const Color(0xFFFF3366)),
      ];
    } else {
      items = [
        _LegendItem('Calm', const Color(0xFF48BFE3)),
        _LegendItem('Breezy', const Color(0xFF64DFDF)),
        _LegendItem('Strong', const Color(0xFFFFB347)),
        _LegendItem('Storm', const Color(0xFFFF3366)),
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(isDay ? 0.1 : 0.06),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: item.color,
                    boxShadow: [
                      BoxShadow(color: item.color.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOpenInBrowserButton(bool isDay, double lat, double lon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildLauncherCard(
              title: 'OpenWeather Map',
              icon: Icons.layers_rounded,
              gradientColors: [
                const Color(0xFF00B4D8).withOpacity(0.35),
                const Color(0xFF0077B6).withOpacity(0.35),
              ],
              borderColor: const Color(0xFF00B4D8).withOpacity(0.5),
              onTap: () => _openFullRadarMap(lat, lon),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildLauncherCard(
              title: 'Windy Live Doppler',
              icon: Icons.air_rounded,
              gradientColors: [
                const Color(0xFFFF6B6B).withOpacity(0.35),
                const Color(0xFFFF8E53).withOpacity(0.35),
              ],
              borderColor: const Color(0xFFFF6B6B).withOpacity(0.5),
              onTap: () => _openWindyRadarMap(lat, lon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLauncherCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: gradientColors),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new_rounded, color: Colors.white70, size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(isDay ? 0.15 : 0.1),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  Future<void> _openFullRadarMap(double lat, double lon) async {
    final url = Uri.parse(
      'https://openweathermap.org/weathermap?basemap=map&cities=true&layer=${_layers[_selectedLayer].layerId}&lat=$lat&lon=$lon&zoom=8',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWindyRadarMap(double lat, double lon) async {
    final url = Uri.parse('https://www.windy.com/?$lat,$lon,8');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Convert longitude to tile X coordinate
  int _lonToTileX(double lon, int zoom) {
    return ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  // Convert latitude to tile Y coordinate
  int _latToTileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180.0;
    return ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * (1 << zoom)).floor();
  }
}

class _RadarLayer {
  final String name;
  final IconData icon;
  final String layerId;
  final Color color;

  const _RadarLayer(this.name, this.icon, this.layerId, this.color);
}

class _LegendItem {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);
}
