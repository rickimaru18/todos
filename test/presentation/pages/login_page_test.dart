import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:todos/core/errors/auth_failures.dart';
import 'package:todos/core/errors/failure.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/presentation/pages/pages.dart';
import 'package:todos/src/presentation/providers/providers.dart';
import 'package:todos/src/presentation/viewmodels/login_viewmodel.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../mocks.dart';
import '../build_widget.dart';

void main() {
  const String username = 'username';
  const String password = 'password';

  late Widget loginPage;
  late MockAuthUsecases authUsecases;
  late MockUserUsecases userUsecases;

  setUp(() {
    authUsecases = MockAuthUsecases();
    userUsecases = MockUserUsecases();

    loginPage = MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            userUsecases: userUsecases,
          ),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => LoginViewModel(authUsecases: authUsecases),
        ),
      ],
      child: const LoginPage(),
    );

    when(userUsecases.getLoggedInUser()).thenAnswer(
      (_) async => const Right<Failure, User?>(null),
    );
  });

  // Enter username and password textfields using the values, [username] and [password].
  //
  // [isLogin] - If TRUE, will perform login, otherwise, signup.
  // [isStopOnLoading] - If TRUE, will perform login or signup but will only
  //    pump 1 frame.
  Future<void> enterFieldsAndAuthenticate({
    required WidgetTester tester,
    required AppLocalizations appLocalizations,
    String username = username,
    String password = password,
    bool isLogin = true,
    bool isStopOnLoading = false,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, appLocalizations.username),
      username,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, appLocalizations.password),
      password,
    );
    await tester.pump();
    await tester.tap(
      find.text(isLogin ? appLocalizations.login : appLocalizations.signup),
    );

    if (isStopOnLoading) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  group('[Basic UI checks]', () {
    testWidgets('Initial display', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
      );

      expect(find.byType(AppIcon), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, appLocalizations.username),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, appLocalizations.password),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.text(appLocalizations.login), findsOneWidget);
      expect(find.text(appLocalizations.noAccountYet), findsOneWidget);
      expect(
        find.widgetWithText(TextButton, appLocalizations.signup),
        findsOneWidget,
      );
    });

    testWidgets('Login loading display', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
      );

      await tester.runAsync(() async {
        when(authUsecases.login(any, any)).thenAnswer(
          (_) => Future<Either<Failure, User>>.delayed(
            const Duration(seconds: 5),
            () => const Right<Failure, User>(
              User(id: 0, username: 'username'),
            ),
          ),
        );

        await enterFieldsAndAuthenticate(
          tester: tester,
          appLocalizations: appLocalizations,
          isStopOnLoading: true,
        );
      });

      verify(authUsecases.login(username, password));
      verifyNever(authUsecases.signup(username, password));
      verifyNoMoreInteractions(authUsecases);

      expect(find.byType(AppIcon), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, appLocalizations.username),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, appLocalizations.password),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.login), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(appLocalizations.login), findsOneWidget);
      expect(find.text(appLocalizations.noAccountYet), findsOneWidget);
      expect(
        find.widgetWithText(TextButton, appLocalizations.signup),
        findsOneWidget,
      );

      final TextField usernameField = tester.widget(
        find.widgetWithText(TextField, appLocalizations.username),
      ) as TextField;
      final TextField passwordField = tester.widget(
        find.widgetWithText(TextField, appLocalizations.password),
      ) as TextField;
      final ElevatedButton loginButton = tester.widget(
        find.byKey(const ValueKey<String>('LoginPage_loginButton')),
      ) as ElevatedButton;
      final TextButton signUpButton = tester.widget(
        find.widgetWithText(TextButton, appLocalizations.signup),
      ) as TextButton;

      expect(usernameField.readOnly, true);
      expect(passwordField.readOnly, true);
      expect(loginButton.onPressed, null);
      expect(signUpButton.onPressed, null);
    });

    testWidgets('Sign up loading display', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
      );

      await tester.runAsync(() async {
        when(authUsecases.signup(any, any)).thenAnswer(
          (_) => Future<Either<Failure, User>>.delayed(
            const Duration(seconds: 5),
            () => const Right<Failure, User>(User(id: 0, username: 'username')),
          ),
        );

        await enterFieldsAndAuthenticate(
          tester: tester,
          appLocalizations: appLocalizations,
          isLogin: false,
          isStopOnLoading: true,
        );
      });

      verifyNever(authUsecases.login(username, password));
      verify(authUsecases.signup(username, password));
      verifyNoMoreInteractions(authUsecases);

      expect(find.byType(AppIcon), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, appLocalizations.username),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, appLocalizations.password),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.login), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(appLocalizations.login), findsOneWidget);
      expect(find.text(appLocalizations.noAccountYet), findsOneWidget);
      expect(
        find.widgetWithText(TextButton, appLocalizations.signup),
        findsOneWidget,
      );

      final TextField usernameField = tester.widget(
        find.widgetWithText(TextField, appLocalizations.username),
      ) as TextField;
      final TextField passwordField = tester.widget(
        find.widgetWithText(TextField, appLocalizations.password),
      ) as TextField;
      final ElevatedButton loginButton = tester.widget(
        find.byKey(const ValueKey<String>('LoginPage_loginButton')),
      ) as ElevatedButton;
      final TextButton signUpButton = tester.widget(
        find.widgetWithText(TextButton, appLocalizations.signup),
      ) as TextButton;

      expect(usernameField.readOnly, true);
      expect(passwordField.readOnly, true);
      expect(loginButton.onPressed, null);
      expect(signUpButton.onPressed, null);
    });
  });

  group('[Input checks]', () {
    testWidgets('Username field max length check', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
      );

      // Valid length.
      await tester.enterText(
        find.widgetWithText(TextFormField, appLocalizations.username),
        username,
      );

      expect(find.widgetWithText(TextFormField, username), findsOneWidget);

      // Exceeds max length.
      await tester.enterText(
        find.widgetWithText(TextFormField, appLocalizations.username),
        '1234567890123456789012345678901234567890',
      );

      expect(
        find.widgetWithText(TextFormField, '12345678901234567890123456789012'),
        findsOneWidget,
      );
    });

    testWidgets('Password field max length check', (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
      );

      // Valid length.
      await tester.enterText(
        find.widgetWithText(TextFormField, appLocalizations.password),
        password,
      );

      expect(find.widgetWithText(TextFormField, password), findsOneWidget);

      // Exceeds max length.
      await tester.enterText(
        find.widgetWithText(TextFormField, appLocalizations.password),
        '1234567890123456789012345678901234567890123456789012345678901234567890',
      );

      expect(
        find.widgetWithText(
          TextFormField,
          '1234567890123456789012345678901234567890123456789012345678901234',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Username invalid characters check',
        (WidgetTester tester) async {
      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
      );

      // Valid chars.
      await tester.enterText(
        find.widgetWithText(TextFormField, appLocalizations.username),
        username,
      );

      expect(find.widgetWithText(TextFormField, username), findsOneWidget);

      // Invalid chars.
      await tester.enterText(
        find.widgetWithText(TextFormField, appLocalizations.username),
        '$username ',
      );

      expect(find.widgetWithText(TextFormField, username), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, appLocalizations.username),
        '$username!@"[]',
      );

      expect(find.widgetWithText(TextFormField, username), findsOneWidget);
    });
  });

  group('[Event checks]', () {
    testWidgets('Login successful', (WidgetTester tester) async {
      String? toRoute;

      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
        onNavigateTo: (String route) => toRoute = route,
      );

      when(authUsecases.login(any, any)).thenAnswer(
        (_) async => const Right<Failure, User>(
          User(id: 0, username: 'username'),
        ),
      );

      await enterFieldsAndAuthenticate(
        tester: tester,
        appLocalizations: appLocalizations,
      );

      verify(authUsecases.login(username, password));
      verifyNever(authUsecases.signup(username, password));
      verifyNoMoreInteractions(authUsecases);

      expect(find.byType(LoginPage), findsNothing);
      expect(toRoute, HomePage.routeName);
    });

    testWidgets('Signup successful', (WidgetTester tester) async {
      String? toRoute;

      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
        onNavigateTo: (String route) => toRoute = route,
      );

      when(authUsecases.signup(any, any)).thenAnswer(
        (_) async => const Right<Failure, User>(
          User(id: 0, username: 'username'),
        ),
      );

      await enterFieldsAndAuthenticate(
        tester: tester,
        appLocalizations: appLocalizations,
        isLogin: false,
      );

      verifyNever(authUsecases.login(username, password));
      verify(authUsecases.signup(username, password));
      verifyNoMoreInteractions(authUsecases);

      expect(find.byType(LoginPage), findsNothing);
      expect(toRoute, HomePage.routeName);
    });

    testWidgets('Login failure', (WidgetTester tester) async {
      String? toRoute;

      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
        onNavigateTo: (String route) => toRoute = route,
      );

      when(authUsecases.login(any, any)).thenAnswer(
        (_) async => const Left<Failure, User>(InvalidUsernameFailure()),
      );

      await enterFieldsAndAuthenticate(
        tester: tester,
        appLocalizations: appLocalizations,
        username: '',
      );

      verify(authUsecases.login('', password));
      verifyNever(authUsecases.signup('', password));
      verifyNoMoreInteractions(authUsecases);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.widgetWithText(SnackBar, const InvalidUsernameFailure().error),
        findsOneWidget,
      );
      expect(toRoute, null);
    });

    testWidgets('Signup failure', (WidgetTester tester) async {
      String? toRoute;

      final AppLocalizations appLocalizations = await buildWidget(
        tester,
        loginPage,
        onNavigateTo: (String route) => toRoute = route,
      );

      when(authUsecases.signup(any, any)).thenAnswer(
        (_) async => const Left<Failure, User>(InvalidUsernameFailure()),
      );

      await enterFieldsAndAuthenticate(
        tester: tester,
        appLocalizations: appLocalizations,
        username: '',
        isLogin: false,
      );

      verifyNever(authUsecases.login('', password));
      verify(authUsecases.signup('', password));
      verifyNoMoreInteractions(authUsecases);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.widgetWithText(SnackBar, const InvalidUsernameFailure().error),
        findsOneWidget,
      );
      expect(toRoute, null);
    });
  });
}
