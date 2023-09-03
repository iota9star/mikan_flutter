import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ParticleController {
  ParticleWrapperState? _state;

  final _random = math.Random();

  void play([Color color = Colors.blue]) {
    final state = _state;
    if (state == null) {
      return;
    }
    final widget = state.widget;
    state.particles = List.generate(
      (_random.nextDouble() *
                  (widget.maxNumberOfParticle - widget.minNumberOfParticle))
              .toInt() +
          widget.minNumberOfParticle,
      (index) => Particle(
        size: _random.nextDouble() * (widget.maxSize - widget.minSize) +
            widget.minSize,
        color: color,
        percentOfDistance: _random.nextDouble() *
                (widget.maxPercentOfDistance - widget.minPercentOfDistance) +
            widget.minPercentOfDistance,
        shape: ParticleShape.from(_random.nextDouble()),
        speedOfRotate: _random.nextDouble() *
                (widget.maxSpeedOfRotate - widget.minSpeedOfRotate) +
            widget.minSpeedOfRotate,
      ),
    );
    state._controller.reset();
    state._controller.forward();
  }

  void _dispose() {
    _state = null;
  }
}

class ParticleWrapper extends StatefulWidget {
  const ParticleWrapper({
    super.key,
    required this.controller,
    this.maxSize = 10.0,
    this.minSize = 6.0,
    this.maxPercentOfDistance = 0.9,
    this.minPercentOfDistance = 0.7,
    this.maxNumberOfParticle = 64,
    this.minNumberOfParticle = 48,
    this.maxSpeedOfRotate = 16.0,
    this.minSpeedOfRotate = 1.0,
    this.duration = const Duration(milliseconds: 2400),
    this.child,
  });

  final ParticleController controller;
  final double maxSize;

  final double minSize;
  final double maxPercentOfDistance;

  final double minPercentOfDistance;

  final int maxNumberOfParticle;

  final int minNumberOfParticle;

  final double maxSpeedOfRotate;
  final double minSpeedOfRotate;
  final Duration duration;

  final Widget? child;

  @override
  ParticleWrapperState createState() => ParticleWrapperState();
}

class ParticleWrapperState extends State<ParticleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _controller.reset();
    //   }
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.controller._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: ParticlePainter(
        particles: particles,
        animation: _controller.view,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
      child: widget.child,
    );
  }
}

enum ParticleShape {
  circle,
  square,
  rectangle,
  triangle,
  ;

  factory ParticleShape.from(double v) {
    if (v < 0.1) {
      return ParticleShape.circle;
    } else if (v < 0.2) {
      return ParticleShape.rectangle;
    } else if (v < 0.3) {
      return ParticleShape.triangle;
    } else {
      return ParticleShape.square;
    }
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
  int get hashCode =>
      size.hashCode ^
      color.hashCode ^
      percentOfDistance.hashCode ^
      speedOfRotate.hashCode ^
      shape.hashCode;
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.curve,
  }) : super(repaint: animation);
  final List<Particle> particles;
  final Animation<double> animation;
  final Curve curve;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = curve.transform(animation.value);
    final gap = size.width / (particles.length + 1);
    for (int i = 0; i < particles.length; ++i) {
      final particle = particles[i];
      final height = size.height * particle.percentOfDistance;
      const radians = math.pi * 3 / 2;
      final tx = gap * (i + 1) + progress * math.cos(radians);
      final ty = size.height + progress * height * math.sin(radians);
      final paint = ParticleShape.rectangle == particle.shape
          ? (Paint()
            ..color = particle.color.withOpacity(
              progress > 0.75
                  ? (progress < 0.999 ? 1.0 : (1 - progress) / 0.001)
                  : progress / 0.75,
            )
            ..style = PaintingStyle.fill)
          : (Paint()
            ..color = particle.color
                .withOpacity(progress < 0.999 ? 1.0 : (1 - progress) / 0.001)
            ..style = PaintingStyle.fill);
      canvas.save();
      canvas.translate(tx, ty + particle.size / 2);
      if (particle.shape case ParticleShape.circle) {
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      } else if (particle.shape case ParticleShape.square) {
        canvas.rotate(2 * math.pi * progress * particle.speedOfRotate);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        );
        canvas.drawRect(rect, paint);
      } else if (particle.shape case ParticleShape.triangle) {
        canvas.rotate(2 * math.pi * progress * particle.speedOfRotate);
        final path = Path();
        final halfSize = particle.size / 2;
        path.moveTo(0, -halfSize);
        path.lineTo(-halfSize, halfSize);
        path.lineTo(halfSize, halfSize);
        path.close();
        canvas.drawPath(path, paint);
      } else if (particle.shape case ParticleShape.rectangle) {
        final rect = Rect.fromCenter(
          center: Offset(0, height / 2 * (1 - progress)),
          width: particle.size,
          height: math.max(particle.size, height / 2 - height / 2 * progress),
        );
        canvas.drawRect(rect, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.curve != curve ||
        !listEquals(oldDelegate.particles, particles);
  }
}
