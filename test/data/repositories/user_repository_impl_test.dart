import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/data/models/user_model.dart';
import 'package:todos/src/data/repositories/user_repository_impl.dart';
import 'package:todos/src/domain/entities/entities.dart';

import '../../mocks.dart';

void main() {
  late MockUserLocalSource userLocalSource;
  late UserRepositoryImpl userRepository;

  setUp(() {
    userLocalSource = MockUserLocalSource();
    userRepository = UserRepositoryImpl(
      userLocalSource: userLocalSource,
    );
  });

  group('[Check if logged-in]', () {
    test('Already logged-in', () async {
      when(userLocalSource.getLoggedInUser()).thenAnswer(
        (_) async => <String, UserSignupModel>{
          'username': UserSignupModel(0, 'password')
        },
      );

      final Either<Failure, User?> res = await userRepository.getLoggedInUser();

      expect(res.isRight(), true);
      verify(userLocalSource.getLoggedInUser());
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Not yet logged-in', () async {
      when(userLocalSource.getLoggedInUser()).thenAnswer((_) async => null);

      final Either<Failure, User?> res = await userRepository.getLoggedInUser();

      expect(res.isRight(), true);
      expect(res, const Right(null));
      verify(userLocalSource.getLoggedInUser());
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Failure', () async {
      when(userLocalSource.getLoggedInUser()).thenThrow(Exception());

      final Either<Failure, User?> res = await userRepository.getLoggedInUser();

      expect(res.isLeft(), true);
      verify(userLocalSource.getLoggedInUser());
      verifyNoMoreInteractions(userLocalSource);
    });
  });

  group('[Logout]', () {
    test('Successful', () async {
      when(userLocalSource.logoutUser()).thenAnswer((_) async => true);

      final Either<Failure, bool> res = await userRepository.logout();

      expect(res.isRight(), true);
      expect(res, const Right(true));
      verify(userLocalSource.logoutUser());
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Unsuccessful', () async {
      when(userLocalSource.logoutUser()).thenAnswer((_) async => false);

      final Either<Failure, bool> res = await userRepository.logout();

      expect(res.isRight(), true);
      expect(res, const Right(false));
      verify(userLocalSource.logoutUser());
      verifyNoMoreInteractions(userLocalSource);
    });

    test('Failure', () async {
      when(userLocalSource.logoutUser()).thenThrow(Exception());

      final Either<Failure, bool> res = await userRepository.logout();

      expect(res.isLeft(), true);
      verify(userLocalSource.logoutUser());
      verifyNoMoreInteractions(userLocalSource);
    });
  });
}
