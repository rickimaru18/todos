import 'package:dartz/dartz.dart';

import '../../../core/errors/auth_failures.dart';
import '../../../core/errors/failure.dart';
import '../../../core/settings/configs.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/user_local_source.dart';
import '../models/user_model.dart';

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
        res = const Left<Failure, User>(MaxUsersFailure());
      } else if (await _userLocalSource.hasUser(username)) {
        res = const Left<Failure, User>(UsernameTakenFailure());
      } else {
        final UserSignupModel signupModel = await _userLocalSource.addUser(
          username,
          password,
        );
        await _userLocalSource.loginUser(username);

        res = Right<Failure, User>(
          User(id: signupModel.id, username: username),
        );
      }
    } catch (e) {
      res = const Left<Failure, User>(
        Failure('Sign up failed. Please try again.'),
      );
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
          res = Right<Failure, User>(
            User(id: signupModel.id, username: username),
          );
        } else {
          res = const Left<Failure, User>(IncorrectPasswordFailure());
        }
      } else {
        res = const Left<Failure, User>(UsernameNotFoundFailure());
      }
    } catch (e) {
      res = const Left<Failure, User>(
        Failure('Login failed. Please try again.'),
      );
    }

    return res;
  }
}
