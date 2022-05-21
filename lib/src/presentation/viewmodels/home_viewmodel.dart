import 'dart:async';
import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/data/repositories/todo_repository_impl.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/domain/usecases/usecases.dart';
import 'package:todos/src/presentation/providers/providers.dart';
import 'package:todos/src/presentation/viewmodels/viewmodel.dart';

class HomeViewModel extends Viewmodel {
  HomeViewModel({
    required this.userProvider,
    TodoUsecases? todoUsecases,
  }) : _todoUsecases = todoUsecases ??
            TodoUsecases(
              todoRepository: TodoRepositoryImpl(),
            ) {
    getTodos();
  }

  final UserProvider userProvider;
  final TodoUsecases _todoUsecases;

  List<Todo>? _todos;
  StreamSubscription<List<Todo>>? _todosStreamSub;

  String _searchTerm = '';

  /// Flag if [getTodos] in ongoing.
  bool get isGettingTodos => _isGettingTodos;
  bool _isGettingTodos = false;

  /// Filter [todos].
  ///
  /// If [value] is NULL, show all.
  /// If [value] is TRUE, only show completed.
  /// IF [value] is FALSE, only show not completed.
  bool? get showCompletedTodos => _showCompletedTodos;
  bool? _showCompletedTodos;
  set showCompletedTodos(bool? value) {
    if (_showCompletedTodos == value) {
      return;
    }
    _showCompletedTodos = value;
    notifyListeners();
  }

  /// List of TODOs for [userProvider.user].
  UnmodifiableListView<Todo>? get todos {
    Iterable<Todo>? res;

    if (_showCompletedTodos == true) {
      res = _todos?.where((Todo todo) => todo.completed);
    } else if (_showCompletedTodos == false) {
      res = _todos?.where((Todo todo) => !todo.completed);
    } else {
      res = _todos;
    }

    if (_searchTerm.isNotEmpty) {
      res =
          res?.where((Todo todo) => todo.title.contains(_searchTerm)).toList();
    }

    return res != null ? UnmodifiableListView<Todo>(res) : null;
  }

  /// All TODOs count.
  int get allTodosCount => _todos?.length ?? 0;

  /// Completed TODOs count.
  int get completedTodosCount =>
      _todos?.where((Todo todo) => todo.completed).length ?? 0;

  /// Get TODOs.
  Future<void> getTodos() async {
    if (isGettingTodos) {
      return;
    }

    _isGettingTodos = true;
    notifyListeners();

    final Either<Failure, List<Todo>> res =
        await _todoUsecases.getTodos(userProvider.user!.id);

    res.fold(
      (Failure l) => onError?.call(l.error),
      (List<Todo> r) {
        _todos = r;
        _listenToChanges();
      },
    );

    _isGettingTodos = false;
    notifyListeners();
  }

  /// Listen to local data source changes.
  Future<void> _listenToChanges() async {
    await _todosStreamSub?.cancel();

    final Either<Failure, Stream<List<Todo>>> res =
        await _todoUsecases.listenToChanges(userProvider.user!.id);

    res.fold(
      (Failure l) => onError?.call(l.error),
      (Stream<List<Todo>> r) {
        _todosStreamSub = r.listen((List<Todo> changes) {
          _todos = changes;
          notifyListeners();
        });
      },
    );
  }

  /// Toggle [todo.completed] state.
  ///
  /// If successful, changes will auto reflect in [todos].
  Future<void> toggleCompleteState(Todo todo) async {
    final Either<Failure, Todo> res =
        await _todoUsecases.toggleTodoComplete(todo);

    res.fold(
      (Failure l) => onError?.call(l.error),
      (_) {
        // Do nothing.
      },
    );
  }

  /// Search [todos] with [name].
  void searchTodos(String name) {
    final String trimmedName = name.trim();

    if (_searchTerm == trimmedName) {
      return;
    }

    _searchTerm = trimmedName;
    notifyListeners();
  }
}
