import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/weather_condition_mapper.dart';

/// Full-screen ambient atmospheric particle layer (Stars for night, Rain for storm/rain, Solar rays for sunny)
class WeatherParticles extends StatefulWidget {
  final WeatherType weatherType;
  final bool isDay;

  const WeatherParticles({
    super.key,
    required this.weatherType,
    required this.isDay,
  });

  @override
  State<WeatherParticles> createState() => _WeatherParticlesState();
}

class _WeatherParticlesState extends State<WeatherParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _generateParticles();
  }

  void _generateParticles() {
    _particles.clear();
    final count = !widget.isDay ? 35 : (widget.weatherType == WeatherType.rain || widget.weatherType == WeatherType.thunderstorm ? 40 : 15);
    for (int i = 0; i < count; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.1 + _random.nextDouble() * 0.4,
        size: 1.5 + _random.nextDouble() * 3.0,
        opacity: 0.2 + _random.nextDouble() * 0.6,
        phase: _random.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant WeatherParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherType != widget.weatherType || oldWidget.isDay != widget.isDay) {
      _generateParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              particles: _particles,
              progress: _controller.value,
              weatherType: widget.weatherType,
              isDay: widget.isDay,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final WeatherType weatherType;
  final bool isDay;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.weatherType,
    required this.isDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final isRain = weatherType == WeatherType.rain ||
        weatherType == WeatherType.drizzle ||
        weatherType == WeatherType.heavyRain ||
        weatherType == WeatherType.thunderstorm;

    if (isRain) {
      // Falling Rain Streak Particles
      final rainPaint = Paint()
        ..color = const Color(0x6648CAE4)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.5;

      for (final p in particles) {
        final currentY = ((p.y + progress * (p.speed * 4)) % 1.0) * size.height;
        final currentX = ((p.x + progress * 0.1) % 1.0) * size.width;
        canvas.drawLine(
          Offset(currentX, currentY),
          Offset(currentX - 3, currentY + 12),
          rainPaint..color = Colors.white.withOpacity(p.opacity * 0.5),
        );
      }
    } else if (!isDay) {
      // Cosmic Twinkling Stars
      for (final p in particles) {
        final twinkle = (math.sin(progress * 2 * math.pi + p.phase) + 1.0) / 2.0;
        final alpha = (p.opacity * (0.3 + twinkle * 0.7)).clamp(0.0, 1.0);
        final paint = Paint()..color = Colors.white.withOpacity(alpha);
        final currentX = p.x * size.width;
        final currentY = p.y * size.height;
        canvas.drawCircle(Offset(currentX, currentY), p.size * (0.8 + twinkle * 0.4), paint);
      }
    } else {
      // Subtle floating daytime dust / sun dust particles
      for (final p in particles) {
        final currentY = ((p.y - progress * p.speed * 0.5) % 1.0) * size.height;
        final currentX = ((p.x + math.sin(progress * 2 * math.pi + p.phase) * 0.05) % 1.0) * size.width;
        final paint = Paint()..color = Colors.white.withOpacity(p.opacity * 0.25);
        canvas.drawCircle(Offset(currentX, currentY), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
