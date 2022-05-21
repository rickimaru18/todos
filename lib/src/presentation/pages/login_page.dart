import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:todos/core/settings/configs.dart';
import 'package:todos/src/domain/entities/user.dart';
import 'package:todos/src/presentation/pages/pages.dart';
import 'package:todos/src/presentation/providers/providers.dart';
import 'package:todos/src/presentation/viewmodels/login_viewmodel.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  static const String routeName = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final LoginViewModel _viewModel = context.read<LoginViewModel>();

  @override
  void initState() {
    super.initState();

    _viewModel.onError = (String error) => showErrorSnackBar(context, error);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Callback when login button is pressed.
  Future<void> _onLogin() async => _authenticationPostProcess(
        await _viewModel.login(
          _usernameController.text,
          _passwordController.text,
        ),
      );

  /// Callback when signup button is pressed.
  Future<void> _onSignup() async => _authenticationPostProcess(
        await _viewModel.signup(
          _usernameController.text,
          _passwordController.text,
        ),
      );

  /// Process after executing authentication.
  void _authenticationPostProcess(User? user) {
    context.read<UserProvider>().user = user;

    if (mounted && user != null) {
      Navigator.of(context).pushReplacementNamed(HomePage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AppIcon(),
            const SizedBox(height: 20),
            _Form(
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),
            const SizedBox(height: 40),
            _SubmitSection(
              onLogin: _onLogin,
              onSignup: _onSignup,
            ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
class _Form extends StatelessWidget {
  const _Form({
    required this.usernameController,
    required this.passwordController,
    super.key,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Selector<LoginViewModel, bool>(
      selector: (_, LoginViewModel viewModel) => viewModel.isLoggingIn,
      builder: (_, bool isLoggingIn, __) => Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.username,
              ),
              readOnly: isLoggingIn,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9a-zA-Z._]')),
                LengthLimitingTextInputFormatter(Configs.usernameMaxLength),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.password,
              ),
              readOnly: isLoggingIn,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(Configs.passwordMaxLength),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
class _SubmitSection extends StatelessWidget {
  const _SubmitSection({
    required this.onLogin,
    required this.onSignup,
    super.key,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignup;

  /// Build "Login" button.
  Widget _buildLoginButton() => Selector<LoginViewModel, bool>(
        selector: (_, LoginViewModel viewModel) => viewModel.isLoggingIn,
        builder: (BuildContext context, bool isLoggingIn, __) =>
            ElevatedButton.icon(
          key: const ValueKey<String>('LoginPage_loginButton'),
          onPressed: isLoggingIn ? null : onLogin,
          icon: isLoggingIn
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.login),
          label: Text(AppLocalizations.of(context)!.login),
        ),
      );

  /// Build "Sign up" button.
  Widget _buildSignupButton() => Selector<LoginViewModel, bool>(
        selector: (_, LoginViewModel viewModel) => viewModel.isLoggingIn,
        builder: (BuildContext context, bool isLoggingIn, __) => TextButton(
          onPressed: isLoggingIn ? null : onSignup,
          child: Text(AppLocalizations.of(context)!.signup),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildLoginButton(),
        const Divider(height: 30),
        Text(AppLocalizations.of(context)!.noAccountYet),
        _buildSignupButton(),
      ],
    );
  }
}
