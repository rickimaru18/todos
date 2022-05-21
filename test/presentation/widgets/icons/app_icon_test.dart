import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../build_widget.dart';

void main() {
  const AppIcon appIcon = AppIcon();

  testWidgets('Check all components', (WidgetTester tester) async {
    final AppLocalizations appLocalizations =
        await buildWidget(tester, appIcon);

    expect(find.byIcon(Icons.assignment), findsOneWidget);
    expect(find.text(appLocalizations.appTitle), findsOneWidget);
  });
}
