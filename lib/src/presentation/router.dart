import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/pages.dart';
import 'providers/user_provider.dart';
import 'viewmodels/viewmodels.dart';

bool _isPreviousRouteInitial = false;

RouteFactory router = (RouteSettings routeSettings) {
  final Widget page;

  switch (routeSettings.name) {
    case InitialPage.routeName:
      page = const InitialPage();
      _isPreviousRouteInitial = true;
      break;

    case LoginPage.routeName:
      page = ChangeNotifierProvider<LoginViewModel>(
        create: (_) => LoginViewModel(),
        child: const LoginPage(),
      );
      break;

    case HomePage.routeName:
      page = ChangeNotifierProvider<HomeViewModel>(
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

    return PageRouteBuilder<dynamic>(
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
