import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/presentation/pages/pages.dart';
import 'package:todos/src/presentation/providers/providers.dart';
import 'package:todos/src/presentation/viewmodels/viewmodels.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../mocks.dart';
import '../build_widget.dart';

void main() {
  const User user = User(id: 0, username: 'sampleUser');

  final List<Todo> todos = List<Todo>.generate(
    5,
    (int i) => Todo(
      userId: user.id,
      id: i,
      title: 'Todo $i',
      completed: i.isEven,
    ),
  );
  final int completedTodosCount =
      todos.where((Todo todo) => todo.completed).length;

  late MockUserUsecases userUsecases;
  late MockTodoUsecases todoUsecases;
  late Widget homePage;

  setUp(() {
    userUsecases = MockUserUsecases();
    todoUsecases = MockTodoUsecases();

    homePage = MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            userUsecases: userUsecases,
          )..user = user,
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (BuildContext context) => HomeViewModel(
            userProvider: context.read<UserProvider>(),
            todoUsecases: todoUsecases,
          ),
        ),
      ],
      child: const HomePage(),
    );

    when(userUsecases.getLoggedInUser()).thenAnswer(
      (_) async => const Right<Failure, User?>(user),
    );
    when(todoUsecases.listenToChanges(any)).thenAnswer(
      (_) async => const Right<Failure, Stream<List<Todo>>>(
        Stream<List<Todo>>.empty(),
      ),
    );
  });

  group('[Basic UI checks]', () {
    testWidgets('Check all components', (WidgetTester tester) async {
      when(todoUsecases.getTodos(any)).thenAnswer(
        (_) async => Right<Failure, List<Todo>>(todos),
      );

      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        homePage,
      );

      // AppBar section
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.widgetWithText(AppBar, appLocalizations.appTitle),
        findsOneWidget,
      );
      expect(find.widgetWithIcon(IconButton, Icons.menu), findsOneWidget);

      // Filter section
      expect(
        find.widgetWithText(TextField, appLocalizations.search),
        findsOneWidget,
      );
      expect(find.byType(TodoFilters), findsOneWidget);

      await tester.pump();

      // List section
      expect(find.byType(TodoListView), findsOneWidget);
      expect(find.byType(TodoListTile), findsNWidgets(todos.length));

      // Status section
      expect(find.text(completedTodosCount.toString()), findsOneWidget);
      expect(
        find.text(' of ${todos.length} ${appLocalizations.completed}'),
        findsOneWidget,
      );
    });

    testWidgets('Check loading state', (WidgetTester tester) async {
      await tester.runAsync(() async {
        when(todoUsecases.getTodos(any)).thenAnswer(
          (_) => Future<Either<Failure, List<Todo>>>.delayed(
            const Duration(seconds: 5),
            () => Right<Failure, List<Todo>>(todos),
          ),
        );

        final AppLocalizations appLocalizations = await buildWidget(
          tester,
          homePage,
        );

        // AppBar section
        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.widgetWithText(AppBar, appLocalizations.appTitle),
          findsOneWidget,
        );
        expect(find.widgetWithIcon(IconButton, Icons.menu), findsOneWidget);

        // Filter section
        expect(
          find.widgetWithText(TextField, appLocalizations.search),
          findsOneWidget,
        );
        expect(find.byType(TodoFilters), findsOneWidget);

        await tester.pump();

        // List section
        expect(find.byType(TodoListView), findsNothing);
        expect(find.byType(Loading), findsOneWidget);

        // Status section
        expect(find.text(completedTodosCount.toString()), findsNothing);
        expect(
          find.text(' of ${todos.length} ${appLocalizations.completed}'),
          findsNothing,
        );
      });
    });

    testWidgets('Check empty state', (WidgetTester tester) async {
      when(todoUsecases.getTodos(any)).thenAnswer(
        (_) async => const Right<Failure, List<Todo>>(<Todo>[]),
      );

      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        homePage,
      );

      // AppBar section
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.widgetWithText(AppBar, appLocalizations.appTitle),
        findsOneWidget,
      );
      expect(find.widgetWithIcon(IconButton, Icons.menu), findsOneWidget);

      // Filter section
      expect(
        find.widgetWithText(TextField, appLocalizations.search),
        findsOneWidget,
      );
      expect(find.byType(TodoFilters), findsOneWidget);

      await tester.pump();

      // List section
      expect(find.byType(TodoListView), findsNothing);
      expect(find.byType(Empty), findsOneWidget);

      // Status section
      expect(find.text(completedTodosCount.toString()), findsNothing);
      expect(
        find.text(' of ${todos.length} ${appLocalizations.completed}'),
        findsNothing,
      );
    });
  });

  group('[Drawer checks]', () {
    setUp(() {
      when(todoUsecases.getTodos(any)).thenAnswer(
        (_) async => const Right<Failure, List<Todo>>(<Todo>[]),
      );
      when(userUsecases.logout()).thenAnswer(
        (_) async => const Right<Failure, bool>(true),
      );
    });

    testWidgets('Check all components', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        homePage,
      );

      expect(find.byType(Drawer), findsNothing);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);
      expect(
        find.widgetWithText(CircleAvatar, user.username[0].toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(user.username), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, appLocalizations.logout),
        findsOneWidget,
      );
    });

    testWidgets('Logout', (WidgetTester tester) async {
      String? toRoute;

      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        homePage,
        onNavigateTo: (String route) => toRoute = route,
      );

      expect(find.byType(Drawer), findsNothing);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);

      await tester.tap(
        find.widgetWithText(ElevatedButton, appLocalizations.logout),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
      expect(toRoute, LoginPage.routeName);
    });
  });

  group('[Filter checks]', () {
    setUp(() {
      when(todoUsecases.getTodos(any)).thenAnswer(
        (_) async => Right<Failure, List<Todo>>(todos),
      );
    });

    testWidgets('Search', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        homePage,
      );

      // Search specific todo.
      await tester.enterText(
        find.widgetWithText(TextField, appLocalizations.search),
        todos.first.title,
      );
      await tester.pump();

      expect(find.byType(TodoListView), findsOneWidget);
      expect(find.byType(TodoListTile), findsOneWidget);

      // Search keyword.
      await tester.enterText(
        find.widgetWithText(TextField, appLocalizations.search),
        'Todo ',
      );
      await tester.pump();

      expect(find.byType(TodoListView), findsOneWidget);
      expect(find.byType(TodoListTile), findsNWidgets(todos.length));

      // Search unknown.
      await tester.enterText(
        find.widgetWithText(TextField, appLocalizations.search),
        'lda;skfjlkadsjf',
      );
      await tester.pump();

      expect(find.byType(TodoListView), findsNothing);
      expect(find.byType(Empty), findsOneWidget);
    });

    testWidgets('Filter via "TodoFilters"', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        homePage,
      );

      // Filter completed todos.
      await tester.tap(
        find.widgetWithText(RadioButton<bool?>, appLocalizations.completed),
      );
      await tester.pump();

      expect(find.byType(TodoListView), findsOneWidget);
      expect(find.byType(TodoListTile), findsNWidgets(completedTodosCount));

      // Filter not completed todos.
      await tester.tap(
        find.widgetWithText(RadioButton<bool?>, appLocalizations.todo),
      );
      await tester.pump();

      expect(find.byType(TodoListView), findsOneWidget);
      expect(
        find.byType(TodoListTile),
        findsNWidgets(todos.length - completedTodosCount),
      );

      // Filter all todos.
      await tester.tap(
        find.widgetWithText(RadioButton<bool?>, appLocalizations.all),
      );
      await tester.pump();

      expect(find.byType(TodoListView), findsOneWidget);
      expect(find.byType(TodoListTile), findsNWidgets(todos.length));
    });
  });
}
