import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/providers/models/login_model.dart';
import 'package:mikan_flutter/providers/models/subscribed_model.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

@FFRoute(
  name: "login",
  routeName: "login",
)
@immutable
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProxyProvider<IndexModel, LoginModel>(
        create: (_) => LoginModel(),
        update: (_, indexModel, loginModel) {
          loginModel.user = indexModel.user;
          return loginModel;
        },
        child: Builder(builder: (context) {
          final LoginModel loginModel =
              Provider.of<LoginModel>(context, listen: false);
          return Scaffold(
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
                    _buildHeader(),
                    SizedBox(
                      height: 42.0,
                    ),
                    _buildAccountField(loginModel),
                    SizedBox(
                      height: 16.0,
                    ),
                    _buildPasswordField(loginModel),
                    SizedBox(
                      height: 16.0,
                    ),
                    _buildRememberRow(accentColor, loginModel),
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
                    _buildLoginButton(
                      context,
                      primaryColor,
                      accentColor,
                      scaffoldBackgroundColor,
                    ),
                    SizedBox(
                      height: 56.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoginButton(
    final BuildContext context,
    final Color primaryColor,
    final Color accentColor,
    final Color scaffoldBackgroundColor,
  ) {
    return Selector<LoginModel, Tuple2<User, bool>>(
      selector: (_, model) => Tuple2(model.user, model.loading),
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, tuple, __) {
        final User user = tuple.item1;
        final bool loading = tuple.item2;
        final bool isNotOk = user == null || user?.token?.isNullOrBlank == true;
        final Color btnColor = loading ? primaryColor : accentColor;
        final Color iconColor =
            btnColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
        return RaisedButton(
          onPressed: () {
            if (isNotOk || loading) return;
            context.read<LoginModel>().submit(() {
              context.read<IndexModel>().refresh();
              context.read<SubscribedModel>().refresh();
              Navigator.popUntil(
                context,
                (route) => route.settings.name == Routes.home,
              );
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          color: scaffoldBackgroundColor.withOpacity(0),
          padding: EdgeInsets.zero,
          child: Container(
            height: 48.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
              gradient: LinearGradient(
                colors: [
                  btnColor,
                  btnColor.withOpacity(0.64),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SpinKitWave(
                    size: 20.0,
                    type: SpinKitWaveType.center,
                    color: iconColor,
                  ),
                SizedBox(width: 12.0),
                Text(
                  loading ? "登录中..." : "登录",
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12.0),
                if (loading)
                  SpinKitWave(
                    size: 20.0,
                    type: SpinKitWaveType.center,
                    color: iconColor,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRememberRow(
    final Color accentColor,
    final LoginModel loginModel,
  ) {
    return Row(
      children: <Widget>[
        Selector<LoginModel, bool>(
          selector: (_, model) => model.rememberMe,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, checked, __) {
            return Checkbox(
              value: checked,
              visualDensity: VisualDensity(),
              activeColor: accentColor,
              onChanged: (val) {
                loginModel.rememberMe = val;
              },
            );
          },
        ),
        Expanded(child: Text("记住密码")),
        FlatButton(
          onPressed: () {},
          child: Text("忘记密码"),
        )
      ],
    );
  }

  Widget _buildAccountField(final LoginModel loginModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: TextField(
        controller: loginModel.accountController,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          labelText: '帐号',
          prefixIcon: Icon(
            FluentIcons.inprivate_account_24_regular,
          ),
        ),
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildPasswordField(final LoginModel loginModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: TextField(
        obscureText: true,
        controller: loginModel.passwordController,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          labelText: '密码',
          prefixIcon: Icon(FluentIcons.password_24_regular),
        ),
        keyboardType: TextInputType.visiblePassword,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ExtendedImage.asset(
          "assets/mikan.png",
          width: 72.0,
        ),
        SizedBox(width: 24.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Welcome to Mikan",
              style: TextStyle(fontSize: 14.0),
            ),
            Text(
              "蜜柑计划",
              style: TextStyle(
                fontSize: 32.0,
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }
}
