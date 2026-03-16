import 'dart:math' as math;

import 'package:flutter/material.dart';

final _random = math.Random();

class ParticleEffect {
  ParticleEffect._();

  static void show(
    BuildContext context, {
    required Color color,
    int? particleCount,
    double? minSize,
    double? maxSize,
    double? minPercentOfDistance,
    double? maxPercentOfDistance,
    double? minSpeedOfRotate,
    double? maxSpeedOfRotate,
    Duration? duration,
  }) {
    final overlayState = Overlay.of(context, rootOverlay: true);

    final effectWidget = _ParticleEffectWidget(
      color: color,
      particleCount: particleCount,
      minSize: minSize,
      maxSize: maxSize,
      minPercentOfDistance: minPercentOfDistance,
      maxPercentOfDistance: maxPercentOfDistance,
      minSpeedOfRotate: minSpeedOfRotate,
      maxSpeedOfRotate: maxSpeedOfRotate,
      duration: duration,
      onComplete: () {
        _currentOverlayEntry?.remove();
        _currentOverlayEntry = null;
      },
    );

    final overlayEntry = OverlayEntry(
      builder: (_) => Positioned.fill(child: IgnorePointer(child: effectWidget)),
    );

    _currentOverlayEntry?.remove();
    _currentOverlayEntry = overlayEntry;

    overlayState.insert(overlayEntry);
  }

  static OverlayEntry? _currentOverlayEntry;
}

class _ParticleEffectWidget extends StatefulWidget {
  const _ParticleEffectWidget({
    required this.color,
    this.particleCount,
    this.minSize,
    this.maxSize,
    this.minPercentOfDistance,
    this.maxPercentOfDistance,
    this.minSpeedOfRotate,
    this.maxSpeedOfRotate,
    this.duration,
    required this.onComplete,
  });

  final Color color;
  final int? particleCount;
  final double? minSize;
  final double? maxSize;
  final double? minPercentOfDistance;
  final double? maxPercentOfDistance;
  final double? minSpeedOfRotate;
  final double? maxSpeedOfRotate;
  final Duration? duration;
  final VoidCallback onComplete;

  @override
  State<_ParticleEffectWidget> createState() => _ParticleEffectWidgetState();
}

class _ParticleEffectWidgetState extends State<_ParticleEffectWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  static const _defaultMinSize = 4.0;
  static const _defaultMaxSize = 14.0;
  static const _defaultMinPercentOfDistance = 0.50;
  static const _defaultMaxPercentOfDistance = 0.90;
  static const _defaultMinNumberOfParticle = 50;
  static const _defaultMaxNumberOfParticle = 70;
  static const _defaultMinSpeedOfRotate = 0.5;
  static const _defaultMaxSpeedOfRotate = 20.0;
  static const _defaultDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration ?? _defaultDuration);
    _generateParticles();
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  void _generateParticles() {
    final minSize = widget.minSize ?? _defaultMinSize;
    final maxSize = widget.maxSize ?? _defaultMaxSize;
    final minPercentOfDistance = widget.minPercentOfDistance ?? _defaultMinPercentOfDistance;
    final maxPercentOfDistance = widget.maxPercentOfDistance ?? _defaultMaxPercentOfDistance;
    final maxNumberOfParticle =
        widget.particleCount ??
        _random.nextInt(_defaultMaxNumberOfParticle - _defaultMinNumberOfParticle + 1) + _defaultMinNumberOfParticle;
    final minSpeedOfRotate = widget.minSpeedOfRotate ?? _defaultMinSpeedOfRotate;
    final maxSpeedOfRotate = widget.maxSpeedOfRotate ?? _defaultMaxSpeedOfRotate;

    _particles = List.generate(maxNumberOfParticle, (index) {
      return Particle(
        size: _random.nextDouble() * (maxSize - minSize) + minSize,
        color: widget.color,
        percentOfDistance: _random.nextDouble() * (maxPercentOfDistance - minPercentOfDistance) + minPercentOfDistance,
        shape: ParticleShape.from(_random.nextDouble()),
        speedOfRotate: _random.nextDouble() * (maxSpeedOfRotate - minSpeedOfRotate) + minSpeedOfRotate,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(particles: _particles, animation: _controller.view, curve: Curves.easeOutCubic),
          );
        },
      ),
    );
  }
}

