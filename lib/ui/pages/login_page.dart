import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/login_model.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:mikan_flutter/topvars.dart';
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
          final loginModel = Provider.of<LoginModel>(context, listen: false);
          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400.0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: edgeH24V36WithStatusBar,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          normalFormHeader,
                          sizedBoxH42,
                          _buildUserNameField(theme, loginModel),
                          sizedBoxH16,
                          _buildPasswordField(theme, loginModel),
                          sizedBoxH16,
                          _buildRememberRow(theme, loginModel),
                          sizedBoxH16,
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.register);
                            },
                            child: Text("还没有账号？赶紧来注册一个吧~"),
                          ),
                          sizedBoxH16,
                          Row(
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  FluentIcons.chevron_left_24_regular,
                                  size: 16.0,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                minWidth: 0.0,
                                padding: edge16,
                                shape: circleShape,
                                color: theme.backgroundColor,
                              ),
                              sizedBoxW12,
                              Expanded(child: _buildLoginButton(theme)),
                            ],
                          ),
                          sizedBoxH56,
                        ],
                      ),
                    ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SpinKitWave(
                  size: 20.0,
                  type: SpinKitWaveType.center,
                  color: iconColor,
                ),
              sizedBoxW12,
              Text(
                loading ? "登录中..." : "登录",
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sizedBoxW12,
              if (loading)
                SpinKitWave(
                  size: 20.0,
                  type: SpinKitWaveType.center,
                  color: iconColor,
                ),
            ],
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
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: theme.accentColor,
              onChanged: (val) {
                loginModel.rememberMe = val ?? false;
              },
            );
          },
        ),
        Expanded(child: Text("记住密码")),
        TextButton(
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
    return TextFormField(
      controller: loginModel.accountController,
      cursorColor: theme.accentColor,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: '用户名',
        hintText: '请输入用户名',
        hintStyle: TextStyle(fontSize: 14.0),
        prefixIcon: Icon(
          FluentIcons.person_24_regular,
          color: theme.accentColor,
        ),
      ),
      validator: (value) {
        return value.isNullOrBlank ? "用户名不能为空" : null;
      },
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildPasswordField(
    final ThemeData theme,
    final LoginModel loginModel,
  ) {
    return Selector<LoginModel, bool>(
      selector: (_, model) => model.showPassword,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, showPassword, __) {
        return TextFormField(
          obscureText: !showPassword,
          cursorColor: theme.accentColor,
          controller: loginModel.passwordController,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: '密码',
            hintText: '请输入密码',
            hintStyle: TextStyle(fontSize: 14.0, letterSpacing: 0.0),
            prefixIcon: Icon(
              FluentIcons.password_24_regular,
              color: theme.accentColor,
            ),
            suffixIcon: IconButton(
              icon: showPassword
                  ? Icon(
                      FluentIcons.eye_show_24_regular,
                      color: theme.accentColor,
                    )
                  : Icon(
                      FluentIcons.eye_show_24_filled,
                      color: theme.accentColor,
                    ),
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
    );
  }
}
