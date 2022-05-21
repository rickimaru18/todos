import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/presentation/pages/pages.dart';

import '../build_widget.dart';

void main() {
  testWidgets('Check all components', (WidgetTester tester) async {
    final AppLocalizations appLocalizations =
        await buildWidget(tester, const UnknownPage());

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    expect(find.text(appLocalizations.unknownPage), findsOneWidget);
  });
}