enum ParticleShape {
  circle,
  square,
  rectangle,
  triangle;

  factory ParticleShape.from(double v) {
    return switch (v) {
      < 0.12 => ParticleShape.circle,
      < 0.24 => ParticleShape.rectangle,
      < 0.36 => ParticleShape.triangle,
      _ => ParticleShape.square,
    };
  }
}

class Particle {
  Particle({
    required this.size,
    required this.color,
    required this.percentOfDistance,
    required this.speedOfRotate,
    required this.shape,
  });

  final double size;
  final Color color;
  final double percentOfDistance;
  final double speedOfRotate;
  final ParticleShape shape;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Particle &&
          runtimeType == other.runtimeType &&
          size == other.size &&
          color == other.color &&
          percentOfDistance == other.percentOfDistance &&
          speedOfRotate == other.speedOfRotate &&
          shape == other.shape;

  @override
  int get hashCode => Object.hash(size, color, percentOfDistance, speedOfRotate, shape);
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({required this.particles, required this.animation, required this.curve}) : super(repaint: animation);

  final List<Particle> particles;
  final Animation<double> animation;
  final Curve curve;

  static const _twoPi = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = curve.transform(animation.value);

    if (progress >= 1.0) {
      return;
    }

    final gap = size.width / (particles.length + 1);

    final normalPaint = Paint()..style = PaintingStyle.fill;
    final rectanglePaint = Paint()..style = PaintingStyle.fill;

    const sinValue = -1.0;

    final alpha = progress < 0.99 ? 1.0 : (1 - progress) / 0.01;

    if (alpha <= 0.0) {
      return;
    }

    for (int i = 0; i < particles.length; ++i) {
      final particle = particles[i];

      if (particle.shape == ParticleShape.rectangle) {
        final rectAlpha = progress > 0.70 ? (progress < 0.99 ? 1.0 : (1 - progress) / 0.01) : progress / 0.70;

        if (rectAlpha <= 0.0) {
          continue;
        }

        final height = size.height * particle.percentOfDistance;
        final tx = gap * (i + 1);
        final ty = size.height + progress * height * sinValue;

        rectanglePaint.color = particle.color.withValues(alpha: rectAlpha);

        final rect = Rect.fromCenter(
          center: Offset(tx, ty + height / 2 * (1 - progress) + particle.size / 2),
          width: particle.size,
          height: math.max(particle.size, height / 2 * (1 - progress)),
        );
        canvas.drawRect(rect, rectanglePaint);
      } else {
        final height = size.height * particle.percentOfDistance;
        final tx = gap * (i + 1);
        final ty = size.height + progress * height * sinValue;

        final particleColor = particle.color.withValues(alpha: alpha);

        if (particle.shape == ParticleShape.circle) {
          normalPaint.color = particleColor;
          canvas.drawCircle(Offset(tx, ty + particle.size / 2), particle.size / 2, normalPaint);
        } else {
          canvas.save();
          canvas.translate(tx, ty + particle.size / 2);

          final rotationAngle = _twoPi * progress * particle.speedOfRotate;
          canvas.rotate(rotationAngle);

          final scale = progress < 0.85 ? 1.0 : (1 - (progress - 0.85) / 0.15);

          final halfSize = particle.size / 2;

          if (particle.shape == ParticleShape.square) {
            final rect = Rect.fromLTRB(-halfSize, -halfSize, halfSize, halfSize);
            normalPaint.color = particleColor;
            canvas.scale(scale);
            canvas.drawRect(rect, normalPaint);
          } else if (particle.shape == ParticleShape.triangle) {
            final path = Path()
              ..moveTo(0, -halfSize)
              ..lineTo(-halfSize, halfSize)
              ..lineTo(halfSize, halfSize)
              ..close();
            normalPaint.color = particleColor;
            canvas.scale(scale);
            canvas.drawPath(path, normalPaint);
          }

          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}
