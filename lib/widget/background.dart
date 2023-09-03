import 'dart:math';

import 'package:flutter/material.dart';

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.color,
  });

  double x;
  double y;
  final double radius;
  double speedX;
  double speedY;
  final Color color;
}

class BubbleBackground extends StatefulWidget {
  const BubbleBackground({
    super.key,
    required this.child,
    required this.colors,
  });

  final Widget child;
  final List<Color> colors;

  @override
  BubbleBackgroundState createState() => BubbleBackgroundState();
}

class BubbleBackgroundState extends State<BubbleBackground>
    with TickerProviderStateMixin {
  final List<Particle> particles = [];

  final _notifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    tick();
  }

  Future<void> tick() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) {
        return;
      }
      if (particles.isEmpty) {
        createParticles(context.size!);
      }
      for (final particle in particles) {
        particle.x += particle.speedX;
        particle.y += particle.speedY;

        if (particle.x < 0 || particle.x > MediaQuery.of(context).size.width) {
          particle.speedX *= -1;
        }
        if (particle.y < 0 || particle.y > MediaQuery.of(context).size.height) {
          particle.speedY *= -1;
        }
      }
      _notifier.value = _notifier.value + 1;
    }
  }

  void createParticles(Size size) {
    final random = Random();
    for (final color in widget.colors) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 100 + 50;
      final speedX = random.nextDouble() * 2 - 1;
      final speedY = random.nextDouble() * 2 - 1;
      final particle = Particle(
        x: x,
        y: y,
        radius: radius,
        speedX: speedX,
        speedY: speedY,
        color: color,
      );
      particles.add(particle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles, _notifier),
      child: widget.child,
    );
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter(this.particles, Listenable listenable)
      : super(repaint: listenable);

  final List<Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        Paint()..color = particle.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
