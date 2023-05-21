import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'internal/extension.dart';
import 'internal/hive.dart';
import 'internal/http_cache_manager.dart';
import 'internal/kit.dart';
import 'internal/lifecycle.dart';
import 'internal/log.dart';
import 'internal/network_font_loader.dart';
import 'mikan_route.dart';
import 'mikan_routes.dart';
import 'providers/fonts_model.dart';
import 'providers/home_model.dart';
import 'providers/index_model.dart';
import 'providers/list_model.dart';
import 'providers/op_model.dart';
import 'providers/subscribed_model.dart';
import 'topvars.dart';
import 'widget/restart.dart';

final _analytics = FirebaseAnalytics.instance;
final _observer = FirebaseAnalyticsObserver(analytics: _analytics);

final isMobile = Platform.isIOS || Platform.isAndroid;
final isSupportFirebase = isMobile || Platform.isMacOS;
final isDesktop = Platform.isMacOS || Platform.isLinux || Platform.isWindows;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initMisc();
  await _initWindow();
  runApp(Restart(child: const MikanApp()));
}

Future<void> _initWindow() async {
  if (isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      minimumSize: Size(480, 320),
      title: 'MikanProject',
    );
    unawaited(
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      }),
    );
  }
}

Future _initFirebase() async {
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}

Future<void> _initMisc() async {
  await Future.wait([
    MyHive.init(),
    NetworkFontLoader.init(),
    HttpCacheManager.init(),
    if (isSupportFirebase) _initFirebase(),
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
  ]);
  if (Platform.isAndroid) {
    unawaited(
      FlutterDisplayMode.setHighRefreshRate().catchError((e, s) {
        e.error(stackTrace: s);
      }),
    );
  }
}

class MikanApp extends StatefulWidget {
  const MikanApp({super.key});

  @override
  State<MikanApp> createState() => _MikanAppState();
}

class _MikanAppState extends State<MikanApp> {
  StreamSubscription<ConnectivityResult>? _subscription;

  void _subscribeConnectivityChange() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      switch (result) {
        case ConnectivityResult.wifi:
          '您正在使用 WiFi网络'.toast();
        case ConnectivityResult.mobile:
          '您正在使用 移动网络'.toast();
        case ConnectivityResult.none:
          '您已断开 网络'.toast();
        case ConnectivityResult.ethernet:
          '您正在使用 以太网'.toast();
        case ConnectivityResult.bluetooth:
          '您正在使用 蓝牙网络'.toast();
        case ConnectivityResult.vpn:
          '您正在使用 VPN'.toast();
        case ConnectivityResult.other:
          '您正在使用 未知网络'.toast();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _subscribeConnectivityChange();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FontsModel>(
          create: (context) => FontsModel(),
          lazy: false,
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
      child: _buildMaterialApp(context),
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: MyHive.settings.listenable(),
      builder: (context, _, child) {
        final fontFamily = MyHive.getFontFamily()?.value;
        final colorSeed = Color(MyHive.getColorSeed());
        final themeMode = MyHive.getThemeMode();
        final navigatorObservers = [
          Lifecycle.lifecycleRouteObserver,
          if (isSupportFirebase) _observer,
          FFNavigatorObserver(
            routeChange: (newRoute, oldRoute) {
              //you can track page here
              final oldSettings = oldRoute?.settings;
              final newSettings = newRoute?.settings;
              'route change: '
                      '${oldSettings?.name} => ${newSettings?.name}'
                  .$debug();
            },
          ),
        ];
        return MaterialApp(
          scrollBehavior: const ScrollBehavior().copyWith(
            dragDevices: PointerDeviceKind.values.toSet(),
            overscroll: true,
            platform: TargetPlatform.iOS,
            physics: const BouncingScrollPhysics(),
            scrollbars: false,
          ),
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: fontFamily,
            colorSchemeSeed: colorSeed,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: fontFamily,
            colorSchemeSeed: colorSeed,
          ),
          initialRoute: Routes.splash.name,
          builder: (context, child) {
            return OKToast(
              position: ToastPosition(
                align: Alignment.bottomCenter,
                offset: -context.screenHeight * 0.18,
              ),
              child: child!,
            );
          },
          onGenerateRoute: (RouteSettings settings) {
            return onGenerateRoute(
              settings: settings,
              getRouteSettings: getRouteSettings,
            );
          },
          navigatorKey: navKey,
          navigatorObservers: navigatorObservers,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
