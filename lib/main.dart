import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:mikan_flutter/base/store.dart';
import 'package:mikan_flutter/ext/logger.dart';
import 'package:mikan_flutter/mikan_flutter_route_helper.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/providers/models/firebase_model.dart';
import 'package:mikan_flutter/providers/models/home_model.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/providers/models/list_model.dart';
import 'package:mikan_flutter/providers/models/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await Store.init();
  await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition.bottom,
      radius: 640,
      backgroundColor: Colors.white70.withAlpha(196),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeModel>(
            create: (context) => ThemeModel(),
          ),
          ChangeNotifierProvider<FirebaseModel>(
            create: (context) => FirebaseModel(),
          ),
          ListenableProvider<IndexModel>(
            create: (context) => IndexModel(),
            lazy: false,
          ),
          ChangeNotifierProvider<ListModel>(
            create: (context) => ListModel(),
            lazy: false,
          ),
          ChangeNotifierProvider<HomeModel>(
            create: (context) => HomeModel(),
            lazy: false,
          ),
        ],
        child: Consumer<ThemeModel>(
          builder: (context, themeModel, child) {
            final FirebaseModel firebaseModel =
                Provider.of<FirebaseModel>(context);
            return RefreshConfiguration(
              autoLoad: true,
              // 头部触发刷新的越界距离
              headerTriggerDistance: 80.0,
              headerBuilder: () => ClassicHeader(
                refreshStyle: RefreshStyle.Follow,
              ),
              // 自定义回弹动画,三个属性值意义请查询flutter api
              springDescription:
                  SpringDescription(stiffness: 170, damping: 16, mass: 1.9),
              //头部最大可以拖动的范围,如果发生冲出视图范围区域,请设置这个属性
              maxOverScrollExtent: 240,
              // 底部最大可以拖动的范围
              maxUnderScrollExtent: 240,
              //这个属性不兼容PageView和TabBarView,如果你特别需要TabBarView左右滑动,你需要把它设置为true
              enableScrollWhenRefreshCompleted: true,
              //在加载失败的状态下,用户仍然可以通过手势上拉来触发加载更多
              enableLoadingWhenFailed: true,
              // Viewport不满一屏时,禁用上拉加载更多功能
              hideFooterWhenNotFull: false,
              // 可以通过惯性滑动触发加载更多
              enableBallisticLoad: true,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: themeModel.themeData(),
                darkTheme: themeModel.themeData(platformDarkMode: true),
                initialRoute: Routes.mikanHome,
                onGenerateRoute: (RouteSettings settings) =>
                    onGenerateRouteHelper(settings),
                navigatorObservers: [
                  firebaseModel.observer,
                  FFNavigatorObserver(
                      routeChange: (Route newRoute, Route oldRoute) {
                    //you can track page here
                    final RouteSettings oldSettings = oldRoute?.settings;
                    final RouteSettings newSettings = newRoute?.settings;
                    logd(
                        "route change: ${oldSettings?.name} => ${newSettings?.name}");
                    if (newSettings is FFRouteSettings &&
                        oldSettings is FFRouteSettings) {
                      if (newSettings?.showStatusBar !=
                          oldSettings?.showStatusBar) {
                        if (newSettings?.showStatusBar == true) {
                          SystemChrome.setEnabledSystemUIOverlays(
                              SystemUiOverlay.values);
                          SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle.dark);
                        } else {
                          SystemChrome.setEnabledSystemUIOverlays([]);
                        }
                      }
                    }
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
