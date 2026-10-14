import 'dart:async';
import 'package:flutter/material.dart';
import '../../navigation/main_navigation_shell.dart';
import '../../shared/widgets/weather_3d_art.dart';
import '../../shared/widgets/weather_particles.dart';
import '../../shared/widgets/glass_card.dart';
import '../../weather/controllers/weather_controller.dart';

/// 7-Second Dynamic 3D Weather-Reactive Splash Screen
class SplashScreen extends StatefulWidget {
  final WeatherController controller;

  const SplashScreen({super.key, required this.controller});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 7;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Parallel fetch weather in background while splash is animating
    widget.controller.initWeather();

    // Listen to changes in weather controller so splash updates in real-time
    widget.controller.addListener(_onWeatherUpdated);

    // Exact 7-second timer countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 1) {
            _secondsRemaining--;
          } else {
            _secondsRemaining = 0;
            _countdownTimer?.cancel();
          }
        });
      }
    });

    // Exact 7-second navigation guarantee
    _navigationTimer = Timer(const Duration(seconds: 7), () {
      _navigateToHome();
    });
  }

  void _onWeatherUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navigationTimer?.cancel();
    _countdownTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainNavigationShell(controller: widget.controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeCurve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          final scaleCurve = Tween<double>(begin: 0.94, end: 1.0).animate(fadeCurve);
          return FadeTransition(
            opacity: fadeCurve,
            child: ScaleTransition(scale: scaleCurve, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _countdownTimer?.cancel();
    widget.controller.removeListener(_onWeatherUpdated);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.controller.snapshot;
    final isDay = widget.controller.isDayEffective;
    final weatherType = widget.controller.currentWeatherType;
    final gradientColors = widget.controller.backgroundGradient;
    final glowColor = widget.controller.ambientGlow;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Animated Gradient Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
          ),

          // 2. Atmospheric Particle Layer (Rain, Stars, Sun Dust)
          WeatherParticles(
            weatherType: weatherType,
            isDay: isDay,
          ),

          // 3. Central Aesthetic 3D Branding & Weather Elements
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // 3D Weather Art Hero Centerpiece
                          Weather3DArt(
                            weatherType: weatherType,
                            isDay: isDay,
                            size: 210,
                          ),

                          const SizedBox(height: 28),

                          // Brand Name with 3D Glowing Shadows
                          Text(
                            'SOLUNAIR',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: glowColor.withOpacity(0.85),
                                  blurRadius: 28,
                                  offset: Offset.zero,
                                ),
                                const Shadow(
                                  color: Color(0x99000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Transitional Subtitle
                          Text(
                            'ATMOSPHERIC INTELLIGENCE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.5,
                              color: isDay ? const Color(0xEEFFFFFF) : const Color(0xCC90E0EF),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Pakistan & Global Real-time Forecast',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.2,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Live Weather Status Card (Adapts to real-time city conditions)
                          GlassCard(
                            isDay: isDay,
                            borderRadius: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            glowColor: glowColor.withOpacity(0.3),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                    color: glowColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  if (weather != null) ...[
                                    Text(
                                      '${weather.cityName} • ${weather.temperatureC.round()}°C',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        weather.conditionText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'Connecting Live Weather...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // 7-Second Circular Timer & Skip Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Glowing Countdown Indicator
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: CircularProgressIndicator(
                                      value: (7 - _secondsRemaining) / 7.0,
                                      strokeWidth: 3.5,
                                      backgroundColor: Colors.white.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                                    ),
                                  ),
                                  Text(
                                    '$_secondsRemaining',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 18),

                              // Quick Skip Action
                              TextButton.icon(
                                onPressed: _navigateToHome,
                                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                label: const Text(
                                  'Explore Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.16),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Colors.white.withOpacity(0.25)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
