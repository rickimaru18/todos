import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> buildWidget(
  WidgetTester tester,
  Widget widget, {
  ValueChanged<String>? onNavigateTo,
}) async {
  late AppLocalizations appLocalizations;

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: widget,
      ),
      builder: (BuildContext context, Widget? child) {
        appLocalizations = AppLocalizations.of(context)!;

        return child!;
      },
      onGenerateRoute: (RouteSettings routeSettings) {
        onNavigateTo?.call(routeSettings.name ?? '');

        return MaterialPageRoute<dynamic>(
          builder: (_) => const Scaffold(),
        );
      },
    ),
  );

  return appLocalizations;
}
