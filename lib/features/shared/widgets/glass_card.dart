import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Premium 3D Glassmorphic Card Widget with specular highlights and optional touch tilt
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isDay;
  final VoidCallback? onTap;
  final double blurSigma;
  final Color? glowColor;
  final bool enableTilt;
  final double elevation;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius = 24.0,
    this.isDay = true,
    this.onTap,
    this.blurSigma = 16.0,
    this.glowColor,
    this.enableTilt = false,
    this.elevation = 8.0,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isPressed = false;

  void _onPointerMove(PointerMoveEvent event, BoxConstraints constraints) {
    if (!widget.enableTilt) return;
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    if (width <= 0 || height <= 0) return;

    final dx = (event.localPosition.dx / width) - 0.5;
    final dy = (event.localPosition.dy / height) - 0.5;

    setState(() {
      _tiltX = -dy * 0.15;
      _tiltY = dx * 0.15;
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    if (!widget.enableTilt) return;
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = widget.glowColor ?? (widget.isDay ? const Color(0x26FFFFFF) : const Color(0x3348CAE4));

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget cardContent = ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isDay
                      ? [
                          const Color(0x40FFFFFF),
                          const Color(0x1AFFFFFF),
                          const Color(0x26FFFFFF),
                        ]
                      : [
                          const Color(0x38243B55),
                          const Color(0x24141E30),
                          const Color(0x301E293B),
                        ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                border: Border.all(
                  width: 1.2,
                  color: widget.isDay ? const Color(0x66FFFFFF) : const Color(0x3390E0EF),
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveGlow,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  const BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );

        if (widget.enableTilt) {
          cardContent = Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX)
              ..rotateY(_tiltY)
              ..scale(_isPressed ? 0.98 : 1.0),
            child: cardContent,
          );
        }

        Widget interactive = MouseRegion(
          onExit: _onPointerExit,
          child: Listener(
            onPointerMove: (e) => _onPointerMove(e, constraints),
            onPointerDown: (_) => setState(() => _isPressed = true),
            onPointerUp: (_) => setState(() => _isPressed = false),
            child: widget.onTap != null
                ? InkWell(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    onTap: widget.onTap,
                    child: cardContent,
                  )
                : cardContent,
          ),
        );

        if (widget.margin != null) {
          interactive = Padding(padding: widget.margin!, child: interactive);
        }

        return interactive;
      },
    );
  }
}
