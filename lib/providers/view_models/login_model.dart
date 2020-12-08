import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/internal/store.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/view_models/base_model.dart';

class LoginModel extends CancelableBaseModel {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get accountController => _accountController;

  TextEditingController get passwordController => _passwordController;

  LoginModel() {
    final login = Store.getLogin();
    _accountController.text = login.getOrNull("UserName");
    _passwordController.text = login.getOrNull("Password");
    this._rememberMe = login.getOrNull("RememberMe") ?? false;
  }

  User _user;

  User get user => _user;

  bool _rememberMe;

  bool get rememberMe => _rememberMe;

  bool _loading = false;

  bool get loading => _loading;

  set rememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  submit(VoidCallback loginSuccess) async {
    this._loading = true;
    notifyListeners();
    final Resp tokenResp = await (this + Repo.refreshToken());
    if (!tokenResp.success) {
      return "获取登录参数失败".toast();
    }
    final String token = tokenResp.data;
    if (token.isNullOrBlank) {
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
      Store.setLogin(loginParams);
      "登录成功".toast();
      loginSuccess.call();
    } else {
      "登录失败，请稍候重试：${resp.msg}".toast();
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
