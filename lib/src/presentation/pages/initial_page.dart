import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todos/src/domain/entities/entities.dart';
import 'package:todos/src/presentation/pages/pages.dart';
import 'package:todos/src/presentation/providers/providers.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({
    super.key,
  });

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = context.read<UserProvider>();

    userProvider.onUserChanged = (User? user) {
      userProvider.onUserChanged = null;
      Navigator.of(context).pushReplacementNamed(
        user != null ? HomePage.routeName : LoginPage.routeName,
      );
    };

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: AppIcon(
          color: Colors.white,
        ),
      ),
    );
  }
}
