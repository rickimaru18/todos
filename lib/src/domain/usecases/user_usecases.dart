import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UserUsecases {
  const UserUsecases({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  final UserRepository _userRepository;

  /// Get logged-in user.
  Future<Either<Failure, User?>> getLoggedInUser() =>
      _userRepository.getLoggedInUser();

  /// Logout user.
  Future<Either<Failure, bool>> logout() => _userRepository.logout();
}
