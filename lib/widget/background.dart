import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.color,
    this.phase = 0.0,
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
    for (final color in widget.colors) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 80 + 40;
      final speedX = (random.nextDouble() * 0.4 + 0.2) * (random.nextBool() ? 1 : -1);
      final speedY = (random.nextDouble() * 0.4 + 0.2) * (random.nextBool() ? 1 : -1);
      final phase = random.nextDouble();
      particles.add(Particle(
        x: x,
        y: y,
        radius: radius,
        speedX: speedX,
        speedY: speedY,
        color: color,
        phase: phase,
      ));
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
    for (final particle in particles) {
      final pulse = (sin((animationValue + particle.phase) * 2 * pi * 0.5) + 1) / 2;
      final currentRadius = particle.baseRadius * (0.95 + pulse * 0.1);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.6);

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

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true;
  }
}
