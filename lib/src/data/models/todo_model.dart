import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:todos/src/domain/entities/todo.dart';

part 'todo_model.g.dart';

@JsonSerializable()
class TodoModel extends Todo {
  TodoModel({
    required super.userId,
    required super.id,
    required super.title,
    super.completed,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
}

//------------------------------------------------------------------------------
@HiveType(typeId: 11)
class UserTodosModel extends HiveObject {
  UserTodosModel(this.todos);

  @HiveField(0)
  final List<Todo> todos;
}
