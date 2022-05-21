import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todos/src/presentation/pages/pages.dart';
import 'package:todos/src/presentation/providers/user_provider.dart';
import 'package:todos/src/presentation/viewmodels/viewmodels.dart';

bool _isPreviousRouteInitial = false;

RouteFactory router = (RouteSettings routeSettings) {
  final Widget page;

  switch (routeSettings.name) {
    case InitialPage.routeName:
      page = const InitialPage();
      _isPreviousRouteInitial = true;
      break;

    case LoginPage.routeName:
      page = ChangeNotifierProvider(
        create: (_) => LoginViewModel(),
        child: const LoginPage(),
      );
      break;

    case HomePage.routeName:
      page = ChangeNotifierProvider(
        create: (BuildContext context) => HomeViewModel(
          userProvider: context.read<UserProvider>(),
        ),
        child: const HomePage(),
      );
      break;

    default:
      page = const UnknownPage();
  }

  if (_isPreviousRouteInitial && routeSettings.name != InitialPage.routeName) {
    _isPreviousRouteInitial = false;

    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) =>
          FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  return MaterialPageRoute<void>(
    settings: routeSettings,
    builder: (_) => page,
  );
};
