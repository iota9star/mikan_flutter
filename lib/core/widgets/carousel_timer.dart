import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

/// Manages auto-scroll timer for carousel widgets with user interaction awareness.
///
/// Pauses auto-scroll when the user is interacting with the carousel,
/// and resumes after a configurable idle duration.
class CarouselTimerHelper {
  CarouselTimerHelper({
    required InfiniteScrollController controller,
    required double itemExtent,
    Duration interval = const Duration(milliseconds: 3600),
    Duration scrollDuration = const Duration(milliseconds: 800),
    Curve scrollCurve = Curves.easeInOut,
    Duration resumeDelay = const Duration(seconds: 3),
  }) : _controller = controller,
       _itemExtent = itemExtent,
       _interval = interval,
       _scrollDuration = scrollDuration,
       _scrollCurve = scrollCurve,
       _resumeDelay = resumeDelay;

  final InfiniteScrollController _controller;
  final double _itemExtent;
  final Duration _interval;
  final Duration _scrollDuration;
  final Curve _scrollCurve;
  final Duration _resumeDelay;

  Timer? _autoTimer;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;

  /// Start the auto-scroll timer.
  void start() {
    _autoTimer?.cancel();
    _resumeTimer?.cancel();
    _isUserInteracting = false;
    _autoTimer = Timer.periodic(_interval, (_) {
      if (_isUserInteracting || !_controller.hasClients) {
        return;
      }
      _controller.animateToItem(
        (_controller.offset / _itemExtent).round() + 1,
        duration: _scrollDuration,
        curve: _scrollCurve,
      );
    });
  }

  /// Stop the auto-scroll timer.
  void stop() {
    _autoTimer?.cancel();
    _autoTimer = null;
    _resumeTimer?.cancel();
    _resumeTimer = null;
    _isUserInteracting = false;
  }

  /// Dispose all timers. Call in State.dispose().
  void dispose() {
    stop();
  }

  /// Handles user scroll notifications. Wraps the carousel with
  /// [NotificationListener<UserScrollNotification>] using this method.
  bool handleScrollNotification(UserScrollNotification notification) {
    switch (notification.direction) {
      case ScrollDirection.idle:
        // User stopped scrolling — schedule resume
        _isUserInteracting = false;
        _resumeTimer?.cancel();
        _resumeTimer = Timer(_resumeDelay, () {
          if (!_isUserInteracting) {
            _restartTimer();
          }
        });
      case ScrollDirection.forward:
      case ScrollDirection.reverse:
        // User is scrolling — pause auto-scroll
        _isUserInteracting = true;
        _autoTimer?.cancel();
        _resumeTimer?.cancel();
    }
    return false;
  }

  void _restartTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(_interval, (_) {
      if (_isUserInteracting || !_controller.hasClients) {
        return;
      }
      _controller.animateToItem(
        (_controller.offset / _itemExtent).round() + 1,
        duration: _scrollDuration,
        curve: _scrollCurve,
      );
    });
  }
}
