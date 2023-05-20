import 'package:flutter/material.dart';

import '../internal/extension.dart';
import '../internal/http.dart';
import '../internal/repo.dart';
import 'base_model.dart';

class ForgotPasswordModel extends BaseModel {
  final TextEditingController _emailController = TextEditingController();

  TextEditingController get emailController => _emailController;

  bool _loading = false;

  bool get loading => _loading;

  Future<void> submit(VoidCallback onSuccess) async {
    _loading = true;
    notifyListeners();
    final Resp tokenResp = await Repo.refreshForgotPasswordToken();
    if (!tokenResp.success) {
      _loading = false;
      notifyListeners();
      return '获取重置密码参数失败'.toast();
    }
    final String token = tokenResp.data;
    if (token.isNullOrBlank) {
      _loading = false;
      notifyListeners();
      return '获取重置密码参数为空，请稍候重试'.toast();
    }
    final Map<String, dynamic> params = {
      'Email': _emailController.text,
      '__RequestVerificationToken': token
    };
    final Resp resp = await Repo.forgotPassword(params);
    _loading = false;
    notifyListeners();
    if (resp.success) {
      '重置密码邮件发送成功'.toast();
      onSuccess.call();
    } else {
      '重置密码邮件失败，请稍候重试：${resp.msg}'.toast();
    }
  }

  @override
  Future<void> dispose() async {
    _emailController.dispose();
    super.dispose();
  }
}
