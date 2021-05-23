import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/providers/view_models/index_model.dart';
import 'package:mikan_flutter/providers/view_models/login_model.dart';
import 'package:mikan_flutter/providers/view_models/subscribed_model.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "login",
  routeName: "login",
)
@immutable
class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<LoginModel>(
        create: (_) => LoginModel(),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildHeader(),
                      SizedBox(height: 42.0),
                      _buildUserNameField(theme, loginModel),
                      SizedBox(height: 16.0),
                      _buildPasswordField(theme, loginModel),
                      SizedBox(height: 16.0),
                      _buildRememberRow(theme, loginModel),
                      SizedBox(height: 16.0),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.register);
                        },
                        child: Text("还没有账号？赶紧来注册一个吧~"),
                      ),
                      SizedBox(height: 16.0),
                      _buildLoginButton(theme),
                      SizedBox(
                        height: 56.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoginButton(final ThemeData theme) {
    return Selector<LoginModel, bool>(
      selector: (_, model) => model.loading,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, loading, __) {
        final Color btnColor = loading ? theme.primaryColor : theme.accentColor;
        final Color iconColor =
            btnColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
        return ElevatedButton(
          onPressed: () {
            if (loading) return;
            if (_formKey.currentState!.validate()) {
              context.read<LoginModel>().submit(() {
                context.read<IndexModel>().refresh();
                context.read<SubscribedModel>().refresh();
                Navigator.popUntil(
                  context,
                  (route) => route.settings.name == Routes.home,
                );
              });
            }
          },
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(24.0),
          // ),
          // color: theme.backgroundColor,
          // padding: EdgeInsets.zero,
          child: Container(
            height: 48.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
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
                  loading ? "登录中" : "登录",
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
    final ThemeData theme,
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
              activeColor: theme.accentColor,
              onChanged: (val) {
                loginModel.rememberMe = val ?? false;
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

  Widget _buildUserNameField(
    final ThemeData theme,
    final LoginModel loginModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextFormField(
        controller: loginModel.accountController,
        cursorColor: theme.accentColor,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          labelText: '用户名',
          hintText: '请输入用户名',
          hintStyle: TextStyle(fontSize: 14.0),
          prefixIcon: Icon(
            FluentIcons.person_24_regular,
          ),
        ),
        validator: (value) {
          return value.isNullOrBlank ? "用户名不能为空" : null;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildPasswordField(
    final ThemeData theme,
    final LoginModel loginModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Selector<LoginModel, bool>(
        selector: (_, model) => model.showPassword,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, showPassword, __) {
          return TextFormField(
            obscureText: !showPassword,
            obscuringCharacter: "*",
            style: TextStyle(letterSpacing: 6.0),
            cursorColor: theme.accentColor,
            controller: loginModel.passwordController,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              labelText: '密码',
              hintText: '请输入密码',
              hintStyle: TextStyle(fontSize: 14.0, letterSpacing: 0.0),
              prefixIcon: Icon(FluentIcons.password_24_regular),
              suffixIcon: IconButton(
                icon: showPassword
                    ? Icon(FluentIcons.eye_show_24_regular)
                    : Icon(FluentIcons.eye_show_24_filled),
                onPressed: () {
                  loginModel.showPassword = !showPassword;
                },
              ),
            ),
            validator: (value) {
              if (value.isNullOrBlank) return "密码不能为空";
              if (value!.length < 6) return "密码最少6位";
              return null;
            },
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.visiblePassword,
          );
        },
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
              "Mikan Project",
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
