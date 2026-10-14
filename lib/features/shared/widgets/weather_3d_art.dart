import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/weather_condition_mapper.dart';

/// Photorealistic weather artwork with atmospheric glow, volumetric depth,
/// and natural light rendering instead of cartoonish flat shapes.
class Weather3DArt extends StatefulWidget {
  final WeatherType weatherType;
  final bool isDay;
  final double size;
  final bool isAnimated;

  const Weather3DArt({
    super.key,
    required this.weatherType,
    required this.isDay,
    this.size = 180.0,
    this.isAnimated = true,
  });

  @override
  State<Weather3DArt> createState() => _Weather3DArtState();
}

class _Weather3DArtState extends State<Weather3DArt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant Weather3DArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimated && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatOffset = math.sin(_controller.value * 2 * math.pi) * 3.0;
        final rotateAngle = math.sin(_controller.value * 2 * math.pi) * 0.015;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.rotate(
            angle: rotateAngle,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _RealisticWeatherPainter(
                  type: widget.weatherType,
                  isDay: widget.isDay,
                  animProgress: _controller.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RealisticWeatherPainter extends CustomPainter {
  final WeatherType type;
  final bool isDay;
  final double animProgress;

  _RealisticWeatherPainter({
    required this.type,
    required this.isDay,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case WeatherType.sunny:
        _drawRealisticSun(canvas, size, center);
        break;

      case WeatherType.clearNight:
        _drawRealisticMoon(canvas, size, center);
        break;

      case WeatherType.partlyCloudyDay:
        _drawRealisticSunPeeking(canvas, size, center);
        _drawRealisticCloud(canvas, size, center, isDark: false, hasSunBacklight: true);
        break;

      case WeatherType.partlyCloudyNight:
        _drawRealisticMoonPeeking(canvas, size, center);
        _drawRealisticCloud(canvas, size, center, isDark: true, hasMoonBacklight: true);
        break;

      case WeatherType.cloudy:
      case WeatherType.overcast:
        _drawRealisticCloud(canvas, size, center, isDark: !isDay);
        break;

      case WeatherType.rain:
        _drawRealisticCloud(canvas, size, Offset(center.dx, center.dy - size.height * 0.1), isDark: true);
        _drawRealisticRain(canvas, size, center, isHeavy: false, isDrizzle: false);
        break;

      case WeatherType.drizzle:
        _drawRealisticCloud(canvas, size, Offset(center.dx, center.dy - size.height * 0.1), isDark: true);
        _drawRealisticRain(canvas, size, center, isHeavy: false, isDrizzle: true);
        break;

      case WeatherType.heavyRain:
        _drawRealisticCloud(canvas, size, Offset(center.dx, center.dy - size.height * 0.1), isDark: true);
        _drawRealisticRain(canvas, size, center, isHeavy: true, isDrizzle: false);
        break;

      case WeatherType.thunderstorm:
        _drawRealisticCloud(canvas, size, Offset(center.dx, center.dy - size.height * 0.12), isDark: true);
        _drawRealisticLightning(canvas, size, center);
        _drawRealisticRain(canvas, size, center, isHeavy: true, isDrizzle: false);
        break;

      case WeatherType.snow:
        _drawRealisticCloud(canvas, size, Offset(center.dx, center.dy - size.height * 0.1), isDark: false);
        _drawRealisticSnow(canvas, size, center);
        break;

      case WeatherType.fog:
      case WeatherType.windy:
        _drawRealisticCloud(canvas, size, center, isDark: false);
        _drawRealisticFog(canvas, size, center);
        break;
    }
  }

  // ============================================================
  // REALISTIC SUN — Multi-layer atmospheric glow with corona
  // ============================================================
  void _drawRealisticSun(Canvas canvas, Size size, Offset center) {
    final radius = size.width * 0.28;

    // Layer 1: Wide atmospheric haze (warm golden bloom)
    for (int i = 4; i >= 0; i--) {
      final hazeRadius = radius * (2.2 + i * 0.3);
      final hazeOpacity = 0.04 + i * 0.015;
      canvas.drawCircle(
        center,
        hazeRadius,
        Paint()
          ..color = const Color(0xFFFFB347).withOpacity(hazeOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, hazeRadius * 0.5),
      );
    }

    // Layer 2: Inner corona glow
    final coronaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x88FFD700),
          const Color(0x44FFA500),
          const Color(0x11FF8C00),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.8));
    canvas.drawCircle(center, radius * 1.8, coronaPaint);

    // Layer 3: Soft rays (subtle atmospheric scattering)
    final rayCount = 12;
    final rayAngleOffset = animProgress * math.pi * 0.15;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount) + rayAngleOffset;
      final rayLen = radius * (0.25 + 0.08 * math.sin(animProgress * math.pi * 2 + i * 0.5));
      final start = Offset(
        center.dx + math.cos(angle) * (radius * 1.05),
        center.dy + math.sin(angle) * (radius * 1.05),
      );
      final end = Offset(
        center.dx + math.cos(angle) * (radius * 1.05 + rayLen),
        center.dy + math.sin(angle) * (radius * 1.05 + rayLen),
      );

      final rayPaint = Paint()
        ..strokeWidth = size.width * 0.018
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x55FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(start, end, rayPaint);
    }

    // Layer 4: Photosphere drop shadow
    canvas.drawCircle(
      center.translate(0, radius * 0.12),
      radius,
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.2),
    );

    // Layer 5: Main photosphere with realistic thermal gradient
    final sunPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.25),
        radius: 0.85,
        colors: const [
          Color(0xFFFFF8DC),  // Cornsilk — hot white-yellow core
          Color(0xFFFFE066),  // Warm gold
          Color(0xFFFFBE0B),  // Deep gold
          Color(0xFFFF9500),  // Solar orange
          Color(0xFFE87400),  // Limb darkening
        ],
        stops: const [0.0, 0.25, 0.5, 0.78, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sunPaint);

    // Layer 6: Specular reflection (natural light catch)
    final specCenter = center.translate(-radius * 0.22, -radius * 0.22);
    final specPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.55),
          Colors.white.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: specCenter, radius: radius * 0.4));
    canvas.drawCircle(specCenter, radius * 0.38, specPaint);
  }

  // ============================================================
  // REALISTIC MOON — Volumetric crescent with surface texture
  // ============================================================
  void _drawRealisticMoon(Canvas canvas, Size size, Offset center) {
    final radius = size.width * 0.28;

    // Layer 1: Moonlight atmospheric haze
    for (int i = 3; i >= 0; i--) {
      final hazeRadius = radius * (1.8 + i * 0.25);
      canvas.drawCircle(
        center,
        hazeRadius,
        Paint()
          ..color = const Color(0xFF94D2E8).withOpacity(0.025 + i * 0.01)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, hazeRadius * 0.4),
      );
    }

    // Layer 2: Soft moon glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x44B8D8E8),
          const Color(0x22B8D8E8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.6));
    canvas.drawCircle(center, radius * 1.6, glowPaint);

    // Layer 3: Full moon sphere (base) with realistic grey-blue surface
    final moonBase = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.25),
        radius: 0.9,
        colors: const [
          Color(0xFFF0F4F8),  // Bright illuminated face
          Color(0xFFD6E4EE),  // Mid-tone
          Color(0xFFB0C4D8),  // Terminator region
          Color(0xFF8AA0B8),  // Limb
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, moonBase);

    // Layer 4: Surface "maria" (dark crater patches) using subtle circles
    final mariaColor = const Color(0x18506878);
    canvas.drawCircle(center.translate(-radius * 0.15, -radius * 0.18), radius * 0.18, Paint()..color = mariaColor);
    canvas.drawCircle(center.translate(radius * 0.12, radius * 0.1), radius * 0.14, Paint()..color = mariaColor);
    canvas.drawCircle(center.translate(-radius * 0.25, radius * 0.22), radius * 0.1, Paint()..color = mariaColor);
    canvas.drawCircle(center.translate(radius * 0.28, -radius * 0.15), radius * 0.08, Paint()..color = mariaColor);

    // Layer 5: Crescent shadow overlay (creates natural crescent shape)
    final shadowCenter = Offset(center.dx + radius * 0.55, center.dy - radius * 0.05);
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.75,
        colors: [
          const Color(0xFF0B1929).withOpacity(0.92),
          const Color(0xFF0B1929).withOpacity(0.7),
          const Color(0xFF0B1929).withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: shadowCenter, radius: radius * 1.05));
    canvas.drawCircle(shadowCenter, radius * 1.05, shadowPaint);

    // Layer 6: Specular highlight on illuminated crescent edge
    final specCenter = center.translate(-radius * 0.3, -radius * 0.2);
    canvas.drawCircle(
      specCenter,
      radius * 0.25,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: specCenter, radius: radius * 0.25)),
    );

    // Layer 7: Stars in the vicinity
    _drawRealisticStar(canvas, Offset(center.dx + radius * 1.1, center.dy - radius * 0.8), size.width * 0.012);
    _drawRealisticStar(canvas, Offset(center.dx - radius * 1.2, center.dy + radius * 0.5), size.width * 0.010);
    _drawRealisticStar(canvas, Offset(center.dx + radius * 0.7, center.dy + radius * 1.0), size.width * 0.008);
  }

  void _drawRealisticStar(Canvas canvas, Offset pos, double radius) {
    // Core glow
    canvas.drawCircle(
      pos,
      radius * 2.5,
      Paint()
        ..color = const Color(0x20FFFFFF)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 3),
    );
    // Bright center
    canvas.drawCircle(
      pos,
      radius,
      Paint()..color = const Color(0xDDFFFFFF),
    );
    // Cross flare
    final flarePaint = Paint()
      ..strokeWidth = radius * 0.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x55FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawLine(
      Offset(pos.dx - radius * 2.5, pos.dy),
      Offset(pos.dx + radius * 2.5, pos.dy),
      flarePaint,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy - radius * 2.5),
      Offset(pos.dx, pos.dy + radius * 2.5),
      flarePaint,
    );
  }

  // ============================================================
  // REALISTIC SUN PEEKING (behind cloud)
  // ============================================================
  void _drawRealisticSunPeeking(Canvas canvas, Size size, Offset center) {
    final sunCenter = Offset(center.dx + size.width * 0.22, center.dy - size.height * 0.22);
    final radius = size.width * 0.2;

    // Atmospheric haze
    canvas.drawCircle(
      sunCenter,
      radius * 2.0,
      Paint()
        ..color = const Color(0x22FFB347)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 1.0),
    );

    // Corona
    final coronaPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0x55FFD700), const Color(0x22FFA500), Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: radius * 1.5));
    canvas.drawCircle(sunCenter, radius * 1.5, coronaPaint);

    // Photosphere
    final sunPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.25),
        radius: 0.85,
        colors: const [
          Color(0xFFFFF8DC),
          Color(0xFFFFE066),
          Color(0xFFFF9500),
          Color(0xFFE87400),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: radius));
    canvas.drawCircle(sunCenter, radius, sunPaint);

    // Specular
    canvas.drawCircle(
      sunCenter.translate(-radius * 0.2, -radius * 0.2),
      radius * 0.28,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(0.45), Colors.transparent],
        ).createShader(Rect.fromCircle(center: sunCenter.translate(-radius * 0.2, -radius * 0.2), radius: radius * 0.28)),
    );
  }

  // ============================================================
  // REALISTIC MOON PEEKING (behind cloud)
  // ============================================================
  void _drawRealisticMoonPeeking(Canvas canvas, Size size, Offset center) {
    final moonCenter = Offset(center.dx + size.width * 0.22, center.dy - size.height * 0.22);
    final radius = size.width * 0.18;

    // Glow
    canvas.drawCircle(
      moonCenter,
      radius * 1.8,
      Paint()
        ..color = const Color(0x22B8D8E8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
    );

    // Moon surface
    final moonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.25),
        radius: 0.9,
        colors: const [
          Color(0xFFF0F4F8),
          Color(0xFFD0DDE8),
          Color(0xFFA8B8C8),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: radius));
    canvas.drawCircle(moonCenter, radius, moonPaint);

    // Crescent shadow
    final shadowCenter = Offset(moonCenter.dx + radius * 0.5, moonCenter.dy);
    canvas.drawCircle(
      shadowCenter,
      radius * 0.9,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF0B1929).withOpacity(0.8),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: shadowCenter, radius: radius * 0.9)),
    );
  }

  // ============================================================
  // REALISTIC CLOUD — Volumetric with natural light scattering
  // ============================================================
  void _drawRealisticCloud(
    Canvas canvas,
    Size size,
    Offset center, {
    required bool isDark,
    bool hasSunBacklight = false,
    bool hasMoonBacklight = false,
  }) {
    final cloudWidth = size.width * 0.75;
    final cloudHeight = size.height * 0.48;
    final cloudCenter = Offset(center.dx, center.dy + size.height * 0.06);

    // Shadow beneath cloud (ambient occlusion)
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cloudCenter.dx, cloudCenter.dy + cloudHeight * 0.45),
        width: cloudWidth * 0.7,
        height: cloudHeight * 0.25,
      ),
      shadowPaint,
    );

    // Define puff positions for volumetric cloud
    final puffs = [
      _CloudPuff(Offset(cloudCenter.dx - cloudWidth * 0.26, cloudCenter.dy + cloudHeight * 0.08), cloudHeight * 0.36),
      _CloudPuff(Offset(cloudCenter.dx - cloudWidth * 0.04, cloudCenter.dy - cloudHeight * 0.16), cloudHeight * 0.50),
      _CloudPuff(Offset(cloudCenter.dx + cloudWidth * 0.24, cloudCenter.dy + cloudHeight * 0.04), cloudHeight * 0.40),
    ];

    // Base pill
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cloudCenter.dx, cloudCenter.dy + cloudHeight * 0.2),
        width: cloudWidth * 0.9,
        height: cloudHeight * 0.5,
      ),
      Radius.circular(cloudHeight * 0.25),
    );

    // Color palette: light clouds or dark storm clouds
    final List<Color> cloudColors = isDark
        ? const [
            Color(0xFFB8C4D0),  // Lighter top
            Color(0xFF8494A7),  // Mid gray-blue
            Color(0xFF5A6B7E),  // Darker mid
            Color(0xFF3D4E60),  // Dark base
          ]
        : const [
            Color(0xFFFFFFFF),  // Bright white top
            Color(0xFFF5F7FA),  // Subtle off-white
            Color(0xFFE4EAF0),  // Light gray undertone
            Color(0xFFD0DAE4),  // Shadow base
          ];

    final cloudShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: cloudColors,
      stops: const [0.0, 0.35, 0.7, 1.0],
    ).createShader(Rect.fromCenter(center: cloudCenter, width: cloudWidth, height: cloudHeight));

    final cloudPaint = Paint()..shader = cloudShader;

    // Draw base shape
    canvas.drawRRect(baseRect, cloudPaint);

    // Draw each puff with its own subtle gradient for volume
    for (final puff in puffs) {
      canvas.drawCircle(puff.center, puff.radius, cloudPaint);
    }

    // Top-light highlight (simulating sky light from above)
    for (final puff in puffs) {
      final highlightCenter = puff.center.translate(0, -puff.radius * 0.3);
      final highlightPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.7,
          colors: [
            Colors.white.withOpacity(isDark ? 0.2 : 0.55),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: highlightCenter, radius: puff.radius * 0.6));
      canvas.drawCircle(highlightCenter, puff.radius * 0.55, highlightPaint);
    }

    // Natural Silver / Golden Lining Backlight when sun or moon is behind
    if (hasSunBacklight) {
      final goldRimPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x99FFD166),
            const Color(0x33FFB703),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(cloudCenter.dx + cloudWidth * 0.2, cloudCenter.dy - cloudHeight * 0.15),
          radius: cloudHeight * 0.5,
        ));
      canvas.drawCircle(
        Offset(cloudCenter.dx + cloudWidth * 0.2, cloudCenter.dy - cloudHeight * 0.15),
        cloudHeight * 0.45,
        goldRimPaint,
      );
    } else if (hasMoonBacklight) {
      final moonRimPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x66B8D8E8),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cloudCenter.dx + cloudWidth * 0.2, cloudCenter.dy - cloudHeight * 0.15),
          radius: cloudHeight * 0.4,
        ));
      canvas.drawCircle(
        Offset(cloudCenter.dx + cloudWidth * 0.2, cloudCenter.dy - cloudHeight * 0.15),
        cloudHeight * 0.38,
        moonRimPaint,
      );
    }

    // Soft rim light on the edges
    final rimHighlight = puffs[1]; // Main top puff
    final rimCenter = rimHighlight.center.translate(-rimHighlight.radius * 0.15, -rimHighlight.radius * 0.35);
    canvas.drawCircle(
      rimCenter,
      rimHighlight.radius * 0.3,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(isDark ? 0.15 : 0.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: rimCenter, radius: rimHighlight.radius * 0.3)),
    );
  }

  // ============================================================
  // REALISTIC RAIN — Streaked droplets with motion blur
  // ============================================================
  void _drawRealisticRain(
    Canvas canvas,
    Size size,
    Offset center, {
    bool isHeavy = false,
    bool isDrizzle = false,
  }) {
    final dropCount = isHeavy ? 13 : (isDrizzle ? 5 : 8);
    final startY = center.dy + size.height * 0.18;
    final dropSpacing = size.width * (isHeavy ? 0.055 : (isDrizzle ? 0.12 : 0.085));

    for (int i = 0; i < dropCount; i++) {
      final x = (center.dx - size.width * 0.32) + (i * dropSpacing);
      final phase = ((animProgress + (i * (isHeavy ? 0.09 : 0.13))) % 1.0);
      final y = startY + phase * size.height * (isHeavy ? 0.32 : 0.26);
      final baseLength = isHeavy ? 0.09 : (isDrizzle ? 0.035 : 0.065);
      final dropLength = size.height * baseLength + (i % 3) * size.height * 0.015;

      // Motion-blurred raindrop streak
      final dropPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(isHeavy ? 0x5590C9E4 : 0x2290C9E4),
            Color(isHeavy ? 0x9990C9E4 : 0x6690C9E4),
            Color(isHeavy ? 0xDD5BA6D6 : 0x995BA6D6),
          ],
        ).createShader(Rect.fromLTWH(x - 1, y - dropLength, 2, dropLength))
        ..strokeWidth = size.width * (isHeavy ? 0.015 : (isDrizzle ? 0.008 : 0.011))
        ..strokeCap = StrokeCap.round;

      // Slight diagonal to simulate wind
      final windDx = isHeavy ? 2.5 : 1.2;
      canvas.drawLine(
        Offset(x - windDx, y - dropLength),
        Offset(x + (windDx * 0.4), y),
        dropPaint,
      );

      // Tiny bright tip at the bottom
      canvas.drawCircle(
        Offset(x + (windDx * 0.4), y),
        size.width * (isHeavy ? 0.006 : 0.004),
        Paint()..color = const Color(0xAA9ED4EA),
      );
    }
  }

  // ============================================================
  // REALISTIC LIGHTNING — Branching bolt with electric glow
  // ============================================================
  void _drawRealisticLightning(Canvas canvas, Size size, Offset center) {
    final startX = center.dx - size.width * 0.04;
    final startY = center.dy + size.height * 0.06;

    final boltPath = Path();
    boltPath.moveTo(startX, startY);
    boltPath.lineTo(startX - size.width * 0.06, startY + size.height * 0.14);
    boltPath.lineTo(startX + size.width * 0.02, startY + size.height * 0.15);
    boltPath.lineTo(startX - size.width * 0.03, startY + size.height * 0.28);
    boltPath.lineTo(startX + size.width * 0.08, startY + size.height * 0.12);
    boltPath.lineTo(startX + size.width * 0.02, startY + size.height * 0.11);
    boltPath.close();

    // Electric field glow (wide)
    canvas.drawPath(
      boltPath,
      Paint()
        ..color = const Color(0x44C8A2FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Inner glow (medium)
    canvas.drawPath(
      boltPath,
      Paint()
        ..color = const Color(0x77E8D4FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Core bolt with hot white-blue gradient
    final boltPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFE8E0FF),
          Color(0xFFD4C4FF),
          Color(0xFFBBA0FF),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(startX, startY + size.height * 0.14),
        width: size.width * 0.15,
        height: size.height * 0.28,
      ));
    canvas.drawPath(boltPath, boltPaint);

    // Small branch
    final branchPaint = Paint()
      ..color = const Color(0x99E8D4FF)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(startX - size.width * 0.03, startY + size.height * 0.18),
      Offset(startX - size.width * 0.09, startY + size.height * 0.22),
      branchPaint,
    );
  }

  // ============================================================
  // REALISTIC SNOW — Soft crystalline flakes with gentle drift
  // ============================================================
  void _drawRealisticSnow(Canvas canvas, Size size, Offset center) {
    final flakeCount = 6;
    final spacing = size.width * 0.12;
    final startY = center.dy + size.height * 0.18;

    for (int i = 0; i < flakeCount; i++) {
      final x = (center.dx - size.width * 0.28) + (i * spacing);
      final phase = ((animProgress + (i * 0.17)) % 1.0);
      final y = startY + phase * size.height * 0.25;

      // Slight horizontal drift
      final drift = math.sin(phase * math.pi * 2 + i) * size.width * 0.015;
      final flakeX = x + drift;

      final flakeRadius = size.width * (0.012 + (i % 3) * 0.004);

      // Soft glow around each flake
      canvas.drawCircle(
        Offset(flakeX, y),
        flakeRadius * 3,
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, flakeRadius * 2),
      );

      // Snowflake body
      canvas.drawCircle(
        Offset(flakeX, y),
        flakeRadius,
        Paint()..color = Colors.white.withOpacity(0.85),
      );

      // Tiny crystalline cross
      final crossPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 0.6
        ..strokeCap = StrokeCap.round;
      final cr = flakeRadius * 1.5;
      canvas.drawLine(Offset(flakeX - cr, y), Offset(flakeX + cr, y), crossPaint);
      canvas.drawLine(Offset(flakeX, y - cr), Offset(flakeX, y + cr), crossPaint);
    }
  }

  // ============================================================
  // REALISTIC FOG — Layered atmospheric mist bands
  // ============================================================
  void _drawRealisticFog(Canvas canvas, Size size, Offset center) {
    final fogY = center.dy + size.height * 0.2;

    for (int i = 0; i < 4; i++) {
      final y = fogY + i * size.height * 0.055;
      final xOffset = math.sin(animProgress * math.pi * 2 + i) * size.width * 0.02;
      final width = size.width * (0.7 - i * 0.08);
      final opacity = 0.25 - i * 0.04;

      final fogRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + xOffset, y),
          width: width,
          height: size.height * 0.025,
        ),
        Radius.circular(size.height * 0.012),
      );

      canvas.drawRRect(
        fogRect,
        Paint()
          ..color = Colors.white.withOpacity(opacity.clamp(0.05, 0.3))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RealisticWeatherPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.isDay != isDay ||
        oldDelegate.animProgress != animProgress;
  }
}

class _CloudPuff {
  final Offset center;
  final double radius;
  const _CloudPuff(this.center, this.radius);
}
