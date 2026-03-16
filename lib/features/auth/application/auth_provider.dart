import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/features/home/application/index_provider.dart';
import 'package:mikan/features/subscription/application/subscribed_provider.dart';

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

  /// Updates the remember me state.
  void update(bool value) {
    state = value;
  }
}

/// Saved login credentials.
class SavedLogin {
  const SavedLogin({this.userName = '', this.password = '', this.rememberMe = false});
  final String userName;
  final String password;
  final bool rememberMe;
}

/// Get saved login credentials for UI pre-filling.
SavedLogin getSavedCredentials() {
  final login = MyHive.getLogin();
  return SavedLogin(
    userName: login['UserName'] ?? '',
    password: login['Password'] ?? '',
    rememberMe: login['RememberMe'] ?? false,
  );
}

final loginMutation = Mutation<void>();

/// Performs login with the given credentials.
Future<void> performLogin({required String userName, required String password, required bool rememberMe}) async {
  await MikanApi.login(userName, password);

  // Save credentials if remember me is checked
  if (rememberMe) {
    MyHive.setLogin({'UserName': userName, 'Password': password, 'RememberMe': rememberMe});
  } else {
    unawaited(MyHive.removeLogin());
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

Future<void> performRegister({
  required String userName,
  required String email,
  required String password,
  required String confirmPassword,
  String? qq,
}) async {
  await MikanApi.register(userName, email, password, confirmPassword, qq: qq);
}

final forgotPasswordMutation = Mutation<void>();

Future<void> performForgotPassword({required String email}) async {
  await MikanApi.forgotPassword(email);
}

Future<void> refreshDataAfterAuthentication(ProviderContainer container) async {
  await container.read(indexProvider.notifier).refresh();
  container.invalidate(recentRecordsProvider);
}

String formatAuthError(Object error) {
  var message = error.toString().trim();
  const prefixes = ['Bad state: ', 'StateError: ', 'Exception: ', 'Error: '];

  var updated = true;
  while (updated) {
    updated = false;
    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length).trim();
        updated = true;
      }
    }
  }

  return message;
}
