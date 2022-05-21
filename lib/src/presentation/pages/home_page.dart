import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:todos/src/domain/entities/todo.dart';
import 'package:todos/src/presentation/pages/pages.dart';
import 'package:todos/src/presentation/providers/providers.dart';
import 'package:todos/src/presentation/viewmodels/home_viewmodel.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  static const routeName = '/home';

  /// Callback when logout icon is pressed.
  Future<void> _onLogout(BuildContext context) async {
    final bool res = await context.read<UserProvider>().logout();

    if (res) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
    }
  }

  /// Build [Drawer].
  Drawer _buildDrawer(BuildContext context) {
    final UserProvider userProvider = context.read<UserProvider>();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              ListTile(
                textColor: Colors.white,
                leading: CircleAvatar(
                  backgroundColor: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)],
                  child: Text(userProvider.user!.username[0].toUpperCase()),
                ),
                title: Text(userProvider.user!.username),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _onLogout(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.logout,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Column(
        children: const <Widget>[
          _Filters(),
          _Todos(),
          _Status(),
        ],
      ),
    );
  }
}

//------------------------------------------------------------------------------
class _Filters extends StatelessWidget {
  const _Filters({
    super.key,
  });

  /// Build search textfield.
  Widget _buildSearchField(BuildContext context) {
    final HomeViewModel viewModel = context.read<HomeViewModel>();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        onChanged: viewModel.searchTodos,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
        ),
      ),
    );
  }

  /// Build [TodoFilters].
  Widget _buildFilters() => Selector<HomeViewModel, bool?>(
        selector: (_, HomeViewModel viewModel) => viewModel.showCompletedTodos,
        builder: (BuildContext context, bool? showCompletedTodos, __) =>
            TodoFilters(
          onChanged: (bool? value) =>
              context.read<HomeViewModel>().showCompletedTodos = value,
          groupValue: showCompletedTodos,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildSearchField(context),
        _buildFilters(),
      ],
    );
  }
}

//------------------------------------------------------------------------------
class _Todos extends StatelessWidget {
  const _Todos({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Selector<HomeViewModel, List<Todo>?>(
        selector: (_, HomeViewModel viewModel) => viewModel.todos,
        builder: (_, List<Todo>? todos, __) {
          if (todos == null) {
            return const Loading();
          } else if (todos.isEmpty) {
            return const Empty();
          }

          return TodoListView(
            onToggleComplete: context.read<HomeViewModel>().toggleCompleteState,
            todos: todos,
          );
        },
      ),
    );
  }
}

//------------------------------------------------------------------------------
class _Status extends StatelessWidget {
  const _Status({
    super.key,
  });

  /// Build status text.
  Widget _buildStatus(BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: 10,
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        color: Theme.of(context).primaryColor.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Selector<HomeViewModel, int>(
              selector: (_, HomeViewModel viewModel) =>
                  viewModel.completedTodosCount,
              builder: (_, int completedTodosCount, __) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$completedTodosCount',
                  key: ValueKey<int>(completedTodosCount),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            Text(
              ' of ${context.read<HomeViewModel>().allTodosCount} ${AppLocalizations.of(context)!.completed}',
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Selector<HomeViewModel, int>(
      selector: (_, HomeViewModel viewModel) => viewModel.allTodosCount,
      builder: (_, int allTodosCount, __) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: allTodosCount == 0 ? const SizedBox() : _buildStatus(context),
      ),
    );
  }
}
