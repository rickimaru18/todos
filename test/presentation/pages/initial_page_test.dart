import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/presentation/pages/pages.dart';
import 'package:todos/src/presentation/providers/providers.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../mocks.dart';
import '../build_widget.dart';

void main() {
  late MockUserUsecases userUsecases;
  late Widget initialPage;

  setUp(() {
    userUsecases = MockUserUsecases();
    initialPage = ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(
        userUsecases: userUsecases,
      ),
      child: const InitialPage(),
    );
  });

  testWidgets('Check all components', (WidgetTester tester) async {
    await tester.runAsync(() async {
      when(userUsecases.getLoggedInUser()).thenAnswer(
        (_) => Future<Either<Failure, User?>>.delayed(
          const Duration(seconds: 5),
          () => const Right<Failure, User?>(null),
        ),
      );

      await buildWidget(tester, initialPage);

      verify(userUsecases.getLoggedInUser());
      verifyNoMoreInteractions(userUsecases);

      expect(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(AppIcon),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Already logged-in', (WidgetTester tester) async {
    String? toRoute;

    when(userUsecases.getLoggedInUser()).thenAnswer(
      (_) async => const Right<Failure, User?>(
        User(id: 0, username: 'username'),
      ),
    );

    await buildWidget(
      tester,
      initialPage,
      onNavigateTo: (String route) => toRoute = route,
    );

    verify(userUsecases.getLoggedInUser());
    verifyNoMoreInteractions(userUsecases);

    expect(find.byType(InitialPage), findsOneWidget);
    expect(toRoute, HomePage.routeName);
  });

  testWidgets('Not yet logged-in', (WidgetTester tester) async {
    String? toRoute;

    when(userUsecases.getLoggedInUser()).thenAnswer(
      (_) async => const Right<Failure, User?>(null),
    );

    await buildWidget(
      tester,
      initialPage,
      onNavigateTo: (String route) => toRoute = route,
    );

    verify(userUsecases.getLoggedInUser());
    verifyNoMoreInteractions(userUsecases);

    expect(find.byType(InitialPage), findsOneWidget);
    expect(toRoute, LoginPage.routeName);
  });
}
