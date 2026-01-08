import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import '../../../../../res/assets.gen.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../shared/ui/fragments/forgot_password_confirm.dart';
import '../../../../../shared/widgets/bottom_sheet.dart';
import '../../../../../topvars.dart';
import '../providers/auth_provider.dart';

@FFRoute(name: '/forget-password')
class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Use flutter_hooks to manage controller automatically
    final emailController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // Watch the forgot password mutation state
    final forgotPasswordState = ref.watch(forgotPasswordMutation);

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
                  children: [
                    Image.asset(Assets.mikan.path, width: 64.0),
                    const Gap(8),
                    Text('Mikan Project', style: theme.textTheme.bodySmall),
                    Text('蜜柑计划', style: theme.textTheme.titleLarge),
                    const Gap(42),
                    _buildEmailField(emailController),
                    const Gap(42),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.west_rounded),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildSubmitButton(theme, forgotPasswordState, formKey, emailController, ref, context),
                        ),
                      ],
                    ),
                    const Gap(42),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    ThemeData theme,
    MutationState<void> forgotPasswordState,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isLoading = forgotPasswordState is MutationPending;
    final hasError = forgotPasswordState is MutationError;

    return ElevatedButton(
      style: ButtonStyle(backgroundColor: hasError ? const WidgetStatePropertyAll(Colors.red) : null),
      onPressed: isLoading
          ? null
          : () {
              if (!formKey.currentState!.validate()) {
                return;
              }

              // 使用 Mutation API
              forgotPasswordMutation.run(ref, (tsx) async {
                await performForgotPassword(email: emailController.text);

                // Success
                if (context.mounted) {
                  '重置密码邮件发送成功'.toast();
                  _showForgotPasswordConfirmationPanel(context);
                }
              });
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isLoading ? '提交中...' : '提交'),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 16, height: 16)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
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
        if (!RegExp(r'.+@.+\..+').hasMatch(value!)) {
          return '邮箱格式不正确';
        }
        return null;
      },
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.emailAddress,
    );
  }

  void _showForgotPasswordConfirmationPanel(BuildContext context) {
    MBottomSheet.show(context, (context) => const MBottomSheet(child: ForgotPasswordConfirm()));
  }
}
