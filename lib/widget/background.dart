import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum ParticleLayer {
  background,
  middle,
  foreground,
}

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.color,
    this.phase = 0.0,
    this.layer = ParticleLayer.middle,
    double? pulseSpeed,
  })  : pulseSpeed = pulseSpeed ?? 0.02 + Random().nextDouble() * 0.02,
        baseRadius = radius;

  double x;
  double y;
  double radius;
  double speedX;
  double speedY;
  final Color color;
  final double phase;
  final double pulseSpeed;
  final double baseRadius;
  final ParticleLayer layer;
}

class BubbleBackground extends StatefulWidget {
  const BubbleBackground({super.key, required this.child, required this.colors});

  final Widget child;
  final List<Color> colors;

  @override
  BubbleBackgroundState createState() => BubbleBackgroundState();
}

class BubbleBackgroundState extends State<BubbleBackground> with SingleTickerProviderStateMixin {
  final List<Particle> particles = [];
  late AnimationController _controller;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    if (_lastSize == null || size != _lastSize) {
      _lastSize = size;
      createParticles(size);
    }
  }

  void createParticles(Size size) {
    final random = Random();
    particles.clear();

    final area = size.width * size.height;
    final particleCount = (area / 120000).clamp(5, 20).round();

    final points = _poissonDiscSampling(
      width: size.width,
      height: size.height,
      minDist: 200,
      maxAttempts: 30,
      targetPoints: particleCount,
    );

    final layerCounts = {
      ParticleLayer.background: (particleCount * 0.3).round().clamp(1, particleCount),
      ParticleLayer.middle: (particleCount * 0.4).round().clamp(1, particleCount),
      ParticleLayer.foreground: (particleCount * 0.3).round().clamp(1, particleCount),
    };

    int pointIndex = 0;
    for (final layer in ParticleLayer.values) {
      final count = layerCounts[layer]!;
      for (int i = 0; i < count && pointIndex < points.length; i++, pointIndex++) {
        final point = points[pointIndex];
        final colorIndex = random.nextInt(widget.colors.length);
        final color = widget.colors[colorIndex];

        final layerSettings = _getLayerSettings(layer);
        final radius = layerSettings.radiusRange(random);
        final speedMultiplier = layerSettings.speedMultiplier;
        final alpha = layerSettings.alpha;

        final speedX = (random.nextDouble() * 0.4 + 0.2) * (random.nextBool() ? 1 : -1) * speedMultiplier;
        final speedY = (random.nextDouble() * 0.4 + 0.2) * (random.nextBool() ? 1 : -1) * speedMultiplier;
        final phase = random.nextDouble() * 2 * pi;

        particles.add(Particle(
          x: point.x,
          y: point.y,
          radius: radius,
          speedX: speedX,
          speedY: speedY,
          color: color.withValues(alpha: alpha),
          phase: phase,
          layer: layer,
        ));
      }
    }
  }

  List<_Point> _poissonDiscSampling({
    required double width,
    required double height,
    required double minDist,
    required int maxAttempts,
    required int targetPoints,
  }) {
    final random = Random();
    final List<_Point> points = [];
    final List<_Point> activeList = [];

    final cellSize = minDist / sqrt(2);
    final gridWidth = (width / cellSize).ceil() + 1;
    final gridHeight = (height / cellSize).ceil() + 1;
    final grid = List<List<_Point?>>.generate(
      gridHeight,
      (_) => List<_Point?>.filled(gridWidth, null),
    );

    _Point addPoint(double x, double y) {
      final point = _Point(x, y);
      final cellX = (x / cellSize).floor();
      final cellY = (y / cellSize).floor();
      if (cellX >= 0 && cellX < gridWidth && cellY >= 0 && cellY < gridHeight) {
        grid[cellY][cellX] = point;
      }
      return point;
    }

    bool isValidPoint(double x, double y) {
      final cellX = (x / cellSize).floor();
      final cellY = (y / cellSize).floor();

      final minX = (cellX - 2).clamp(0, gridWidth - 1);
      final maxX = (cellX + 2).clamp(0, gridWidth - 1);
      final minY = (cellY - 2).clamp(0, gridHeight - 1);
      final maxY = (cellY + 2).clamp(0, gridHeight - 1);

      for (int cy = minY; cy <= maxY; cy++) {
        for (int cx = minX; cx <= maxX; cx++) {
          final neighbor = grid[cy][cx];
          if (neighbor != null) {
            final dx = x - neighbor.x;
            final dy = y - neighbor.y;
            if (dx * dx + dy * dy < minDist * minDist) {
              return false;
            }
          }
        }
      }
      return true;
    }

    final firstPoint = _Point(random.nextDouble() * width, random.nextDouble() * height);
    points.add(firstPoint);
    activeList.add(firstPoint);
    addPoint(firstPoint.x, firstPoint.y);

    while (activeList.isNotEmpty && points.length < targetPoints) {
      final randomIndex = random.nextInt(activeList.length);
      final currentPoint = activeList[randomIndex];
      var found = false;

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final angle = random.nextDouble() * 2 * pi;
        final distance = minDist + random.nextDouble() * minDist;
        final newX = currentPoint.x + cos(angle) * distance;
        final newY = currentPoint.y + sin(angle) * distance;

        if (newX >= 0 && newX <= width && newY >= 0 && newY <= height) {
          if (isValidPoint(newX, newY)) {
            final newPoint = addPoint(newX, newY);
            points.add(newPoint);
            activeList.add(newPoint);
            found = true;
            break;
          }
        }
      }

      if (!found) {
        activeList.removeAt(randomIndex);
      }
    }

    return points;
  }

  _LayerSettings _getLayerSettings(ParticleLayer layer) {
    switch (layer) {
      case ParticleLayer.background:
        return _LayerSettings(
          radiusRange: (random) => random.nextDouble() * 60 + 80,
          speedMultiplier: 0.3,
          alpha: 0.15,
        );
      case ParticleLayer.middle:
        return _LayerSettings(
          radiusRange: (random) => random.nextDouble() * 50 + 50,
          speedMultiplier: 0.6,
          alpha: 0.3,
        );
      case ParticleLayer.foreground:
        return _LayerSettings(
          radiusRange: (random) => random.nextDouble() * 40 + 30,
          speedMultiplier: 1.0,
          alpha: 0.5,
        );
    }
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    for (final particle in particles) {
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      if (particle.x - particle.radius < 0 || particle.x + particle.radius > size.width) {
        particle.speedX *= -1;
        particle.x = particle.x.clamp(particle.radius, size.width - particle.radius);
      }
      if (particle.y - particle.radius < 0 || particle.y + particle.radius > size.height) {
        particle.speedY *= -1;
        particle.y = particle.y.clamp(particle.radius, size.height - particle.radius);
      }
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
        _updateParticles();
        return CustomPaint(
          painter: ParticlePainter(particles, _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter(this.particles, this.animationValue);

  final List<Particle> particles;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final sortedParticles = List<Particle>.from(particles)
      ..sort((a, b) => _layerOrder(a.layer).compareTo(_layerOrder(b.layer)));

    for (final particle in sortedParticles) {
      final pulse = (sin((animationValue + particle.phase) * 2 * pi * 0.5) + 1) / 2;
      final currentRadius = particle.baseRadius * (0.95 + pulse * 0.1);

      final paint = Paint()
        ..color = particle.color;

      final bounds = Rect.fromCircle(
        center: Offset(particle.x, particle.y),
        radius: currentRadius + 25,
      );

      canvas.saveLayer(bounds, Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20));
      canvas.clipRect(bounds);
      canvas.drawCircle(Offset(particle.x, particle.y), currentRadius, paint);
      canvas.restore();
    }
  }

  int _layerOrder(ParticleLayer layer) {
    switch (layer) {
      case ParticleLayer.background:
        return 0;
      case ParticleLayer.middle:
        return 1;
      case ParticleLayer.foreground:
        return 2;
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true;
  }
}

class _Point {
  _Point(this.x, this.y);
  final double x;
  final double y;
}

class _LayerSettings {
  _LayerSettings({
    required this.radiusRange,
    required this.speedMultiplier,
    required this.alpha,
  });

  final double Function(Random) radiusRange;
  final double speedMultiplier;
  final double alpha;
}
