import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class UserRepository {
  /// Get logged-in user.
  Future<Either<Failure, User?>> getLoggedInUser();

  /// Logout user.
  Future<Either<Failure, bool>> logout();
}
