import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import '../../../../../mikan_routes.dart';
import '../../../../../res/assets.gen.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../topvars.dart';
import '../../home/providers/index_provider.dart';
import '../../subscription/providers/subscribed_provider.dart';
import '../providers/auth_provider.dart';

@FFRoute(name: '/register')
class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showPassword = ref.watch(registerShowPasswordProvider);

    // Use flutter_hooks to manage controllers automatically
    final userNameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final emailController = useTextEditingController();
    final qqController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Watch the registration mutation state
    final registerState = ref.watch(registerMutation);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: edgeH24V36WithStatusBar(context),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Assets.mikan.image(width: 64.0),
                    const Gap(8),
                    Text('Mikan Project', style: theme.textTheme.bodySmall),
                    Text('蜜柑计划', style: theme.textTheme.titleLarge),
                    const Gap(16),
                    _buildUserNameField(userNameController),
                    const Gap(16),
                    _buildEmailField(emailController),
                    const Gap(16),
                    _buildPasswordField(passwordController, showPassword, ref),
                    const Gap(16),
                    _buildConfirmPasswordField(confirmPasswordController, passwordController, showPassword, ref),
                    const Gap(16),
                    _buildQQField(qqController),
                    const Gap(56),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.west_rounded),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildRegisterButton(
                            theme,
                            registerState,
                            formKey,
                            emailController,
                            passwordController,
                            confirmPasswordController,
                            ref,
                            context,
                          ),
                        ),
                      ],
                    ),
                    const Gap(56),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(
    ThemeData theme,
    MutationState<void> registerState,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isLoading = registerState is MutationPending;
    final hasError = registerState is MutationError;

    return ElevatedButton(
      style: ButtonStyle(backgroundColor: hasError ? const WidgetStatePropertyAll(Colors.red) : null),
      onPressed: isLoading
          ? null
          : () {
              if (!formKey.currentState!.validate()) {
                return;
              }

              // 使用 Mutation API
              registerMutation.run(ref, (tsx) async {
                await performRegister(
                  email: emailController.text,
                  password: passwordController.text,
                  confirmPassword: confirmPasswordController.text,
                );

                // Success - navigate and refresh
                if (context.mounted) {
                  '注册成功'.toast();
                  // ignore: unawaited_futures
                  Future.microtask(() {
                    ref.read(indexProvider.notifier).refresh();
                    ref.invalidate(recentRecordsProvider);
                  });
                  Navigator.popUntil(context, (route) => route.settings.name == Routes.index.name);
                }
              });
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isLoading ? '注册中' : '注册'),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 16, height: 16)),
          ],
        ],
      ),
    );
  }

  Widget _buildUserNameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        labelText: '用户名',
        hintText: '请输入用户名',
        prefixIcon: Icon(Icons.perm_identity_rounded),
      ),
      validator: (value) => value.isNullOrBlank ? '用户名不能为空' : null,
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

  Widget _buildEmailField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
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

  Widget _buildQQField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
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

  Widget _buildPasswordField(TextEditingController controller, bool showPassword, WidgetRef ref) {
    return TextFormField(
      obscureText: !showPassword,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        labelText: '密码',
        hintText: '请输入密码',
        prefixIcon: const Icon(Icons.password_rounded),
        suffixIcon: IconButton(
          icon: showPassword ? const Icon(Icons.visibility_rounded) : const Icon(Icons.visibility_off_rounded),
          onPressed: () => ref.read(registerShowPasswordProvider.notifier).toggle(),
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
  }

  Widget _buildConfirmPasswordField(
    TextEditingController controller,
    TextEditingController passwordController,
    bool showPassword,
    WidgetRef ref,
  ) {
    return TextFormField(
      obscureText: !showPassword,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        labelText: '确认密码',
        hintText: '请输入确认密码',
        prefixIcon: const Icon(Icons.key_rounded),
        suffixIcon: IconButton(
          icon: showPassword ? const Icon(Icons.visibility_rounded) : const Icon(Icons.visibility_off_rounded),
          onPressed: () => ref.read(registerShowPasswordProvider.notifier).toggle(),
        ),
      ),
      validator: (value) {
        if (value.isNullOrBlank) {
          return '确认密码不能为空';
        }
        if (value != passwordController.text) {
          return '确认密码与密码不一致，请重新输入';
        }
        return null;
      },
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
    );
  }
}
