import 'package:dio/dio.dart';
import 'package:todos/core/errors/todo_failures.dart';
import 'package:todos/src/data/datasources/local/todo_local_source.dart';
import 'package:todos/src/data/datasources/remote/todo_remote_source.dart';
import 'package:todos/src/domain/entities/todo.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:todos/src/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl({
    TodoLocalSource? todoLocalSource,
    TodoRemoteSource? todoRemoteSource,
  })  : _todoLocalSource = todoLocalSource ?? TodoLocalSource(),
        _todoRemoteSource = todoRemoteSource ?? TodoRemoteSource(Dio());

  final TodoLocalSource _todoLocalSource;
  final TodoRemoteSource _todoRemoteSource;

  @override
  Future<Either<Failure, List<Todo>>> getTodos(int userId) async {
    Either<Failure, List<Todo>> res;

    try {
      List<Todo> todos;

      if (!await _todoLocalSource.hasTodos(userId)) {
        todos = await _todoRemoteSource.getTodos();
        await _todoLocalSource.addTodos(todos);
      }

      todos = (await _todoLocalSource.getTodos(userId))!;
      res = Right(todos);
    } catch (e) {
      res = const Left(Failure('Getting TODOs failed. Please try again.'));
    }

    return res;
  }

  @override
  Future<Either<Failure, Stream<List<Todo>>>> listenToChanges(
    int userId,
  ) async {
    Either<Failure, Stream<List<Todo>>> res;

    try {
      final Stream<List<Todo>>? todosStream =
          await _todoLocalSource.listenToChanges(userId);
      res = todosStream != null
          ? Right(todosStream)
          : Left(Failure("Can't find TODOs with $userId user ID"));
    } catch (e) {
      res = const Left(Failure('Listening to TODOs failed. Please try again.'));
    }

    return res;
  }

  @override
  Future<Either<Failure, Todo>> toggleTodoComplete(Todo todo) async {
    Either<Failure, Todo> res;

    try {
      final Todo? newTodo = await _todoLocalSource.toggleTodoComplete(todo);

      if (newTodo != null) {
        res = Right(newTodo);
      } else if (!todo.completed) {
        res = const Left(CompleteTodoFailure());
      } else {
        res = const Left(NotCompleteTodoFailure());
      }
    } catch (e) {
      res = const Left(Failure('Getting TODOs failed. Please try again.'));
    }

    return res;
  }
}
