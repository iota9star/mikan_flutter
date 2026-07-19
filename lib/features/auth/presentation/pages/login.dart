import 'dart:async';

import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import 'package:mikan/app/routing/mikan_routes.dart';
import 'package:mikan/res/assets.gen.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/features/auth/application/auth_provider.dart';

@FFRoute(name: '/login')
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showPassword = ref.watch(showPasswordProvider);
    final rememberMe = ref.watch(rememberMeProvider);

    // Use flutter_hooks to manage controllers automatically
    final savedCredentials = useMemoized(getSavedCredentials);
    final accountController = useTextEditingController(text: savedCredentials.userName);
    final passwordController = useTextEditingController(text: savedCredentials.password);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Reset the (process-global) mutation state on mount so a stale error or
    // loading indicator from a previous visit — or a second instance of this
    // page — never bleeds into a fresh entry. Without this, the red error
    // button and error text persist until a successful run.
    useEffect(() {
      loginMutation.reset(ref);
      return null;
    }, const []);

    // Watch the login mutation state
    final loginState = ref.watch(loginMutation);
    final errorMessage = loginState is MutationError<void> ? formatAuthError(loginState.error) : null;

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
                    const Gap(42),
                    _buildUserNameField(accountController),
                    const Gap(16),
                    _buildPasswordField(passwordController, showPassword, ref),
                    const Gap(16),
                    _buildRememberRow(rememberMe, context, ref),
                    const Gap(16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.register.name),
                      child: const Text('还没有账号？赶紧来注册一个吧~'),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.west_rounded),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildLoginButton(
                            theme,
                            loginState,
                            formKey,
                            accountController,
                            passwordController,
                            ref,
                            context,
                          ),
                        ),
                      ],
                    ),
                    if (errorMessage != null) ...[
                      const Gap(16),
                      Text(
                        errorMessage,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
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

  Widget _buildLoginButton(
    ThemeData theme,
    MutationState<void> loginState,
    GlobalKey<FormState> formKey,
    TextEditingController accountController,
    TextEditingController passwordController,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isLoading = loginState is MutationPending;
    final hasError = loginState is MutationError;

    return ElevatedButton(
      style: ButtonStyle(backgroundColor: hasError ? WidgetStatePropertyAll(theme.colorScheme.error) : null),
      onPressed: isLoading
          ? null
          : () {
              if (!formKey.currentState!.validate()) {
                return;
              }

              loginMutation.run(ref, (tsx) async {
                await performLogin(
                  userName: accountController.text,
                  password: passwordController.text,
                  rememberMe: ref.read(rememberMeProvider),
                );

                // Success - navigate and refresh
                if (context.mounted) {
                  final container = ProviderScope.containerOf(context, listen: false);
                  '登录成功'.toast();
                  Navigator.popUntil(context, (route) => route.settings.name == Routes.index.name);
                  unawaited(refreshDataAfterAuthentication(container));
                }
              });
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isLoading ? '登录中...' : '登录'),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 16, height: 16)),
          ],
        ],
      ),
    );
  }

  Widget _buildRememberRow(bool rememberMe, BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        Checkbox(value: rememberMe, onChanged: (val) => ref.read(rememberMeProvider.notifier).update(val ?? false)),
        const Expanded(child: Text('记住密码')),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.forgetPassword.name),
          child: const Text('忘记密码'),
        ),
      ],
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
          icon: Icon(showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
          onPressed: () => ref.read(showPasswordProvider.notifier).toggle(),
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
  }
}
