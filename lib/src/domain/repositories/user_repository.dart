import 'package:dartz/dartz.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/user.dart';

abstract class UserRepository {
  /// Get logged-in user.
  Future<Either<Failure, User?>> getLoggedInUser();

  /// Logout user.
  Future<Either<Failure, bool>> logout();
}
