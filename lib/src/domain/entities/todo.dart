import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 10)
class Todo extends HiveObject {
  Todo({
    required this.userId,
    required this.id,
    required this.title,
    this.completed = false,
  });

  factory Todo.complete(Todo todo) => Todo(
        userId: todo.userId,
        id: todo.id,
        title: todo.title,
        completed: true,
      );

  factory Todo.notComplete(Todo todo) => Todo(
        userId: todo.userId,
        id: todo.id,
        title: todo.title,
      );

  @HiveField(0)
  final int id;

  @HiveField(1)
  final int userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final bool completed;
}
