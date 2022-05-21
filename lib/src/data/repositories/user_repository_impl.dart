import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_local_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    UserLocalSource? userLocalSource,
  }) : _userLocalSource = userLocalSource ?? UserLocalSource();

  final UserLocalSource _userLocalSource;

  @override
  Future<Either<Failure, User?>> getLoggedInUser() async {
    Either<Failure, User?> res;

    try {
      final Map<String, UserSignupModel>? loggedInUser =
          await _userLocalSource.getLoggedInUser();
      final String? username = loggedInUser?.keys.first;
      final UserSignupModel? userSignupModel = loggedInUser?.values.first;

      res = loggedInUser != null
          ? Right<Failure, User?>(
              User(id: userSignupModel!.id, username: username!),
            )
          : const Right<Failure, User?>(null);
    } catch (e) {
      res = const Left<Failure, User?>(
        Failure('Getting logged-in user failed.'),
      );
    }

    return res;
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    Either<Failure, bool> res;

    try {
      res = Right<Failure, bool>(await _userLocalSource.logoutUser());
    } catch (e) {
      res = const Left<Failure, bool>(
        Failure('Logout failed. Please try again.'),
      );
    }

    return res;
  }
}
