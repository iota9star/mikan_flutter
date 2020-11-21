import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class LoginModel extends CancelableBaseModel {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get accountController => _accountController;

  TextEditingController get passwordController => _passwordController;

  User _user;

  User get user => _user;

  bool _rememberMe = true;

  bool get rememberMe => _rememberMe;

  bool _loading = false;

  bool get loading => _loading;

  set rememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  set user(User value) {
    _user = value;
    notifyListeners();
  }

  submit(VoidCallback loginSuccess) async {
    final Map<String, dynamic> loginPrams = {
      "UserName": _accountController.text,
      "Password": _passwordController.text,
      "RememberMe": _rememberMe,
      "__RequestVerificationToken": _user.token
    };
    this._loading = true;
    notifyListeners();
    final Resp resp = await (this + Repo.submit(loginPrams));
    this._loading = false;
    notifyListeners();
    if (resp.success) {
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
