import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_cockpit/flutter_cockpit_flutter.dart';

import 'package:mikan/app/mikan_app.dart';
import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/common/app_utils.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/http_cache_manager.dart';
import 'package:mikan/core/common/network_font_loader.dart';
import 'package:mikan/core/widgets/restart.dart';
import 'package:mikan/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mirror bootstrap.dart initMisc without window_manager (desktop-only).
  await Future.wait([
    MyHive.init(),
    NetworkFontLoader.init(),
    HttpCacheManager.init(),
    MikanApi.init(),
    if (isSupportFirebase) _initFirebase(),
  ]);
  await KacheInit.init();

  final remoteSession = CockpitRemoteSessionConfiguration.resolveFromEnvironment();
  final config = FlutterCockpitConfig.production(remoteSession: remoteSession);

  FlutterCockpit.runApp(const Restart(child: MikanApp()), config: config);
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
