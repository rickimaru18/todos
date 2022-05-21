import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/core/errors/todo_failures.dart';
import 'package:todos/src/data/models/todo_model.dart';
import 'package:todos/src/data/repositories/todo_repository_impl.dart';
import 'package:todos/src/domain/entities/entities.dart';

import '../../mocks.mocks.dart';

void main() {
  const int userId = 0;

  late MockTodoLocalSource todoLocalSource;
  late MockTodoRemoteSource todoRemoteSource;
  late TodoRepositoryImpl todoRepository;

  setUp(() {
    todoLocalSource = MockTodoLocalSource();
    todoRemoteSource = MockTodoRemoteSource();
    todoRepository = TodoRepositoryImpl(
      todoLocalSource: todoLocalSource,
      todoRemoteSource: todoRemoteSource,
    );
  });

  test('Getting TODOs successfully from remote source', () async {
    final List<TodoModel> todos = <TodoModel>[];

    when(todoLocalSource.hasTodos(any)).thenAnswer((_) async => false);
    when(todoRemoteSource.getTodos()).thenAnswer((_) async => todos);
    when(todoLocalSource.getTodos(any)).thenAnswer((_) async => todos);

    final Either<Failure, List<Todo>> res =
        await todoRepository.getTodos(userId);

    expect(res.isRight(), true);
    verify(todoLocalSource.hasTodos(userId));
    verify(todoRemoteSource.getTodos());
    verify(todoLocalSource.addTodos(todos));
    verify(todoLocalSource.getTodos(userId));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Getting TODOs successfully from local source', () async {
    final List<TodoModel> todos = <TodoModel>[];

    when(todoLocalSource.hasTodos(any)).thenAnswer((_) async => true);
    when(todoLocalSource.getTodos(any)).thenAnswer((_) async => todos);

    final Either<Failure, List<Todo>> res =
        await todoRepository.getTodos(userId);

    expect(res.isRight(), true);
    verify(todoLocalSource.hasTodos(userId));
    verify(todoLocalSource.getTodos(userId));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Getting TODOs failure', () async {
    when(todoLocalSource.hasTodos(any)).thenAnswer((_) async => false);
    when(todoRemoteSource.getTodos()).thenThrow(Exception());

    final Either<Failure, List<Todo>> res =
        await todoRepository.getTodos(userId);

    expect(res.isLeft(), true);
    verify(todoLocalSource.hasTodos(userId));
    verify(todoRemoteSource.getTodos());
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Listen TODOs successfully from local source', () async {
    when(todoLocalSource.listenToChanges(any))
        .thenAnswer((_) async => const Stream<List<Todo>>.empty());

    final Either<Failure, Stream<List<Todo>>> res =
        await todoRepository.listenToChanges(userId);

    expect(res.isRight(), true);
    verify(todoLocalSource.listenToChanges(userId));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Listen TODOs successfully from local source', () async {
    when(todoLocalSource.listenToChanges(any))
        .thenAnswer((_) async => const Stream<List<Todo>>.empty());

    final Either<Failure, Stream<List<Todo>>> res =
        await todoRepository.listenToChanges(userId);

    expect(res.isRight(), true);
    verify(todoLocalSource.listenToChanges(userId));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Listen TODOs failure', () async {
    when(todoLocalSource.listenToChanges(any)).thenAnswer((_) async => null);

    final Either<Failure, Stream<List<Todo>>> res =
        await todoRepository.listenToChanges(userId);

    expect(res.isLeft(), true);
    verify(todoLocalSource.listenToChanges(userId));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Complete TODO successfully', () async {
    final Todo todo = Todo(userId: 0, id: 1, title: 'title');
    final Todo completedTodo = Todo.complete(todo);

    when(todoLocalSource.toggleTodoComplete(any))
        .thenAnswer((_) async => completedTodo);

    final Either<Failure, Todo> res =
        await todoRepository.toggleTodoComplete(todo);

    expect(res.isRight(), true);
    expect(res, Right<Failure, Todo>(completedTodo));
    verify(todoLocalSource.toggleTodoComplete(todo));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Complete TODO failure', () async {
    final Todo todo = Todo(userId: 0, id: 1, title: 'title');

    when(todoLocalSource.toggleTodoComplete(any)).thenAnswer((_) async => null);

    final Either<Failure, Todo> res =
        await todoRepository.toggleTodoComplete(todo);

    expect(res.isLeft(), true);
    expect(res, const Left<Failure, Todo>(CompleteTodoFailure()));
    verify(todoLocalSource.toggleTodoComplete(todo));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Not complete TODO successfully', () async {
    final Todo todo = Todo(
      userId: 0,
      id: 1,
      title: 'title',
      completed: true,
    );
    final Todo notCompletedTodo = Todo.notComplete(todo);

    when(todoLocalSource.toggleTodoComplete(any))
        .thenAnswer((_) async => notCompletedTodo);

    final Either<Failure, Todo> res =
        await todoRepository.toggleTodoComplete(todo);

    expect(res.isRight(), true);
    expect(res, Right<Failure, Todo>(notCompletedTodo));
    verify(todoLocalSource.toggleTodoComplete(todo));
    verifyNoMoreInteractions(todoLocalSource);
  });

  test('Not complete TODO failure', () async {
    final Todo todo = Todo(
      userId: 0,
      id: 1,
      title: 'title',
      completed: true,
    );

    when(todoLocalSource.toggleTodoComplete(any)).thenAnswer((_) async => null);

    final Either<Failure, Todo> res =
        await todoRepository.toggleTodoComplete(todo);

    expect(res.isLeft(), true);
    expect(res, const Left<Failure, Todo>(NotCompleteTodoFailure()));
    verify(todoLocalSource.toggleTodoComplete(todo));
    verifyNoMoreInteractions(todoLocalSource);
  });
}
