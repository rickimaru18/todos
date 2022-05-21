import 'package:dartz/dartz.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/user.dart';

abstract class AuthRepository {
  /// Register user.
  Future<Either<Failure, User>> signup(String username, String password);

  /// Login user.
  Future<Either<Failure, User>> login(String username, String password);
}
