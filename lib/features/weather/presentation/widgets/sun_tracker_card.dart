import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/models/weather_models.dart';
import '../../../shared/widgets/glass_card.dart';

/// Interactive Curved Solar Progression Arc Card (replicates reference design)
class SunTrackerCard extends StatelessWidget {
  final WeatherSnapshot weather;
  final bool isDay;
  final Color glowColor;

  const SunTrackerCard({
    super.key,
    required this.weather,
    required this.isDay,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Estimate daylight progress (0.0 to 1.0)
    final hourFrac = (now.hour + (now.minute / 60.0));
    // Assume 6 AM to 7 PM as day arc
    final sunProgress = ((hourFrac - 6.0) / 13.0).clamp(0.0, 1.0);

    return GlassCard(
      isDay: isDay,
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.wb_twilight_rounded, color: Color(0xFFFFD166), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sun & Daylight Horizon',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isDay ? 'Sun is Active' : 'Night Horizon',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Curved Arc Canvas
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunArcPainter(
                progress: sunProgress,
                isDay: isDay,
                glowColor: glowColor,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Sunrise and Sunset Time Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFB703), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Sunrise',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weather.sunrise,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sunset',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.nightlight_round, color: Color(0xFF64DFDF), size: 14),
                    ],
                  ),
                  Text(
                    weather.sunset,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  final bool isDay;
  final Color glowColor;

  _SunArcPainter({
    required this.progress,
    required this.isDay,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(20, 10, size.width - 40, size.height * 1.6);

    // 1. Dashed or soft background arc
    final bgArcPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawArc(rect, math.pi, math.pi, false, bgArcPaint);

    // 2. Active illuminated arc
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB703), Color(0xFFFFD166), Color(0xFF64DFDF)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    final sweepAngle = math.pi * progress;
    canvas.drawArc(rect, math.pi, sweepAngle, false, activePaint);

    // 3. Glowing Celestial Indicator (Sun/Moon bead)
    final angle = math.pi + sweepAngle;
    final rx = (size.width - 40) / 2;
    final ry = (size.height * 1.6) / 2;
    final cx = rect.center.dx;
    final cy = rect.center.dy;

    final beadX = cx + rx * math.cos(angle);
    final beadY = cy + ry * math.sin(angle);
    final beadCenter = Offset(beadX, beadY);

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0x88FFD166)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(beadCenter, 10, glowPaint);

    // Bead
    final beadPaint = Paint()
      ..shader = RadialGradient(
        colors: isDay
            ? const [Color(0xFFFFF9A6), Color(0xFFFFB703)]
            : const [Color(0xFFE0FBFC), Color(0xFF64DFDF)],
      ).createShader(Rect.fromCircle(center: beadCenter, radius: 6));
    canvas.drawCircle(beadCenter, 6, beadPaint);
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDay != isDay;
  }
}
