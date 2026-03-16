import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Lifecycle {
  const Lifecycle._();

  static RouteObserver lifecycleRouteObserver = RouteObserver();
}

abstract class LifecycleState<T extends StatefulWidget> extends State<T> with RouteAware, WidgetsBindingObserver {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Lifecycle.lifecycleRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPause();
    }
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  @mustCallSuper
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Lifecycle.lifecycleRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  @mustCallSuper
  void didPush() {
    super.didPush();
    onResume();
  }

  @override
  @mustCallSuper
  void didPopNext() {
    super.didPopNext();
    onResume();
  }

  @override
  @mustCallSuper
  void didPop() {
    super.didPop();
    onPause();
  }

  @override
  @mustCallSuper
  void didPushNext() {
    super.didPushNext();
    onPause();
  }

  void onPause() {}

  void onResume() {}
}

abstract class LifecycleRouteState<T extends StatefulWidget> extends State<T> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Lifecycle.lifecycleRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  @mustCallSuper
  void dispose() {
    Lifecycle.lifecycleRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  @mustCallSuper
  void didPush() {
    super.didPush();
    onResume();
  }

  @override
  @mustCallSuper
  void didPopNext() {
    super.didPopNext();
    onResume();
  }

  @override
  @mustCallSuper
  void didPop() {
    super.didPop();
    onPause();
  }

  @override
  @mustCallSuper
  void didPushNext() {
    super.didPushNext();
    onPause();
  }

  void onPause() {}

  void onResume() {}
}

abstract class LifecycleAppState<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver {
  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPause();
    }
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  @mustCallSuper
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onPause() {}

  void onResume() {}
}

/// Mixin for Riverpod ConsumerState to observe app lifecycle state changes.
///
/// Must be used together with WidgetsBindingObserver mixin:
/// ```dart
/// class _MyPageState extends ConsumerState<MyPage>
///     with WidgetsBindingObserver, ConsumerLifecycleState {
///   @override
///   void initState() {
///     super.initState();
///     WidgetsBinding.instance.addObserver(this);
///   }
///
///   @override
///   void dispose() {
///     WidgetsBinding.instance.removeObserver(this);
///     super.dispose();
///   }
///
///   @override
///   void didChangeAppLifecycleState(AppLifecycleState state) {
///     super.didChangeAppLifecycleState(state);
///     // ConsumerLifecycleState handles onResume/onPause
///   }
///
///   @override
///   void onResume() {
///     // Custom resume logic
///   }
///
///   @override
///   void onPause() {
///     // Custom pause logic
///   }
/// }
/// ```
mixin ConsumerLifecycleState<T extends ConsumerStatefulWidget> on ConsumerState<T>, WidgetsBindingObserver {
  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPause();
    }
  }

  /// Called when the app is resumed or the widget becomes visible.
  void onResume() {}

  /// Called when the app is paused or the widget becomes hidden.
  void onPause() {}
}

Future<void> exitApp() async {
  await SystemNavigator.pop(animated: true);
  exit(0);
}
