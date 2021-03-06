import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'viewmodel.dart';

class LoginViewModel extends Viewmodel {
  LoginViewModel({
    AuthUsecases? authUsecases,
  }) : _authUsecases = authUsecases ??
            AuthUsecases(
              authRepository: AuthRepositoryImpl(),
            );

  final AuthUsecases _authUsecases;

  /// Flag if [login] or [signup] in ongoing.
  bool get isLoggingIn => _isLoggingIn;
  bool _isLoggingIn = false;

  /// Login user.
  Future<User?> login(String username, String password) => _execute(
        () => _authUsecases.login(
          username,
          password,
        ),
      );

  /// Register user.
  Future<User?> signup(String username, String password) => _execute(
        () => _authUsecases.signup(
          username,
          password,
        ),
      );

  /// Execute [usecase].
  Future<User?> _execute(
    Future<Either<Failure, User>> Function() usecase,
  ) async {
    if (_isLoggingIn) {
      return null;
    }

    User? user;

    _isLoggingIn = true;
    notifyListeners();

    final Either<Failure, User> res = await usecase();

    res.fold(
      (Failure l) => onError?.call(l.error),
      (User r) => user = r,
    );

    _isLoggingIn = false;
    notifyListeners();

    return user;
  }
}
