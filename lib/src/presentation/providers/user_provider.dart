import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/failure.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/user_usecases.dart';
import '../viewmodels/viewmodel.dart';

class UserProvider extends Viewmodel {
  UserProvider({
    UserUsecases? userUsecases,
  }) : _userUsecases = userUsecases ??
            UserUsecases(
              userRepository: UserRepositoryImpl(),
            ) {
    _init();
  }

  final UserUsecases _userUsecases;

  /// Callback when [user] changes.
  ValueChanged<User?>? onUserChanged;

  /// Currently logged-in user.
  User? get user => _user;
  User? _user;
  set user(User? user) {
    _user = user;
    onUserChanged?.call(user);
  }

  /// Flag if [logout] is ongoing.
  bool get isLoggingOut => _isLoggingOut;
  bool _isLoggingOut = false;

  /// Setup.
  Future<void> _init() async {
    final Either<Failure, User?> res = await _userUsecases.getLoggedInUser();

    res.fold(
      (Failure l) {
        // Do nothing.
      },
      (User? r) => user = r,
    );
  }

  /// Logout [user].
  Future<bool> logout() async {
    if (_isLoggingOut || user == null) {
      return false;
    }

    _isLoggingOut = true;
    notifyListeners();

    final Either<Failure, bool> res = await _userUsecases.logout();

    bool isLogout = false;

    res.fold(
      (Failure l) => onError?.call(l.error),
      (bool r) {
        isLogout = r;
        user = null;
      },
    );

    _isLoggingOut = false;
    notifyListeners();

    return isLogout;
  }

  @override
  void dispose() {
    onUserChanged = null;
    super.dispose();
  }
}
