import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../providers/forgot_password_model.dart';
import '../../res/assets.gen.dart';
import '../../topvars.dart';
import '../../widget/bottom_sheet.dart';
import '../fragments/forgot_password_confirm.dart';

@FFRoute(name: '/forget-password')
@immutable
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<ForgotPasswordModel>(
        create: (_) => ForgotPasswordModel(),
        child: Builder(
          builder: (context) {
            final forgotModel =
                Provider.of<ForgotPasswordModel>(context, listen: false);
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
                              Assets.mikan.path,
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
                            _buildEmailField(theme, forgotModel),
                            sizedBoxH42,
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(Icons.west_rounded),
                                ),
                                sizedBoxW16,
                                Expanded(child: _buildSubmitButton(theme)),
                              ],
                            ),
                            sizedBoxH42,
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

  Widget _buildSubmitButton(ThemeData theme) {
    return Selector<ForgotPasswordModel, bool>(
      selector: (_, model) => model.loading,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, loading, __) {
        return ElevatedButton(
          onPressed: () {
            if (loading) {
              return;
            }
            if (_formKey.currentState!.validate()) {
              context.read<ForgotPasswordModel>().submit(() {
                _showForgotPasswordConfirmationPanel(context);
              });
            }
          },
          child: Text(loading ? '提交中...' : '提交'),
        );
      },
    );
  }

  Widget _buildEmailField(
    ThemeData theme,
    ForgotPasswordModel model,
  ) {
    return TextFormField(
      controller: model.emailController,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        labelText: '您的邮箱',
        hintText: '请输入邮箱地址',
        prefixIcon: Icon(Icons.email_rounded),
      ),
      validator: (value) {
        if (value.isNullOrBlank) {
          return '请填写邮箱地址';
        }
        return value.isNullOrBlank ? '用户名不能为空' : null;
      },
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
    );
  }

  void _showForgotPasswordConfirmationPanel(BuildContext context) {
    MBottomSheet.show(
      context,
      (context) => const MBottomSheet(child: ForgotPasswordConfirm()),
    );
  }
}
