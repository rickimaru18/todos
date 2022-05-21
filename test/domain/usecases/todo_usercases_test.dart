import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/domain/usecases/todo_usecases.dart';

import '../../mocks.dart';

void main() {
  const User user = User(id: 0, username: 'username');

  late MockTodoRepository todoRepository;
  late TodoUsecases todoUsecases;

  setUp(() {
    todoRepository = MockTodoRepository();
    todoUsecases = TodoUsecases(todoRepository: todoRepository);
  });

  group('[TODO fetch]', () {
    test('Successful', () async {
      when(todoRepository.getTodos(any)).thenAnswer(
        (_) async => const Right(<Todo>[]),
      );

      final Either<Failure, List<Todo>> res =
          await todoUsecases.getTodos(user.id);

      expect(res.isRight(), true);
      verify(todoRepository.getTodos(user.id));
      verifyNoMoreInteractions(todoRepository);
    });

    test('Fetch with invalid user ID', () async {
      final Either<Failure, List<Todo>> res = await todoUsecases.getTodos(-1);

      expect(res.isLeft(), true);
      verifyNever(todoRepository.getTodos(-1));
      verifyNoMoreInteractions(todoRepository);
    });

    test('Failure', () async {
      when(todoRepository.getTodos(any)).thenAnswer(
        (_) async => const Left(Failure()),
      );

      final Either<Failure, List<Todo>> res =
          await todoUsecases.getTodos(user.id);

      expect(res.isLeft(), true);
      verify(todoRepository.getTodos(user.id));
      verifyNoMoreInteractions(todoRepository);
    });
  });

  group('[Complete TODOs]', () {
    test('Successful', () async {
      final Todo todo = Todo(userId: 0, id: 1, title: 'title');

      when(todoRepository.toggleTodoComplete(any)).thenAnswer(
        (_) async => Right(Todo.complete(todo)),
      );

      final Either<Failure, Todo> res =
          await todoUsecases.toggleTodoComplete(todo);

      expect(res.isRight(), true);
      expect(res.fold<bool>((_) => false, (Todo r) => r.completed), true);
      verify(todoRepository.toggleTodoComplete(todo));
      verifyNoMoreInteractions(todoRepository);
    });

    test('Failure', () async {
      when(todoRepository.toggleTodoComplete(any)).thenAnswer(
        (_) async => const Left(Failure()),
      );

      final Todo todo = Todo(userId: 0, id: 1, title: 'title');
      final Either<Failure, Todo> res =
          await todoUsecases.toggleTodoComplete(todo);

      expect(res.isLeft(), true);
      verify(todoRepository.toggleTodoComplete(todo));
      verifyNoMoreInteractions(todoRepository);
    });
  });

  group('[Not complete TODOs]', () {
    test('Successful', () async {
      final Todo todo = Todo(
        userId: 0,
        id: 1,
        title: 'title',
        completed: true,
      );

      when(todoRepository.toggleTodoComplete(any)).thenAnswer(
        (_) async => Right(Todo.notComplete(todo)),
      );

      final Either<Failure, Todo> res =
          await todoUsecases.toggleTodoComplete(todo);

      expect(res.isRight(), true);
      expect(res.fold<bool>((_) => false, (Todo r) => r.completed), false);
      verify(todoRepository.toggleTodoComplete(todo));
      verifyNoMoreInteractions(todoRepository);
    });

    test('Failure', () async {
      when(todoRepository.toggleTodoComplete(any)).thenAnswer(
        (_) async => const Left(Failure()),
      );

      final Todo todo = Todo(
        userId: 0,
        id: 1,
        title: 'title',
        completed: true,
      );
      final Either<Failure, Todo> res =
          await todoUsecases.toggleTodoComplete(todo);

      expect(res.isLeft(), true);
      verify(todoRepository.toggleTodoComplete(todo));
      verifyNoMoreInteractions(todoRepository);
    });
  });
}
