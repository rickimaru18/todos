import 'package:todos/src/data/datasources/local/user_local_source.dart';
import 'package:todos/src/data/models/user_model.dart';
import 'package:todos/src/domain/entities/user.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:todos/src/domain/repositories/user_repository.dart';

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
          ? Right(User(id: userSignupModel!.id, username: username!))
          : const Right(null);
    } catch (e) {
      res = const Left(Failure('Getting logged-in user failed.'));
    }

    return res;
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    Either<Failure, bool> res;

    try {
      res = Right(await _userLocalSource.logoutUser());
    } catch (e) {
      res = const Left(Failure('Logout failed. Please try again.'));
    }

    return res;
  }
}
