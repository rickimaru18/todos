import 'package:flutter/material.dart';
import 'package:todos/src/domain/entities/todo.dart';

class TodoListView extends StatelessWidget {
  const TodoListView({
    this.onToggleComplete,
    required this.todos,
    this.itemBuilder,
    super.key,
  });

  final ValueChanged<Todo>? onToggleComplete;
  final List<Todo> todos;
  final IndexedWidgetBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: todos.length,
      itemBuilder: itemBuilder ??
          (_, int i) {
            final Todo todo = todos[i];

            return TodoListTile(
              onToggleComplete: onToggleComplete != null
                  ? () => onToggleComplete!.call(todo)
                  : null,
              todo: todo,
            );
          },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }
}

//------------------------------------------------------------------------------
class TodoListTile extends StatelessWidget {
  const TodoListTile({
    this.onToggleComplete,
    required this.todo,
    super.key,
  });

  final VoidCallback? onToggleComplete;
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      selected: todo.completed,
      trailing: IconButton(
        onPressed: onToggleComplete,
        icon: Icon(
          Icons.check_circle_outline_rounded,
          color: todo.completed ? Colors.lightGreen : Colors.black12,
        ),
      ),
    );
  }
}
