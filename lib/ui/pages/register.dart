import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../mikan_routes.dart';
import '../../providers/index_model.dart';
import '../../providers/register_model.dart';
import '../../providers/subscribed_model.dart';
import '../../topvars.dart';

@FFRoute(name: '/register')
@immutable
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<RegisterModel>(
        create: (_) => RegisterModel(),
        child: Builder(
          builder: (context) {
            final registerModel =
                Provider.of<RegisterModel>(context, listen: false);
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
                            sizedBoxH16,
                            _buildUserNameField(theme, registerModel),
                            sizedBoxH16,
                            _buildPasswordField(theme, registerModel),
                            sizedBoxH16,
                            _buildConfirmPasswordField(theme, registerModel),
                            sizedBoxH16,
                            _buildEmailField(theme, registerModel),
                            sizedBoxH16,
                            _buildQQField(theme, registerModel),
                            sizedBoxH56,
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(Icons.west_rounded),
                                ),
                                sizedBoxW16,
                                Expanded(child: _buildRegisterButton(theme))
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

  Widget _buildRegisterButton(ThemeData theme) {
    return Selector<RegisterModel, bool>(
      selector: (_, model) => model.loading,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, loading, __) {
        return ElevatedButton(
          onPressed: () {
            if (loading) {
              return;
            }
            if (_formKey.currentState!.validate()) {
              context.read<RegisterModel>().submit(() {
                context.read<IndexModel>().refresh();
                context.read<SubscribedModel>().refresh();
                Navigator.popUntil(
                  context,
                  (route) => route.settings.name == Routes.index.name,
                );
              });
            }
          },
          child: Text(loading ? '注册中' : '注册'),
        );
      },
    );
  }

  Widget _buildUserNameField(
    ThemeData theme,
    RegisterModel registerModel,
  ) {
    return TextFormField(
      controller: registerModel.userNameController,
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

  Widget _buildEmailField(
    ThemeData theme,
    RegisterModel registerModel,
  ) {
    return TextFormField(
      controller: registerModel.emailController,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        labelText: '邮箱',
        hintText: '请输入邮箱',
        prefixIcon: Icon(Icons.email_rounded),
      ),
      validator: (value) {
        if (value.isNullOrBlank) {
          return '邮箱不能为空';
        }
        if (!RegExp(r'.+@.+\..+').hasMatch(value!)) {
          return '邮箱格式不正确';
        }
        return null;
      },
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
    );
  }

  Widget _buildQQField(
    ThemeData theme,
    RegisterModel registerModel,
  ) {
    return TextFormField(
      controller: registerModel.qqController,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        labelText: 'QQ',
        hintText: '请输入QQ号码',
        prefixIcon: Icon(Icons.mood_rounded),
      ),
      validator: (value) {
        if (value.isNotBlank) {
          if (!RegExp(r'\d+').hasMatch(value!)) {
            return 'QQ号码应为数字';
          }
          if (value.length < 5) {
            return 'QQ号码最少为5位';
          }
        }
        return null;
      },
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPasswordField(
    ThemeData theme,
    RegisterModel registerModel,
  ) {
    return Selector<RegisterModel, bool>(
      selector: (_, model) => model.showPassword,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, showPassword, __) {
        return TextFormField(
          obscureText: !showPassword,
          controller: registerModel.passwordController,
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
                registerModel.showPassword = !showPassword;
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
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.password],
        );
      },
    );
  }

  Widget _buildConfirmPasswordField(
    ThemeData theme,
    RegisterModel registerModel,
  ) {
    return Selector<RegisterModel, bool>(
      selector: (_, model) => model.showPassword,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, showPassword, __) {
        return TextFormField(
          obscureText: !showPassword,
          controller: registerModel.confirmPasswordController,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            labelText: '确认密码',
            hintText: '请输入确认密码',
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(
              icon: showPassword
                  ? const Icon(Icons.visibility_rounded)
                  : const Icon(Icons.visibility_off_rounded),
              onPressed: () {
                registerModel.showPassword = !showPassword;
              },
            ),
          ),
          validator: (value) {
            if (value.isNullOrBlank) {
              return '确认密码不能为空';
            }
            if (value != registerModel.passwordController.text) {
              return '确认密码与密码不一致，请重新输入';
            }
            return null;
          },
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.password],
        );
      },
    );
  }
}
