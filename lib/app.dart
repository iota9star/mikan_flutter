import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'mikan_route.dart';
import 'mikan_routes.dart';
import 'shared/internal/app_utils.dart';
import 'shared/internal/extension.dart';
import 'shared/internal/lifecycle.dart';
import 'shared/internal/log.dart';
import 'shared/internal/scroll_behavior.dart';
import 'shared/widgets/loading.dart';
import 'shared/widgets/theme_provider.dart';
import 'shared/widgets/toast.dart';
import 'topvars.dart';

final _analytics = FirebaseAnalytics.instance;
final _observer = FirebaseAnalyticsObserver(analytics: _analytics);

class MikanApp extends StatefulWidget {
  const MikanApp({super.key});

  @override
  State<MikanApp> createState() => _MikanAppState();
}

class _MikanAppState extends State<MikanApp> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _firstEvent = true;

  @override
  void initState() {
    super.initState();
    final connectivity = Connectivity();
    _subscription = connectivity.onConnectivityChanged.listen((result) {
      if (_firstEvent) {
        _firstEvent = false;
        return;
      }

      if (result.contains(ConnectivityResult.mobile)) {
        '正在使用 移动网络'.toast();
      } else if (result.contains(ConnectivityResult.wifi)) {
        '正在使用 WiFi网络'.toast();
      } else if (result.contains(ConnectivityResult.ethernet)) {
        '正在使用 以太网'.toast();
      } else if (result.contains(ConnectivityResult.vpn)) {
        '正在使用 VPN'.toast();
      } else if (result.contains(ConnectivityResult.bluetooth)) {
        '正在使用 蓝牙网络'.toast();
      } else if (result.contains(ConnectivityResult.other)) {
        '正在使用 未知网络'.toast();
      } else if (result.contains(ConnectivityResult.none)) {
        '网络已断开'.toast();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(observers: kDebugMode ? [RiverpodLogger()] : [], child: _MaterialAppWrapper());
  }
}

class _MaterialAppWrapper extends StatelessWidget {
  const _MaterialAppWrapper();

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      builder: (mode, lightColorScheme, darkColorScheme, fontFamily) {
        final navigatorObservers = [
          Lifecycle.lifecycleRouteObserver,
          FlutterSmartDialog.observer,
          if (isSupportFirebase) _observer,
          FFNavigatorObserver(
            routeChange: (newRoute, oldRoute) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              final oldSettings = oldRoute?.settings;
              final newSettings = newRoute?.settings;
              'route change: '
                      '${oldSettings?.name} => ${newSettings?.name}'
                  .$debug();
            },
          ),
        ];
        return MaterialApp(
          scrollBehavior: const AlwaysStretchScrollBehavior(),
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: fontFamily,
            colorScheme: lightColorScheme,
            visualDensity: VisualDensity.standard,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: fontFamily,
            colorScheme: darkColorScheme,
            visualDensity: VisualDensity.standard,
          ),
          initialRoute: Routes.splash.name,
          builder: FlutterSmartDialog.init(
            toastBuilder: (msg) => ToastWidget(msg: msg),
            loadingBuilder: (msg) => LoadingWidget(msg: msg),
            builder: (context, child) => AnnotatedRegion(
              value: context.fitSystemUiOverlayStyle,
              child: GestureDetector(onTap: hideKeyboard, child: child),
            ),
          ),
          onGenerateRoute: (RouteSettings settings) {
            return onGenerateRoute(settings: settings, getRouteSettings: getRouteSettings);
          },
          navigatorKey: navKey,
          navigatorObservers: navigatorObservers,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'CN')],
        );
      },
    );
  }
}
