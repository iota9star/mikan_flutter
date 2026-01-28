import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../shared/internal/hive.dart';

final showPasswordProvider = NotifierProvider.autoDispose<ShowPasswordNotifier, bool>(ShowPasswordNotifier.new);

class ShowPasswordNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final rememberMeProvider = NotifierProvider<RememberMeNotifier, bool>(RememberMeNotifier.new);

class RememberMeNotifier extends Notifier<bool> {
  @override
  bool build() {
    final login = MyHive.getLogin();
    return login['RememberMe'] ?? false;
  }

  // ignore: use_setters_to_change_properties
  void update(bool value) {
    state = value;
  }
}

/// Saved login credentials
class SavedLogin {
  const SavedLogin({this.userName = '', this.password = '', this.rememberMe = false});
  final String userName;
  final String password;
  final bool rememberMe;
}

/// Get saved login credentials for UI pre-filling
SavedLogin getSavedCredentials() {
  final login = MyHive.getLogin();
  return SavedLogin(
    userName: login['UserName'] ?? '',
    password: login['Password'] ?? '',
    rememberMe: login['RememberMe'] ?? false,
  );
}

final loginMutation = Mutation<void>();

Future<void> performLogin({required String userName, required String password, required bool rememberMe}) async {
  await MikanApi.login(userName, password);

  // Save credentials if remember me is checked
  if (rememberMe) {
    MyHive.setLogin({'UserName': userName, 'Password': password, 'RememberMe': rememberMe});
  } else {
    // ignore: unawaited_futures
    MyHive.removeLogin();
  }
}

final registerShowPasswordProvider = NotifierProvider.autoDispose<RegisterShowPasswordNotifier, bool>(
  RegisterShowPasswordNotifier.new,
);

class RegisterShowPasswordNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final registerMutation = Mutation<void>();

Future<void> performRegister({required String email, required String password, required String confirmPassword}) async {
  await MikanApi.register(email, password, confirmPassword);
}

final forgotPasswordMutation = Mutation<void>();

Future<void> performForgotPassword({required String email}) async {
  await MikanApi.forgotPassword(email);
}
