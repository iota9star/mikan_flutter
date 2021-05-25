import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/internal/store.dart';
import 'package:mikan_flutter/providers/base_model.dart';

class LoginModel extends CancelableBaseModel {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get accountController => _accountController;

  TextEditingController get passwordController => _passwordController;

  LoginModel() {
    final login = Store.getLogin();
    _accountController.text = login["UserName"] ?? "";
    _passwordController.text = login["Password"] ?? "";
    this._rememberMe = login["RememberMe"] ?? false;
  }

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

  submit(VoidCallback loginSuccess) async {
    this._loading = true;
    notifyListeners();
    final Resp tokenResp = await (this + Repo.refreshLoginToken());
    if (!tokenResp.success) {
      this._loading = false;
      notifyListeners();
      return "获取登录参数失败".toast();
    }
    final String token = tokenResp.data;
    if (token.isNullOrBlank) {
      this._loading = false;
      notifyListeners();
      return "获取登录参数为空，请稍候重试".toast();
    }
    final Map<String, dynamic> loginParams = {
      "UserName": _accountController.text,
      "Password": _passwordController.text,
      "RememberMe": _rememberMe,
      "__RequestVerificationToken": token
    };
    final Resp resp = await (this + Repo.login(loginParams));
    this._loading = false;
    notifyListeners();
    if (resp.success) {
      if (_rememberMe) {
        Store.setLogin(loginParams);
      } else {
        Store.removeLogin();
      }
      "登录成功".toast();
      loginSuccess.call();
    } else {
      "登录失败，请稍候重试：${resp.msg}".toast();
    }
  }

  ValueNotifier<bool> can = ValueNotifier(false);

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
