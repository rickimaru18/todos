import 'dart:async';

import 'package:hive/hive.dart';

import '../../../domain/entities/todo.dart';
import '../../models/todo_model.dart';
import 'local_source.dart';

class TodoLocalSource extends LocalSource {
  factory TodoLocalSource() => _instance;

  TodoLocalSource._();

  static final TodoLocalSource _instance = TodoLocalSource._();

  late final LazyBox<UserTodosModel> _todos;

  @override
  void registerAdapters() {
    Hive.registerAdapter<Todo>(TodoAdapter());
    Hive.registerAdapter<UserTodosModel>(UserTodosModelAdapter());
  }

  @override
  Future<void> openBoxes() async {
    _todos = await Hive.openLazyBox<UserTodosModel>('todos');
  }

  /// Check if [userId] has TODOs.
  Future<bool> hasTodos(int userId) async {
    await areBoxesOpen;
    return _todos.containsKey(userId);
  }

  /// Get TODOs of [userId].
  Future<List<Todo>?> getTodos(int userId) async {
    await areBoxesOpen;
    return (await _todos.get(userId))?.todos;
  }

  /// Listen to changes of TODOs with [userId].
  Future<Stream<List<Todo>>?> listenToChanges(int userId) async {
    await areBoxesOpen;

    if (!_todos.containsKey(userId)) {
      return null;
    }

    return _todos
        .watch(
          key: userId,
        )
        .map<List<Todo>>(
          (BoxEvent event) => (event.value as UserTodosModel).todos,
        );
  }

  /// Add TODOs to a specific user ID.
  Future<void> addTodos(List<Todo> todos) async {
    await areBoxesOpen;

    if (todos.isEmpty) {
      return;
    }

    final Map<int, UserTodosModel> userTodos = <int, UserTodosModel>{};

    for (final Todo todo in todos) {
      userTodos[todo.userId]?.todos.add(todo);
      userTodos[todo.userId] ??= UserTodosModel(<Todo>[todo]);
    }

    await _todos.putAll(userTodos);
  }

  /// Toggle [todo.completed] state.
  Future<Todo?> toggleTodoComplete(Todo todo) async {
    await areBoxesOpen;

    final UserTodosModel? userTodos = await _todos.get(todo.userId);

    if (userTodos == null) {
      return null;
    }

    final List<Todo> todos = userTodos.todos;
    final Todo newTodo =
        todo.completed ? Todo.notComplete(todo) : Todo.complete(todo);

    todos[todos.indexWhere((Todo todoTmp) => todoTmp.id == todo.id)] = newTodo;
    await userTodos.save();

    return newTodo;
  }
}
