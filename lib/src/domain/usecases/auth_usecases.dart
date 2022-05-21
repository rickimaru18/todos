import 'package:dartz/dartz.dart';

import '../../../core/errors/auth_failures.dart';
import '../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthUsecases {
  const AuthUsecases({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  /// Register user.
  Future<Either<Failure, User>> signup(String username, String password) async {
    if (username.isEmpty) {
      return const Left<Failure, User>(InvalidUsernameFailure());
    } else if (password.isEmpty) {
      return const Left<Failure, User>(InvalidPasswordFailure());
    }

    return _authRepository.signup(username, password);
  }

  /// Login user.
  Future<Either<Failure, User>> login(String username, String password) async {
    if (username.isEmpty) {
      return const Left<Failure, User>(InvalidUsernameFailure());
    } else if (password.isEmpty) {
      return const Left<Failure, User>(InvalidPasswordFailure());
    }

    return _authRepository.login(username, password);
  }
}
