import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../build_widget.dart';

void main() {
  final List<Todo> todos = List<Todo>.generate(
    10,
    (int i) => Todo(
      userId: 0,
      id: i,
      title: 'Todo $i',
    ),
  );

  group('[TodoListView default "itemBuilder"]', () {
    Todo? toggledTodo;

    final TodoListView todoListView = TodoListView(
      onToggleComplete: (Todo todo) => toggledTodo = todo,
      todos: todos,
    );

    testWidgets('Check all components', (WidgetTester tester) async {
      await buildWidget(tester, todoListView);

      expect(find.byType(TodoListTile), findsNWidgets(todos.length));

      for (int i = 0; i < todos.length; i++) {
        expect(
            find.widgetWithText(TodoListTile, todos[i].title), findsOneWidget);
      }

      expect(
        find.widgetWithIcon(TodoListTile, Icons.check_circle_outline_rounded),
        findsNWidgets(todos.length),
      );
    });

    testWidgets('Check toggle complete event', (WidgetTester tester) async {
      await buildWidget(tester, todoListView);
      await tester.tap(find.byIcon(Icons.check_circle_outline_rounded).first);

      expect(toggledTodo, todos.first);
    });
  });

  group('[TodoListView custom "itemBuilder"]', () {
    Todo? toggledTodo;

    final TodoListView todoListView = TodoListView(
      onToggleComplete: (Todo todo) => toggledTodo = todo,
      todos: todos,
      itemBuilder: (_, int i) => Text('Custom ${todos[i].title}'),
    );

    testWidgets('Check all components', (WidgetTester tester) async {
      await buildWidget(tester, todoListView);

      expect(find.byType(TodoListTile), findsNothing);

      for (int i = 0; i < todos.length; i++) {
        expect(find.widgetWithText(TodoListTile, todos[i].title), findsNothing);
        expect(find.text('Custom ${todos[i].title}'), findsOneWidget);
      }
    });

    testWidgets('Check toggle complete event', (WidgetTester tester) async {
      await buildWidget(tester, todoListView);

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);

      await tester.tap(find.text('Custom ${todos.first.title}'));

      expect(toggledTodo, null);
    });
  });

  group('[TodoListTile UI checks]', () {
    testWidgets('Check all components', (WidgetTester tester) async {
      final Todo todo = todos.first;

      await buildWidget(
        tester,
        TodoListTile(todo: todo),
      );

      expect(find.text(todo.title), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('Check completed state', (WidgetTester tester) async {
      final Todo todo = Todo.complete(todos.first);

      await buildWidget(
        tester,
        TodoListTile(todo: todo),
      );

      expect(find.text(todo.title), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

      final Icon check = tester.widget(
        find.byIcon(Icons.check_circle_outline_rounded),
      ) as Icon;

      expect(check.color, Colors.lightGreen);
    });

    testWidgets('Check not completed state', (WidgetTester tester) async {
      final Todo todo = todos.first;

      await buildWidget(
        tester,
        TodoListTile(todo: todo),
      );

      expect(find.text(todo.title), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

      final Icon check = tester.widget(
        find.byIcon(Icons.check_circle_outline_rounded),
      ) as Icon;

      expect(check.color, Colors.black12);
    });

    testWidgets('Check toggle complete event', (WidgetTester tester) async {
      final Todo todo = todos.first;

      Todo? toggledTodo;

      await buildWidget(
        tester,
        TodoListTile(
          onToggleComplete: () => toggledTodo = todo,
          todo: todo,
        ),
      );
      await tester.tap(find.byIcon(Icons.check_circle_outline_rounded));

      expect(toggledTodo, todo);
    });
  });
}
