import 'dart:ui';
import 'package:flutter/material.dart';
import '../cities/presentation/city_explorer_screen.dart';
import '../radar/presentation/radar_map_screen.dart';
import '../settings/presentation/settings_screen.dart';
import '../weather/controllers/weather_controller.dart';
import '../weather/presentation/forecast_screen.dart';
import '../weather/presentation/home_screen.dart';

/// Main Application Shell with Floating 3D Glassmorphic Bottom Navigation Bar
class MainNavigationShell extends StatefulWidget {
  final WeatherController controller;

  const MainNavigationShell({super.key, required this.controller});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isDay = widget.controller.isDayEffective;
        final gradientColors = widget.controller.backgroundGradient;
        final glowColor = widget.controller.ambientGlow;

        final screens = [
          HomeScreen(
            controller: widget.controller,
            onOpenCitySearch: () => _onTabSelected(1),
          ),
          CityExplorerScreen(
            controller: widget.controller,
            onCitySelected: () => _onTabSelected(0),
          ),
          ForecastScreen(
            controller: widget.controller,
          ),
          RadarMapScreen(
            controller: widget.controller,
          ),
          SettingsScreen(
            controller: widget.controller,
          ),
        ];

        return Scaffold(
          body: Stack(
            children: [
              // 1. Dynamic Animated Weather Gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradientColors,
                  ),
                ),
              ),

              // 2. Active Screen Content
              IndexedStack(
                index: _currentIndex,
                children: screens,
              ),

              // 3. Floating 3D Glass Bottom Navigation Bar
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _buildFloatingGlassNavBar(isDay, glowColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingGlassNavBar(bool isDay, Color glowColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDay
                  ? [
                      const Color(0x59FFFFFF),
                      const Color(0x33FFFFFF),
                      const Color(0x40FFFFFF),
                    ]
                  : [
                      const Color(0x591B263B),
                      const Color(0x3D0D1B2A),
                      const Color(0x4D243B55),
                    ],
            ),
            border: Border.all(
              width: 1.4,
              color: isDay ? const Color(0x80FFFFFF) : const Color(0x4D90E0EF),
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildNavButton(0, Icons.cloud_rounded, 'Home', glowColor)),
              Expanded(child: _buildNavButton(1, Icons.location_city_rounded, 'Cities', glowColor)),
              _buildNavCenterAction(glowColor),
              Expanded(child: _buildNavButton(2, Icons.calendar_today_rounded, 'Forecast', glowColor)),
              Expanded(child: _buildNavButton(3, Icons.radar_rounded, 'Radar', glowColor)),
              Expanded(child: _buildNavButton(4, Icons.settings_rounded, 'Settings', glowColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, IconData icon, String label, Color glowColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.35),
                    blurRadius: 10,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.65),
              size: 18,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.65),
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Center floating GPS location action button
  Widget _buildNavCenterAction(Color glowColor) {
    final isGpsActive = widget.controller.isGpsActive;
    final isDetecting = widget.controller.isDetectingLocation;

    return GestureDetector(
      onTap: () {
        if (isGpsActive) {
          widget.controller.disableGpsLocation();
        } else {
          widget.controller.useGpsLocation();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isGpsActive
                ? [const Color(0xFF00E676), const Color(0xFF00C853)]
                : [const Color(0xFF64DFDF), const Color(0xFF0077B6)],
          ),
          boxShadow: [
            BoxShadow(
              color: (isGpsActive ? const Color(0xFF00E676) : glowColor).withOpacity(0.6),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isDetecting
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isGpsActive ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                color: Colors.white,
                size: 22,
              ),
      ),
    );
  }
}
