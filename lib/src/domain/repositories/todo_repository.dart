import 'package:dartz/dartz.dart';

import '../../../core/errors/failure.dart';
import '../entities/todo.dart';

abstract class TodoRepository {
  /// Get TODOs based from [userId].
  Future<Either<Failure, List<Todo>>> getTodos(int userId);

  /// Listen to changes of TODOs with [userId].
  Future<Either<Failure, Stream<List<Todo>>>> listenToChanges(int userId);

  /// Toggle [todo.completed] state.
  Future<Either<Failure, Todo>> toggleTodoComplete(Todo todo);
}
