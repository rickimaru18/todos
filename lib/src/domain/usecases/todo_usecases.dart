import 'package:dartz/dartz.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/core/errors/user_failures.dart';
import 'package:todos/src/domain/entities/todo.dart';
import 'package:todos/src/domain/repositories/todo_repository.dart';

class TodoUsecases {
  const TodoUsecases({
    required TodoRepository todoRepository,
  }) : _todoRepository = todoRepository;

  final TodoRepository _todoRepository;

  /// Get TODOs.
  Future<Either<Failure, List<Todo>>> getTodos(int userId) async {
    if (userId < 0) {
      return const Left(InvalidUserIdFailure());
    }
    return _todoRepository.getTodos(userId);
  }

  /// Listen to changes of TODOs with [userId].
  Future<Either<Failure, Stream<List<Todo>>>> listenToChanges(
    int userId,
  ) async {
    if (userId < 0) {
      return const Left(InvalidUserIdFailure());
    }

    return _todoRepository.listenToChanges(userId);
  }

  /// Toggle [todo.completed] state.
  Future<Either<Failure, Todo>> toggleTodoComplete(Todo todo) =>
      _todoRepository.toggleTodoComplete(todo);
}
