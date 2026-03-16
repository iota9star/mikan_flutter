import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:mikan/app/routing/mikan_route.dart';
import 'package:mikan/app/routing/mikan_routes.dart';
import 'package:mikan/core/common/app_utils.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/lifecycle.dart';
import 'package:mikan/core/common/log.dart';
import 'package:mikan/core/common/scroll_behavior.dart';
import 'package:mikan/core/widgets/loading.dart';
import 'package:mikan/core/widgets/theme_provider.dart';
import 'package:mikan/core/widgets/toast.dart';
import 'package:mikan/core/common/app_layout.dart';

FirebaseAnalyticsObserver? _analyticsObserver;

FirebaseAnalyticsObserver? _getAnalyticsObserver() {
  if (!isSupportFirebase) {
    return null;
  }
  return _analyticsObserver ??= FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
}

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
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    final connectivity = Connectivity();
    _subscription = connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    if (_firstEvent) {
      _firstEvent = false;
      return;
    }

    final message = _getConnectivityMessage(result);
    if (message != null) {
      message.toast();
    }
  }

  String? _getConnectivityMessage(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.mobile)) {
      return '正在使用 移动网络';
    } else if (result.contains(ConnectivityResult.wifi)) {
      return '正在使用 WiFi网络';
    } else if (result.contains(ConnectivityResult.ethernet)) {
      return '正在使用 以太网';
    } else if (result.contains(ConnectivityResult.vpn)) {
      return '正在使用 VPN';
    } else if (result.contains(ConnectivityResult.bluetooth)) {
      return '正在使用 蓝牙网络';
    } else if (result.contains(ConnectivityResult.other)) {
      return '正在使用 未知网络';
    } else if (result.contains(ConnectivityResult.none)) {
      return '网络已断开';
    }
    return null;
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
          if (_getAnalyticsObserver() case final observer?) observer,
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
