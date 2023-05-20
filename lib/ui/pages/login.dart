import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../mikan_routes.dart';
import '../../providers/index_model.dart';
import '../../providers/login_model.dart';
import '../../providers/subscribed_model.dart';
import '../../topvars.dart';

@FFRoute(name: '/login')
@immutable
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<LoginModel>(
        create: (_) => LoginModel(),
        child: Builder(
          builder: (context) {
            final loginModel = Provider.of<LoginModel>(context, listen: false);
            return Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400.0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: edgeH24V36WithStatusBar(context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/mikan.png',
                              width: 64.0,
                            ),
                            sizedBoxH8,
                            Text(
                              'Mikan Project',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '蜜柑计划',
                              style: theme.textTheme.titleLarge,
                            ),
                            sizedBoxH42,
                            _buildUserNameField(theme, loginModel),
                            sizedBoxH16,
                            _buildPasswordField(theme, loginModel),
                            sizedBoxH16,
                            _buildRememberRow(context, theme, loginModel),
                            sizedBoxH16,
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.register.name,
                                );
                              },
                              child: const Text('还没有账号？赶紧来注册一个吧~'),
                            ),
                            sizedBoxH16,
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(Icons.west_rounded),
                                ),
                                sizedBoxW16,
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
          },
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return Selector<LoginModel, bool>(
      selector: (_, model) => model.loading,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, loading, __) {
        return ElevatedButton(
          onPressed: () {
            if (loading) {
              return;
            }
            if (_formKey.currentState!.validate()) {
              context.read<LoginModel>().submit(() {
                context.read<IndexModel>().refresh();
                context.read<SubscribedModel>().refresh();
                Navigator.popUntil(
                  context,
                  (route) => route.settings.name == Routes.index.name,
                );
              });
            }
          },
          child: Text(loading ? '登录中...' : '登录'),
        );
      },
    );
  }

  Widget _buildRememberRow(
    BuildContext context,
    ThemeData theme,
    LoginModel loginModel,
  ) {
    return Row(
      children: <Widget>[
        Selector<LoginModel, bool>(
          selector: (_, model) => model.rememberMe,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, checked, __) {
            return Checkbox(
              value: checked,
              onChanged: (val) {
                loginModel.rememberMe = val ?? false;
              },
            );
          },
        ),
        const Expanded(child: Text('记住密码')),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.forgetPassword.name);
          },
          child: const Text('忘记密码'),
        )
      ],
    );
  }

  Widget _buildUserNameField(
    ThemeData theme,
    LoginModel loginModel,
  ) {
    return TextFormField(
      controller: loginModel.accountController,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        labelText: '用户名',
        hintText: '请输入用户名',
        prefixIcon: Icon(Icons.perm_identity_rounded),
      ),
      validator: (value) {
        return value.isNullOrBlank ? '用户名不能为空' : null;
      },
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      autofillHints: const [
        AutofillHints.name,
        AutofillHints.namePrefix,
        AutofillHints.nameSuffix,
        AutofillHints.newUsername,
        AutofillHints.username,
        AutofillHints.nickname,
        AutofillHints.email,
        AutofillHints.telephoneNumber,
      ],
    );
  }

  Widget _buildPasswordField(
    ThemeData theme,
    LoginModel loginModel,
  ) {
    return Selector<LoginModel, bool>(
      selector: (_, model) => model.showPassword,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, showPassword, __) {
        return TextFormField(
          obscureText: !showPassword,
          controller: loginModel.passwordController,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            labelText: '密码',
            hintText: '请输入密码',
            prefixIcon: const Icon(Icons.password_rounded),
            suffixIcon: IconButton(
              icon: showPassword
                  ? const Icon(Icons.visibility_rounded)
                  : const Icon(Icons.visibility_off_rounded),
              onPressed: () {
                loginModel.showPassword = !showPassword;
              },
            ),
          ),
          validator: (value) {
            if (value.isNullOrBlank) {
              return '密码不能为空';
            }
            if (value!.length < 6) {
              return '密码最少6位';
            }
            return null;
          },
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.password],
        );
      },
    );
  }
}
