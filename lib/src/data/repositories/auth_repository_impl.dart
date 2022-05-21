import 'package:todos/core/errors/auth_failures.dart';
import 'package:todos/core/settings/configs.dart';
import 'package:todos/src/data/datasources/local/user_local_source.dart';
import 'package:todos/src/data/models/user_model.dart';
import 'package:todos/src/domain/entities/user.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:todos/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    UserLocalSource? userLocalSource,
  }) : _userLocalSource = userLocalSource ?? UserLocalSource();

  final UserLocalSource _userLocalSource;

  @override
  Future<Either<Failure, User>> signup(String username, String password) async {
    Either<Failure, User> res;

    try {
      if (await _userLocalSource.userCount() == Configs.maxUsers) {
        res = const Left(MaxUsersFailure());
      } else if (await _userLocalSource.hasUser(username)) {
        res = const Left(UsernameTakenFailure());
      } else {
        final UserSignupModel signupModel = await _userLocalSource.addUser(
          username,
          password,
        );
        await _userLocalSource.loginUser(username);

        res = Right(User(id: signupModel.id, username: username));
      }
    } catch (e) {
      res = const Left(Failure('Sign up failed. Please try again.'));
    }

    return res;
  }

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    Either<Failure, User> res;

    try {
      if (await _userLocalSource.hasUser(username)) {
        final UserSignupModel? signupModel =
            await _userLocalSource.getUser(username, password);

        if (signupModel != null) {
          await _userLocalSource.loginUser(username);
          res = Right(User(id: signupModel.id, username: username));
        } else {
          res = const Left(IncorrectPasswordFailure());
        }
      } else {
        res = const Left(UsernameNotFoundFailure());
      }
    } catch (e) {
      res = const Left(Failure('Login failed. Please try again.'));
    }

    return res;
  }
}
