import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Register user.
  Future<Either<Failure, User>> signup(String username, String password);

  /// Login user.
  Future<Either<Failure, User>> login(String username, String password);
}
