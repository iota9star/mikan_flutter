import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:pixa/pixa.dart';
import 'package:window_manager/window_manager.dart';

import 'package:mikan/app/mikan_app.dart';
import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/common/app_utils.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/http_cache_manager.dart';
import 'package:mikan/core/common/network_font_loader.dart';
import 'package:mikan/core/widgets/restart.dart';
import 'package:mikan/firebase_options.dart';

Future<void> initWindow() async {
  if (isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(minimumSize: Size(480, 320), title: 'MikanProject');
    unawaited(
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      }),
    );
  }
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  // Record all framework errors (including non-fatal), not just fatal ones.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // Catch async errors that escape FlutterError (zone-uncaught). These are
  // generally non-fatal (most are unhandled async exceptions), so report them
  // as non-fatal to keep crash-free metrics accurate.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };
}

Future<void> initMisc() async {
  await Future.wait([
    MyHive.init(),
    NetworkFontLoader.init(),
    HttpCacheManager.init(),
    MikanApi.init(),
    // Pixa image pipeline (Rust-backed Native Assets runtime). Independent of
    // the other subsystems and safe to initialize in parallel.
    Pixa.configure(),
    if (isSupportFirebase) initFirebase(),
  ]);
  // Initialize the Kache persistence + network layer.
  // Hive adapters are already registered by MyHive.init() (generated registrar).
  await KacheInit.init();
  if (isMobile) {
    unawaited(
      FlutterDisplayMode.setHighRefreshRate().catchError((e, s) {
        e.error(stackTrace: s);
      }),
    );
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initMisc();
  await initWindow();
  runApp(const Restart(child: MikanApp()));
}
