import 'dart:async';

import 'package:flutter/material.dart';

import '../internal/extension.dart';
import '../internal/hive.dart';
import '../internal/http.dart';
import '../internal/repo.dart';
import 'base_model.dart';

class LoginModel extends BaseModel {
  LoginModel() {
    final login = MyHive.getLogin();
    _accountController.text = login['UserName'] ?? '';
    _passwordController.text = login['Password'] ?? '';
    _rememberMe = login['RememberMe'] ?? false;
  }

  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get accountController => _accountController;

  TextEditingController get passwordController => _passwordController;

  bool _rememberMe = false;

  bool get rememberMe => _rememberMe;

  bool _loading = false;

  bool get loading => _loading;

  set rememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  bool _showPassword = false;

  bool get showPassword => _showPassword;

  set showPassword(bool value) {
    _showPassword = value;
    notifyListeners();
  }

  Future<void> submit(VoidCallback loginSuccess) async {
    _loading = true;
    notifyListeners();
    final Resp tokenResp = await  Repo.refreshLoginToken();
    if (!tokenResp.success) {
      _loading = false;
      notifyListeners();
      return '获取登录参数失败'.toast();
    }
    final String token = tokenResp.data;
    if (token.isNullOrBlank) {
      _loading = false;
      notifyListeners();
      return '获取登录参数为空，请稍候重试'.toast();
    }
    final Map<String, dynamic> loginParams = {
      'UserName': _accountController.text,
      'Password': _passwordController.text,
      'RememberMe': _rememberMe,
      '__RequestVerificationToken': token
    };
    final Resp resp = await  Repo.login(loginParams);
    _loading = false;
    notifyListeners();
    if (resp.success) {
      if (_rememberMe) {
        MyHive.setLogin(loginParams);
      } else {
        unawaited(MyHive.removeLogin());
      }
      '登录成功'.toast();
      loginSuccess.call();
    } else {
      '${resp.msg}'.toast();
    }
  }

  ValueNotifier<bool> can = ValueNotifier(false);

  @override
  Future<void> dispose() async {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
