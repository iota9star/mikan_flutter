import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/internal/ui.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/providers/models/login_model.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "/login",
  routeName: "mikan-login",
)
@immutable
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ListenableProxyProvider<IndexModel, LoginModel>(
        create: (_) => LoginModel(),
        update: (_, indexModel, loginModel) {
          loginModel.user = indexModel.user;
          return loginModel;
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: Sz.statusBarHeight + 36.0,
                bottom: 36.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/mikan.png",
                        width: 96.0,
                      ),
                      SizedBox(width: 24.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Welcome to Mikan",
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            "蜜柑计划",
                            style: TextStyle(
                              fontSize: 48.0,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 56.0,
                  ),
                  Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24.0),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                    ),
                    child: Builder(
                      builder: (context) {
                        return TextField(
                          controller:
                          Provider
                              .of<LoginModel>(context, listen: false)
                              .accountController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: '帐号',
                              prefixIcon: Icon(
                                  FluentIcons.inprivate_account_24_regular)),
                          keyboardType: TextInputType.text,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                    ),
                    child: Builder(
                      builder: (BuildContext context) {
                        return TextField(
                          obscureText: true,
                          controller:
                          Provider
                              .of<LoginModel>(context, listen: false)
                              .passwordController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: '密码',
                              prefixIcon:
                              Icon(FluentIcons.password_24_regular)),
                          keyboardType: TextInputType.visiblePassword,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: <Widget>[
                      Builder(builder: (context) {
                        return Selector<LoginModel, bool>(
                          selector: (_, model) => model.rememberMe,
                          builder: (_, checked, __) {
                            return Checkbox(
                              value: checked,
                              visualDensity: VisualDensity(),
                              onChanged: (val) {
                                context.read<LoginModel>().rememberMe = val;
                              },
                            );
                          },
                        );
                      }),
                      Expanded(child: Text("记住密码")),
                      FlatButton(
                        onPressed: () {},
                        child: Text("忘记密码"),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text("还没有账号？赶紧来注册一个吧~"),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Selector<LoginModel, bool>(
                        selector: (_, model) => model.loading,
                        shouldRebuild: (pre, next) => pre != next,
                        builder: (_, loading, __) {
                          return Selector<LoginModel, User>(
                            builder: (_, user, __) {
                              final bool isNotOk = user == null ||
                                  user?.token?.isNullOrBlank == true;
                              final Color iconColor =
                              (loading ? primaryColor : accentColor)
                                  .computeLuminance() <
                                  0.5
                                  ? Colors.white
                                  : Colors.black;
                              return Ink(
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(),
                                  gradient: LinearGradient(
                                    colors: [
                                      loading ? primaryColor : accentColor,
                                      (loading ? primaryColor : accentColor)
                                          .withOpacity(0.8),
                                    ],
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      color: Colors.black.withAlpha(24),
                                    )
                                  ],
                                ),
                                child: Builder(builder: (context) {
                                  return IconButton(
                                    iconSize: 36.0,
                                    color: iconColor,
                                    icon: isNotOk || loading
                                        ? SpinKitFoldingCube(
                                      color: iconColor,
                                      size: 16.0,
                                      duration: const Duration(
                                          milliseconds: 1600),
                                    )
                                        : Icon(
                                        FluentIcons.caret_right_24_regular),
                                    onPressed: () {
                                      if (isNotOk || loading) return;
                                      context.read<LoginModel>().submit(
                                            () {
                                          context
                                              .read<IndexModel>()
                                              .loadIndex();
                                          Navigator.popUntil(
                                            context,
                                                (route) =>
                                                route.settings.name ==
                                                Routes.home,
                                          );
                                        },
                                      );
                                    },
                                  );
                                }),
                              );
                            },
                            selector: (_, model) => model.user,
                          );
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 56.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
