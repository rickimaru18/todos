import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todos/core/errors/auth_failures.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/domain/usecases/auth_usecases.dart';

import '../../mocks.dart';

void main() {
  const String username = 'username';
  const String password = 'password';
  const User user = User(id: 0, username: username);

  late MockAuthRepository authRepository;
  late AuthUsecases authUsecases;

  setUp(() {
    authRepository = MockAuthRepository();
    authUsecases = AuthUsecases(authRepository: authRepository);
  });

  group('[Login]', () {
    test('Successful', () async {
      when(authRepository.login(any, any)).thenAnswer(
        (_) async => const Right<Failure, User>(user),
      );

      final Either<Failure, User> res = await authUsecases.login(
        username,
        password,
      );

      expect(res.isRight(), true);
      verify(authRepository.login(username, password));
      verifyNoMoreInteractions(authRepository);
    });

    test('Failure', () async {
      when(authRepository.login(any, any)).thenAnswer(
        (_) async => const Left<Failure, User>(Failure()),
      );

      final Either<Failure, User> res = await authRepository.login(
        username,
        password,
      );

      expect(res.isLeft(), true);
      verify(authRepository.login(username, password));
      verifyNoMoreInteractions(authRepository);
    });

    test('Invalid username', () async {
      final Either<Failure, User> res = await authUsecases.login(
        '',
        password,
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(InvalidUsernameFailure()));
      verifyNever(authRepository.login('', password));
      verifyNoMoreInteractions(authRepository);
    });

    test('Invalid password', () async {
      final Either<Failure, User> res = await authUsecases.login(
        username,
        '',
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(InvalidPasswordFailure()));
      verifyNever(authRepository.login(username, ''));
      verifyNoMoreInteractions(authRepository);
    });
  });

  group('[Signup]', () {
    test('Successful', () async {
      when(authRepository.signup(any, any)).thenAnswer(
        (_) async => const Right<Failure, User>(user),
      );

      final Either<Failure, User> res = await authUsecases.signup(
        username,
        password,
      );

      expect(res.isRight(), true);
      verify(authRepository.signup(username, password));
      verifyNoMoreInteractions(authRepository);
    });

    test('Failure', () async {
      when(authRepository.signup(any, any)).thenAnswer(
        (_) async => const Left<Failure, User>(Failure()),
      );

      final Either<Failure, User> res = await authRepository.signup(
        username,
        password,
      );

      expect(res.isLeft(), true);
      verify(authRepository.signup(username, password));
      verifyNoMoreInteractions(authRepository);
    });

    test('Invalid username', () async {
      final Either<Failure, User> res = await authUsecases.signup(
        '',
        password,
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(InvalidUsernameFailure()));
      verifyNever(authRepository.signup('', password));
      verifyNoMoreInteractions(authRepository);
    });

    test('Invalid password', () async {
      final Either<Failure, User> res = await authUsecases.signup(
        username,
        '',
      );

      expect(res.isLeft(), true);
      expect(res, const Left<Failure, User>(InvalidPasswordFailure()));
      verifyNever(authRepository.signup(username, ''));
      verifyNoMoreInteractions(authRepository);
    });
  });
}
