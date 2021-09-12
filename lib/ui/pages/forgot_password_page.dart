import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/providers/forgot_password_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "forget-password",
  routeName: "/forget-password",
)
@immutable
class ForgotPasswordPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<ForgotPasswordModel>(
        create: (_) => ForgotPasswordModel(),
        child: Builder(builder: (context) {
          final forgotModel =
              Provider.of<ForgotPasswordModel>(context, listen: false);
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
                          _buildEmailField(theme, forgotModel),
                          sizedBoxH56,
                          Row(
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(
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
                              sizedBoxW16,
                              Expanded(child: _buildSubmitButton(theme)),
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

  Widget _buildSubmitButton(final ThemeData theme) {
    return Selector<ForgotPasswordModel, bool>(
      selector: (_, model) => model.loading,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, loading, __) {
        final Color btnColor = loading ? theme.primary : theme.secondary;
        final Color iconColor = btnColor.isDark ? Colors.white : Colors.black;
        return ElevatedButton(
          onPressed: () {
            if (loading) return;
            if (_formKey.currentState!.validate()) {
              context.read<ForgotPasswordModel>().submit(() {
                _showForgotPasswordConfirmationPanel(context, theme);
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
                loading ? "提交中..." : "提交",
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

  Widget _buildEmailField(
    final ThemeData theme,
    final ForgotPasswordModel model,
  ) {
    return TextFormField(
      controller: model.emailController,
      cursorColor: theme.secondary,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: '您的邮箱',
        hintText: '请输入邮箱地址',
        hintStyle: const TextStyle(fontSize: 14.0),
        prefixIcon: Icon(
          FluentIcons.mail_24_regular,
          color: theme.secondary,
        ),
      ),
      validator: (value) {
        if (value.isNullOrBlank) {
          return "请填写邮箱地址";
        }
        return value.isNullOrBlank ? "用户名不能为空" : null;
      },
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
    );
  }

  _showForgotPasswordConfirmationPanel(
    final BuildContext context,
    final ThemeData theme,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: radius16,
      backgroundColor: theme.backgroundColor,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: edge24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.backgroundColor.withOpacity(0.72),
                  theme.backgroundColor.withOpacity(0.9),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "忘记密码",
                  textAlign: TextAlign.justify,
                  style: textStyle18B,
                ),
                sizedBoxH16,
                Text("如果您填入的邮箱已在本网站注册，则您会在几分钟内收到重置密码邮件，如果长时间等待后仍收不到邮件请确认"),
                sizedBoxH12,
                Text("1）您是否已经注册"),
                sizedBoxH4,
                Text("2）邮件是否输入正确"),
              ],
            ),
          ),
        );
      },
    );
  }
}
