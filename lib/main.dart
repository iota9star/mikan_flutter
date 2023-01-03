import 'dart:io';
import 'dart:isolate';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/internal/http_cache_manager.dart';
import 'package:mikan_flutter/internal/log.dart';
import 'package:mikan_flutter/internal/network_font_loader.dart';
import 'package:mikan_flutter/internal/store.dart';
import 'package:mikan_flutter/mikan_flutter_route.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/providers/firebase_model.dart';
import 'package:mikan_flutter/providers/fonts_model.dart';
import 'package:mikan_flutter/providers/home_model.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/list_model.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initDependencies();
  runApp(const MikanApp());
  if (!isMobile) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(400, 640);
      appWindow.size = const Size(640, 720);
      appWindow.alignment = Alignment.center;
      appWindow.title = "蜜柑计划";
      appWindow.show();
    });
  }
}

Future _initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    // Handle Crashlytics enabled status when not in Debug,
    // e.g. allow your users to opt-in to crash reporting.
  }
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    await FirebaseCrashlytics.instance.recordError(pair.first, pair.last);
  }).sendPort);
}

Future _initDependencies() async {
  await Store.init();
  await Future.wait([
    MyHive.init(),
    NetworkFontLoader.init(),
    HttpCacheManager.init(),
    if (isSupportFirebase) _initFirebase()
  ]);
  if (Platform.isAndroid) {
    FlutterDisplayMode.setHighRefreshRate().catchError((e, s) {
      e.error(stackTrace: s);
    });
  }
}

class MikanApp extends StatelessWidget {
  const MikanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      _subscribeConnectivityChange();
    }
    return RefreshConfiguration(
      headerTriggerDistance: 80.0,
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed: true,
      hideFooterWhenNotFull: false,
      enableBallisticLoad: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeModel>(
            create: (_) => ThemeModel(),
          ),
          ChangeNotifierProvider<FontsModel>(
            create: (context) => FontsModel(context.read<ThemeModel>()),
            lazy: false,
          ),
          if (isSupportFirebase)
            ChangeNotifierProvider<FirebaseModel>(
              create: (_) => FirebaseModel(),
            ),
          ChangeNotifierProvider<SubscribedModel>(
            create: (_) => SubscribedModel(),
          ),
          ChangeNotifierProvider<OpModel>(
            create: (_) => OpModel(),
          ),
          ChangeNotifierProvider<IndexModel>(
            create: (context) => IndexModel(context.read<SubscribedModel>()),
            lazy: false,
          ),
          ChangeNotifierProvider<ListModel>(
            create: (_) => ListModel(),
          ),
          ChangeNotifierProvider<HomeModel>(
            create: (_) => HomeModel(),
          ),
        ],
        child: Consumer<ThemeModel>(
          builder: (context, themeModel, _) {
            return _buildMaterialApp(context, themeModel);
          },
        ),
      ),
    );
  }

  void _subscribeConnectivityChange() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.wifi:
          "您正在使用WiFi网络".toast();
          break;
        case ConnectivityResult.mobile:
          "您正在使用移动网络".toast();
          break;
        case ConnectivityResult.none:
          "您已断开网络".toast();
          break;
        case ConnectivityResult.ethernet:
          "您正在使用以太网".toast();
          break;
        case ConnectivityResult.bluetooth:
          "您正在使用蓝牙网络".toast();
          break;
        case ConnectivityResult.vpn:
          "您正在使用 VPN".toast();
          break;
      }
    });
  }

  Widget _buildMaterialApp(
    final BuildContext context,
    final ThemeModel themeModel,
  ) {
    final ThemeData theme = themeModel.theme(darkTheme: !isMobile);
    return Theme(
      data: theme,
      child: OKToast(
        position: const ToastPosition(
          align: Alignment.bottomCenter,
          offset: -72.0,
        ),
        child: MaterialApp(
          scrollBehavior: normalScrollBehavior,
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: themeModel.theme(darkTheme: true),
          initialRoute: Routes.splash.name,
          onGenerateRoute: (RouteSettings settings) {
            return onGenerateRoute(
              settings: settings,
              getRouteSettings: getRouteSettings,
            );
          },
          navigatorKey: navKey,
          navigatorObservers: [
            if (isSupportFirebase)
              Provider.of<FirebaseModel>(
                context,
                listen: false,
              ).observer,
            FFNavigatorObserver(routeChange: (newRoute, oldRoute) {
              //you can track page here
              final oldSettings = oldRoute?.settings;
              final newSettings = newRoute?.settings;
              "route change: "
                      "${oldSettings?.name} => ${newSettings?.name}"
                  .debug();
            }),
          ],
        ),
      ),
    );
  }
}
