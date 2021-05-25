import 'dart:isolate';

import 'package:connectivity/connectivity.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/internal/store.dart';
import 'package:mikan_flutter/mikan_flutter_route.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/providers/firebase_model.dart';
import 'package:mikan_flutter/providers/home_model.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/list_model.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

main() async {
  CustomWidgetsFlutterBinding.ensureInitialized();
  await _initDependencies();
  runApp(MikanApp());
}

class CustomWidgetsFlutterBinding extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    final ImageCache imageCache = super.createImageCache();
    imageCache.maximumSize = 128;
    imageCache.maximumSizeBytes = 512 * 1024 * 1024; // 512MB
    return imageCache;
  }

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) CustomWidgetsFlutterBinding();
    return WidgetsBinding.instance!;
  }
}

Future _initFirebase() async {
  await Firebase.initializeApp();

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
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);
}

Future _initDependencies() async {
  await Store.init();
  await MyHive.init();
  await _initFirebase();
}

class MikanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _subscribeConnectivityChange();
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
          ChangeNotifierProvider<FirebaseModel>(
            create: (_) => FirebaseModel(),
          ),
          ChangeNotifierProvider<SubscribedModel>(
            create: (_) => SubscribedModel(),
          ),
          ChangeNotifierProvider<IndexModel>(
            create: (context) => IndexModel(context.read<SubscribedModel>()),
          ),
          ChangeNotifierProvider<ListModel>(
            create: (_) => ListModel(),
          ),
          ChangeNotifierProvider<HomeModel>(
            create: (_) => HomeModel(),
          ),
        ],
        child: Consumer<ThemeModel>(
          builder: (context, themeModel, child) {
            final FirebaseModel firebaseModel = Provider.of<FirebaseModel>(
              context,
              listen: false,
            );
            return _buildMaterialApp(themeModel, firebaseModel);
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
      }
    });
  }

  Widget _buildMaterialApp(
    final ThemeModel themeModel,
    final FirebaseModel firebaseModel,
  ) {
    final ThemeData theme = themeModel.theme();
    return Theme(
      data: theme,
      child: OKToast(
        position: ToastPosition(align: Alignment.bottomCenter, offset: -72.0),
        duration: Duration(milliseconds: 3600),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: themeModel.theme(darkTheme: true),
          initialRoute: Routes.home,
          onGenerateRoute: (RouteSettings settings) {
            return onGenerateRoute(
              settings: settings,
              getRouteSettings: getRouteSettings,
            );
          },
          navigatorObservers: [
            firebaseModel.observer,
            FFNavigatorObserver(routeChange: (newRoute, oldRoute) {
              //you can track page here
              final RouteSettings? oldSettings = oldRoute?.settings;
              final RouteSettings? newSettings = newRoute?.settings;
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
