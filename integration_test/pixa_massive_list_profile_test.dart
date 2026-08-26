import 'dart:io';
import 'dart:ui' show FlutterView, FrameTiming;

import 'package:flutter/foundation.dart' show kProfileMode;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pixa/pixa.dart';
import 'package:pixa/pixa_debug.dart';

import 'package:mikan/features/home/presentation/widgets/index.dart';
import 'package:mikan/main.dart' as app;

const int _flingCount = 8;
const Offset _flingDown = Offset(0, -2200);
const Offset _flingUp = Offset(0, 2200);
const double _flingVelocity = 16000;
const Duration _flingSettle = Duration(seconds: 4);
const Duration _probeInterval = Duration(milliseconds: 100);

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('massive cover list remains bounded during rapid flings', (WidgetTester tester) async {
    expect(kProfileMode, isTrue, reason: 'Run this evidence test with flutter drive --profile.');

    await app.main();
    final _ScrollableTarget target = await _waitForMassiveList(tester);
    final Map<String, Object?> pixaBefore = PixaDebugInspector.snapshot().toJson();

    final Map<String, dynamic> performance = await _capturePerformance(binding, tester, () async {
      for (var fling = 0; fling < _flingCount; fling += 1) {
        await tester.fling(target.finder, fling.isEven ? _flingDown : _flingUp, _flingVelocity);
        await tester.pump(_flingSettle);
      }
    });
    expect(performance['frame_count'], greaterThan(1000));
    final Map<String, Object?> initialDrain = await _waitForPixaDrain(tester);

    final List<int> rssSamples = <int>[];
    for (var sample = 0; sample < 10; sample += 1) {
      await tester.pump(const Duration(seconds: 1));
      rssSamples.add(ProcessInfo.currentRss);
    }
    final Map<String, Object?> finalDrain = await _waitForPixaDrain(tester);

    final FlutterView view = binding.platformDispatcher.views.single;
    binding.reportData = <String, dynamic>{
      'performance': performance,
      'variant': const String.fromEnvironment('MIKAN_PIXA_PROFILE_VARIANT', defaultValue: 'g43_current'),
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'displayRefreshRate': view.display.refreshRate,
      'devicePixelRatio': view.devicePixelRatio,
      'maxScrollExtent': target.position.maxScrollExtent,
      'pixaBefore': pixaBefore,
      'pixaAfter': PixaDebugInspector.snapshot().toJson(),
      'initialDrain': initialDrain,
      'finalDrain': finalDrain,
      'rssSamples': rssSamples,
    };
  });
}

Future<Map<String, dynamic>> _capturePerformance(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  Future<void> Function() action,
) async {
  await tester.pump(const Duration(seconds: 2));
  final List<FrameTiming> timings = <FrameTiming>[];
  final void Function(List<FrameTiming>) callback = timings.addAll;
  binding.addTimingsCallback(callback);
  try {
    await action();
    await tester.pump(const Duration(seconds: 2));
  } finally {
    binding.removeTimingsCallback(callback);
  }
  if (timings.isEmpty) {
    throw StateError('Rapid fling scenario produced no FrameTiming samples.');
  }
  return FrameTimingSummarizer(timings).summary;
}

Future<_ScrollableTarget> _waitForMassiveList(WidgetTester tester) async {
  final Stopwatch timeout = Stopwatch()..start();
  while (timeout.elapsed < const Duration(seconds: 45)) {
    final Finder index = find.byType(IndexFragment);
    final Finder verticalScrollable = find.descendant(
      of: index,
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is Scrollable && axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
      ),
    );
    for (final Element element in verticalScrollable.evaluate()) {
      final ScrollableState state = (element as StatefulElement).state as ScrollableState;
      if (state.position.hasContentDimensions && state.position.maxScrollExtent >= 8000) {
        return _ScrollableTarget(
          finder: find.byElementPredicate((Element candidate) => identical(candidate, element)),
          position: state.position,
        );
      }
    }
    await tester.pump(_probeInterval);
  }
  throw StateError('Mikan massive list did not expose a vertical scroll extent >= 8000px.');
}

Future<Map<String, Object?>> _waitForPixaDrain(WidgetTester tester) async {
  final Stopwatch timeout = Stopwatch()..start();
  var stableProbes = 0;
  var activityRestarts = 0;
  var maxActiveRuntimeLoads = 0;
  var maxLiveProgressSessions = 0;
  while (timeout.elapsed < const Duration(seconds: 90)) {
    final PixaSchedulerStats scheduler = Pixa.pipeline.schedulerStats();
    final PixaCacheStats cache = Pixa.cacheStats();
    final PixaDebugSnapshot debug = PixaDebugInspector.snapshot();
    maxActiveRuntimeLoads = maxActiveRuntimeLoads < scheduler.activeRuntimeLoads
        ? scheduler.activeRuntimeLoads
        : maxActiveRuntimeLoads;
    maxLiveProgressSessions = maxLiveProgressSessions < cache.liveProgressSessions
        ? cache.liveProgressSessions
        : maxLiveProgressSessions;
    final bool drained =
        scheduler.activeRuntimeLoads == 0 &&
        scheduler.queueDepth == 0 &&
        scheduler.inflightRequests == 0 &&
        scheduler.listeners == 0 &&
        cache.liveOwnedBufferHandles == 0 &&
        cache.liveProgressSessions == 0 &&
        debug.displayDecoder.completionQueueDepth == 0 &&
        !debug.displayDecoder.completionFrameScheduled;
    if (!drained && stableProbes > 0) {
      activityRestarts += 1;
    }
    stableProbes = drained ? stableProbes + 1 : 0;
    if (stableProbes >= 10) {
      return <String, Object?>{
        'elapsedMillis': timeout.elapsedMilliseconds,
        'stableWindowMillis': stableProbes * _probeInterval.inMilliseconds,
        'activityRestarts': activityRestarts,
        'maxActiveRuntimeLoads': maxActiveRuntimeLoads,
        'maxLiveProgressSessions': maxLiveProgressSessions,
        'scheduler': scheduler.toJson(),
        'cache': <String, Object?>{
          'liveOwnedBufferHandles': cache.liveOwnedBufferHandles,
          'liveProgressSessions': cache.liveProgressSessions,
          'progressSessionsCreated': cache.progressSessionsCreated,
          'progressSessionsFreed': cache.progressSessionsFreed,
        },
        'display': debug.displayDecoder.toJson(),
      };
    }
    await tester.pump(_probeInterval);
  }
  final PixaDebugSnapshot debug = PixaDebugInspector.snapshot();
  final PixaCacheStats cache = Pixa.cacheStats();
  throw StateError(
    'Pixa did not drain after rapid flings: '
    'scheduler=${debug.schedulerStats?.toJson()}, '
    'liveOwnedBufferHandles=${cache.liveOwnedBufferHandles}, '
    'liveProgressSessions=${cache.liveProgressSessions}, '
    'display=${debug.displayDecoder.toJson()}.',
  );
}

final class _ScrollableTarget {
  const _ScrollableTarget({required this.finder, required this.position});

  final Finder finder;
  final ScrollPosition position;
}
