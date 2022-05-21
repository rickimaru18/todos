import 'package:dartz/dartz.dart';
import 'package:todos/core/errors/auth_failures.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/user.dart';
import 'package:todos/src/domain/repositories/auth_repository.dart';

class AuthUsecases {
  const AuthUsecases({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  /// Register user.
  Future<Either<Failure, User>> signup(String username, String password) async {
    if (username.isEmpty) {
      return const Left(InvalidUsernameFailure());
    } else if (password.isEmpty) {
      return const Left(InvalidPasswordFailure());
    }

    return _authRepository.signup(username, password);
  }

  /// Login user.
  Future<Either<Failure, User>> login(String username, String password) async {
    if (username.isEmpty) {
      return const Left(InvalidUsernameFailure());
    } else if (password.isEmpty) {
      return const Left(InvalidPasswordFailure());
    }

    return _authRepository.login(username, password);
  }
}
