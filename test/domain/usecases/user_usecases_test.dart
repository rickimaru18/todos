import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/domain/usecases/user_usecases.dart';

import '../../mocks.dart';

void main() {
  const User user = User(id: 0, username: 'username');

  late MockUserRepository userRepository;
  late UserUsecases userUsecases;

  setUp(() {
    userRepository = MockUserRepository();
    userUsecases = UserUsecases(userRepository: userRepository);
  });

  test('Already logged-in check', () async {
    when(userRepository.getLoggedInUser()).thenAnswer(
      (_) async => const Right(user),
    );

    final Either<Failure, User?> res = await userUsecases.getLoggedInUser();

    expect(res.isRight(), true);
    expect(res, const Right(user));
    verify(userRepository.getLoggedInUser());
    verifyNoMoreInteractions(userRepository);
  });

  test('Not logged-in check', () async {
    when(userRepository.getLoggedInUser()).thenAnswer(
      (_) async => const Right(null),
    );

    final Either<Failure, User?> res = await userUsecases.getLoggedInUser();

    expect(res.isRight(), true);
    expect(res, const Right(null));
    verify(userRepository.getLoggedInUser());
    verifyNoMoreInteractions(userRepository);
  });
}
