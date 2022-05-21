import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todos/core/errors/auth_failures.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/core/settings/configs.dart';
import 'package:todos/src/data/models/user_model.dart';
import 'package:todos/src/data/repositories/auth_repository_impl.dart';
import 'package:todos/src/domain/entities/entities.dart';

import '../../mocks.dart';

void main() {
  const String username = 'username';
  const String password = 'password';
  const User user = User(id: 0, username: username);

  late MockUserLocalSource userLocalSource;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    userLocalSource = MockUserLocalSource();
    authRepository = AuthRepositoryImpl(userLocalSource: userLocalSource);
  });

  group('[Login]', () {
    test('Successful', () async {
      when(userLocalSource.hasUser(any)).thenAnswer((_) async => true);
      when(userLocalSource.getUser(any, any)).thenAnswer(
        (_) async => UserSignupModel(user.id, password),
      );

      final Either<Failure, User> res = await authRepository.login(
        username,
        password,
      );

      expect(res.isRight(), true);
      verify(userLocalSource.hasUser(username));
      verify(userLocalSource.getUser(username, password));
      verify(userLocalSource.loginUser(username));
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Username not found', () async {
      when(userLocalSource.hasUser(any)).thenAnswer((_) async => false);

      final Either<Failure, User> res = await authRepository.login(
        username,
        password,
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(UsernameNotFoundFailure()));
      verify(userLocalSource.hasUser(username));
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Incorrect password', () async {
      when(userLocalSource.hasUser(any)).thenAnswer((_) async => true);
      when(userLocalSource.getUser(any, any)).thenAnswer((_) async => null);

      final Either<Failure, User> res = await authRepository.login(
        username,
        password,
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(IncorrectPasswordFailure()));
      verify(userLocalSource.hasUser(username));
      verify(userLocalSource.getUser(username, password));
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Failure', () async {
      when(userLocalSource.hasUser(any)).thenAnswer((_) async => true);
      when(userLocalSource.getUser(any, any)).thenThrow(Exception());

      final Either<Failure, User> res = await authRepository.login(
        username,
        password,
      );

      expect(res.isLeft(), true);
      verify(userLocalSource.hasUser(username));
      verify(userLocalSource.getUser(username, password));
      verifyNoMoreInteractions(userLocalSource);
    });
  });

  group('[Signup]', () {
    test('Successful', () async {
      when(userLocalSource.userCount()).thenAnswer((_) async => 0);
      when(userLocalSource.hasUser(any)).thenAnswer((_) async => false);
      when(userLocalSource.addUser(any, any)).thenAnswer(
        (_) async => UserSignupModel(user.id, password),
      );

      final Either<Failure, User> res = await authRepository.signup(
        username,
        password,
      );

      expect(res.isRight(), true);
      verify(userLocalSource.userCount());
      verify(userLocalSource.hasUser(username));
      verify(userLocalSource.addUser(username, password));
      verify(userLocalSource.loginUser(username));
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Max users reached', () async {
      when(userLocalSource.userCount()).thenAnswer(
        (_) async => Configs.maxUsers,
      );

      final Either<Failure, User> res = await authRepository.signup(
        username,
        password,
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(MaxUsersFailure()));
      verify(userLocalSource.userCount());
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Username taken', () async {
      when(userLocalSource.userCount()).thenAnswer((_) async => 0);
      when(userLocalSource.hasUser(any)).thenAnswer((_) async => true);

      final Either<Failure, User> res = await authRepository.signup(
        username,
        password,
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(UsernameTakenFailure()));
      verify(userLocalSource.userCount());
      verify(userLocalSource.hasUser(username));
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Failure', () async {
      when(userLocalSource.userCount()).thenAnswer((_) async => 0);
      when(userLocalSource.hasUser(any)).thenAnswer((_) async => false);
      when(userLocalSource.addUser(any, any)).thenThrow(Exception());

      final Either<Failure, User> res = await authRepository.signup(
        username,
        password,
      );

      expect(res.isLeft(), true);
      verify(userLocalSource.userCount());
      verify(userLocalSource.hasUser(username));
      verify(userLocalSource.addUser(username, password));
      verifyNoMoreInteractions(userLocalSource);
    });
  });
}
